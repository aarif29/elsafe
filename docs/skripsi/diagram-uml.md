# Diagram UML Aplikasi Elsafe

Dokumen ini disusun dari graphify `GRAPH_REPORT.md` dan pembacaan modul inti aplikasi Flutter/Supabase. Fokus sistem adalah pencatatan, pemantauan, tindak lanjut, notifikasi, pemetaan, dan export laporan temuan potensi bahaya KMU/ROW.

> **Catatan Format:** Semua diagram menggunakan tema `neutral` dan arah `TB`/`TD` agar sesuai orientasi *portrait* kertas A4. Class diagram dan activity diagram masing-masing dibagi dua bagian agar setiap gambar cukup dalam satu halaman A4.

## Ringkasan Aktor dan Modul

Aktor utama:
- Petugas/User: login, memilih ULP, membuat dan mengelola temuan, mengunggah foto, mengisi reminder/closing/sosialisasi, melihat peta, dan export laporan.
- Admin: melihat seluruh temuan, menerima notifikasi, dan menyetujui/menolak permintaan perubahan ULP. Pada kode saat ini admin bersifat read-only untuk data temuan.
- Supabase: layanan eksternal untuk Auth, database, storage foto, dan realtime notification.
- Google OAuth/Maps: layanan eksternal untuk autentikasi OAuth dan pembukaan lokasi peta (via url_launcher).

Modul inti:
- `MyApp`, `ElsafeSplashScreen`, `LoginPage`, `RegisterPage`, `NewPasswordPage`, `UlpSelectionScreen`
- `MainShell`, `DashboardScreen`, `DaftarTemuanScreen`, `TemuanScreen`, `EditTemuanScreen`
- `MapsViewWidget`, `NotificationsScreen`, `ExportTemuanScreen`, `AdminApprovalScreen`, `Profile`
- `TemuanService`, `UlpService`, `NotificationService`, `ThemeService`
- `TemuanModel`, `SosialisasiModel`, `TipeTemuan`, `MatriksRisiko`, `Penyulang`
- `filterExportTemuan`, `ExportTemuanPdfGenerator`
- `DashboardDrawer`, `PanduanPenggunaanScreen` (widget bantu di MainShell)

---

## 1. Use Case Diagram

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TB
  petugas([Petugas / User])
  admin([Admin])

  subgraph sistem["Sistem Elsafe"]
    subgraph grpAuth["Autentikasi"]
      ucLogin([Login Google])
      ucRegister([Registrasi])
      ucReset([Reset Sandi])
      ucPilihUlp([Pilih ULP Awal])
    end

    subgraph grpTemuan["Pengelolaan Temuan"]
      ucDashboard([Dashboard])
      ucTambah([Buat Temuan])
      ucDaftar([Daftar Temuan])
      ucDetail([Detail Temuan])
      ucEdit([Edit Temuan])
      ucHapus([Hapus Temuan])
    end

    subgraph grpSub["Sub-Proses Temuan"]
      ucUpload([Upload Foto])
      ucRisiko([Matriks Risiko])
      ucLokasi([Pilih Lokasi])
      ucReminder([Reminder])
      ucClosing([Closing])
      ucSosialisasi([Sosialisasi])
    end

    subgraph grpMonitor["Monitoring dan Output"]
      ucNotif([Notifikasi])
      ucMaps([Peta Temuan])
      ucExport([Export PDF])
      ucPanduan([Panduan])
    end

    subgraph grpProfil["Profil"]
      ucProfil([Profil])
      ucReqUlp([Ajukan Ganti ULP])
    end

    subgraph grpAdmin["Fitur Admin"]
      ucApprove([Approval Ganti ULP])
      ucReadOnly([Lihat Temuan])
    end
  end

  supabase[(Supabase)]
  google[Google OAuth / Maps]

  petugas --> ucLogin & ucRegister & ucReset & ucPilihUlp
  petugas --> ucDashboard & ucTambah & ucDaftar & ucDetail & ucEdit & ucHapus
  petugas --> ucNotif & ucMaps & ucExport & ucProfil & ucReqUlp & ucPanduan

  admin --> ucLogin & ucDashboard & ucReadOnly
  admin --> ucNotif & ucExport & ucApprove & ucPanduan

  ucTambah -.->|include| ucUpload
  ucTambah -.->|include| ucRisiko
  ucTambah -.->|include| ucLokasi
  ucTambah -.->|include| ucReminder
  ucEdit -.->|include| ucClosing
  ucEdit -.->|include| ucSosialisasi
  ucEdit -.->|include| ucUpload

  ucLogin --> google & supabase
  ucLokasi & ucMaps --> google
  ucRegister & ucReset & ucPilihUlp --> supabase
  ucTambah & ucUpload & ucDaftar & ucEdit & ucHapus --> supabase
  ucNotif & ucReqUlp & ucApprove & ucExport --> supabase
```

---

## 2a. Class Diagram – Layer UI

```mermaid
%%{init: {'theme': 'neutral'}}%%
classDiagram
  class MyApp {
    -GlobalKey navigatorKey
    -StreamSubscription authSubscription
    +build()
    -setupAuthListener()
    -navigateAfterLogin()
  }
  class ElsafeSplashScreen {
    +build()
    +initState()
  }
  class ThemeService {
    +ValueNotifier themeMode
    +loadTheme()
    +setTheme(mode)
  }
  class MainShell {
    -bool isAdmin
    -int navIndex
    +build()
    -loadRole()
    -handleLogout()
    +openNotifications()
  }
  class DashboardScreen {
    +loadData()
  }
  class DaftarTemuanScreen {
    +loadData()
    -deleteTemuan(id)
    -showDetailDialog()
  }
  class TemuanScreen {
    +submitForm()
    -uploadFiles()
    -getCurrentLocation()
  }
  class EditTemuanScreen {
    +submitForm()
    +loadSosialisasi()
    -uploadFiles()
  }
  class ExportTemuanScreen {
    -applyFilters()
    -previewPdf()
    -exportPdf()
  }
  class MapsViewWidget {
    -loadTemuan()
    -buildMarkers()
    -showMarkerDetail()
  }
  class NotificationsScreen {
    -load()
    -onTapNotif()
    -markAllRead()
  }
  class AdminApprovalScreen {
    +loadRequests()
    -approve(id)
    -reject(id)
  }
  class Profile {
    +loadProfile()
    -saveProfile()
    -showGantiUlpDialog()
  }

  MyApp --> ElsafeSplashScreen : navigates
  MyApp --> MainShell : navigates
  MyApp --> ThemeService
  MainShell --> DashboardScreen
  MainShell --> DaftarTemuanScreen
  MainShell --> TemuanScreen
  MainShell --> EditTemuanScreen
  MainShell --> ExportTemuanScreen
  MainShell --> MapsViewWidget
  MainShell --> NotificationsScreen
  Profile --> AdminApprovalScreen
```

---

## 2b. Class Diagram – Layer Service dan Model

```mermaid
%%{init: {'theme': 'neutral'}}%%
classDiagram
  class TemuanService {
    -SupabaseClient supabase
    +createTemuan(temuan)
    +updateTemuan(id, data)
    +deleteTemuanSilent(id)
    +getTemuanPaginated(page, size)
    +uploadFoto(file)
    +getUserStatistics()
    +addSosialisasi(data)
    +getSosialisasiByTemuan(id)
  }
  class UlpService {
    -SupabaseClient supabase
    +isAdmin()
    +setUserUlp(ulp)
    +requestGantiUlp(ulpBaru, alasan)
    +approveRequest(id)
    +rejectRequest(id)
    +getPendingRequests()
  }
  class NotificationService {
    +ValueNotifier unreadCount
    -RealtimeChannel channel
    +initialize()
    +getNotifications()
    +markAllAsRead()
    +checkAndNotifyOverdue(...)
    +refreshUnreadCount()
  }
  class TemuanModel {
    +String id
    +String lokasi
    +String statusTemuan
    +String tipeTemuan
    +String ulp
    +String namaPenyulang
    +int skorMatriks
    +String levelRisiko
    +toJson()
    +fromJson(json)$
  }
  class SosialisasiModel {
    +String id
    +String temuanId
    +DateTime tglSosialisasi
    +List fotoUrls
    +toJson()
    +fromJson(json)$
  }
  class MatriksRisiko {
    +hitungSkor(...)$
    +levelDariSkor(skor)$
  }
  class Penyulang {
    +Map perUlp$
    +untukUlp(ulp)$
  }
  class ExportTemuanPdfGenerator {
    +generate(temuan, start, end, ulp)$
  }
  class SupabaseConfig {
    +supabaseUrl$
    +initialize()$
  }

  TemuanService --> TemuanModel
  TemuanService --> SosialisasiModel
  TemuanService --> UlpService
  ExportTemuanPdfGenerator --> TemuanModel
  SosialisasiModel --> TemuanModel : temuanId
```

---

## 3. Sequence Diagram – Membuat Temuan

```mermaid
sequenceDiagram
  actor User as Petugas
  participant Form as TemuanScreen
  participant TS as TemuanService
  participant US as UlpService
  participant NS as NotificationService
  participant SB as Supabase

  User->>Form: Buka form tambah temuan
  Form->>US: getCurrentUserProfile()
  US->>SB: select profiles
  SB-->>US: profil user + ULP
  US-->>Form: profil

  User->>Form: Isi data, tipe KMU/ROW, penyulang, zona, section
  Note over Form: Hitung matriks risiko (lokal)
  User->>Form: Pilih lokasi GPS / manual
  Note over Form: Ambil latitude, longitude, alamat

  User->>Form: Pilih foto temuan
  loop setiap foto
    Form->>TS: uploadFoto(file)
    TS->>US: getCurrentUserProfile()
    US->>SB: select profiles
    SB-->>US: role + ULP
    TS->>SB: upload ke storage foto-temuan
    SB-->>TS: public URL
    TS-->>Form: URL foto
  end

  User->>Form: Simpan
  Form->>TS: createTemuan(TemuanModel)
  TS->>US: getCurrentUserProfile()
  US->>SB: select profiles
  SB-->>US: profil
  alt role admin
    TS-->>Form: gagal – admin read-only
  else role user
    TS->>SB: insert temuan
    SB-->>TS: row temuan baru
    TS-->>Form: sukses
    opt tgl_reminder overdue + status Open
      Form->>NS: checkAndNotifyOverdue()
      NS->>SB: insert notifications
    end
    Form-->>User: kembali ke dashboard
  end
```

---

## 4. Sequence Diagram – Request Ganti ULP dan Approval Admin

```mermaid
sequenceDiagram
  actor User as Petugas
  actor Admin
  participant Profile
  participant Approval as AdminApprovalScreen
  participant US as UlpService
  participant SB as Supabase

  User->>Profile: Pilih ganti ULP
  Profile->>US: requestGantiUlp(ulpBaru, alasan)
  US->>SB: select profiles (ULP lama)
  SB-->>US: profil user
  US->>SB: cek ulp_change_requests pending
  alt request pending sudah ada
    US-->>Profile: gagal – masih pending
  else belum ada request pending
    US->>SB: insert ulp_change_requests (status=pending)
    US-->>Profile: sukses, menunggu admin
  end

  Admin->>Approval: Buka persetujuan ULP
  Approval->>US: getPendingRequests()
  US->>SB: select ulp_change_requests pending
  US->>SB: select profiles pemohon
  SB-->>US: data request + profil
  US-->>Approval: daftar pending

  alt Admin menyetujui
    Admin->>Approval: Approve
    Approval->>US: approveRequest(requestId)
    US->>SB: update request → approved
    US->>SB: update profiles.ulp pemohon
    US-->>Approval: sukses
  else Admin menolak
    Admin->>Approval: Reject
    Approval->>US: rejectRequest(requestId)
    US->>SB: update request → rejected
    US-->>Approval: sukses
  end
```

---

## 5a. Activity Diagram – Alur Autentikasi dan Tambah Temuan

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
  A([Mulai]) --> A0[Tampilkan SplashScreen]
  A0 --> B{Sesi auth tersedia?}
  B -- Tidak --> C[Login Google / Registrasi / Reset Sandi]
  C --> D{Session valid?}
  D -- Tidak --> C
  D -- Ya --> E{ULP sudah disetel?}
  B -- Ya --> E

  E -- Tidak --> F[Pilih ULP Awal]
  F --> G[Simpan ULP ke profil]
  G --> H
  E -- Ya --> H[Masuk MainShell / Dashboard]

  H --> K[Tambah Temuan]
  K --> L[Isi identitas temuan + tipe KMU/ROW]
  L --> M[Pilih lokasi + penyulang / section / zona]
  M --> N[Isi parameter matriks risiko]
  N --> O[Upload foto temuan]
  O --> P[Isi reminder / closing / sosialisasi]
  P --> Q{Form valid?}
  Q -- Tidak --> L
  Q -- Ya --> R[Simpan ke Supabase]
  R --> S{Berhasil?}
  S -- Tidak --> T[Tampilkan pesan error]
  T --> L
  S -- Ya --> U{Reminder overdue\n+ status Open?}
  U -- Ya --> V[Buat notifikasi user dan admin]
  V --> W[Refresh dan kembali ke Dashboard]
  U -- Tidak --> W
  W --> H
```

---

## 5b. Activity Diagram – Alur Fitur Pendukung

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TD
  H([Dashboard]) --> J{Pilih fitur}

  J -- Daftar Temuan --> X[Tampilkan list + search / filter / pagination]
  X --> Z{Aksi pada temuan}
  Z -- Lihat Detail --> AA[Tampilkan detail temuan]
  Z -- Edit --> AB[Form Edit lalu Simpan ke Supabase]
  Z -- Hapus --> AC{Role admin?}
  AC -- Ya --> AE[Ditolak: admin read-only]
  AC -- Tidak --> AF[Hapus data dan foto]
  AA & AB & AF & AE --> J

  J -- Notifikasi --> AG[Tampilkan daftar notifikasi]
  AG --> AH[Tandai dibaca / buka temuan terkait]
  AH --> J

  J -- Peta --> AI[Tampilkan flutter_map + marker temuan]
  AI --> AJ[Lihat detail marker]
  AJ --> J

  J -- Export PDF --> AK[Buka filter laporan]
  AK --> AL[Filter: periode, status, risiko,\nULP, penyulang, zona, section, tipe]
  AL --> AM[Preview data terpilih]
  AM --> AN[Generate dan unduh PDF]
  AN --> J

  J -- Profil --> AO[Tampilkan profil user]
  AO --> AP{Ajukan ganti ULP?}
  AP -- Ya --> AQ[Kirim request, tunggu admin]
  AP -- Tidak --> J
  AQ --> J

  J -- Admin --> AR{Role admin?}
  AR -- Ya --> AS[Kelola approval ganti ULP]
  AS --> AT[Approve / Reject request]
  AT --> J
  AR -- Tidak --> J
```

---

## 6. Deployment / Component Diagram

```mermaid
%%{init: {'theme': 'neutral'}}%%
flowchart TB
  subgraph Client["Client Device"]
    Flutter["Flutter App\nAndroid / iOS / Web"]
  end

  subgraph SupabaseCloud["Supabase Cloud"]
    Auth["Supabase Auth"]
    DB[("PostgreSQL")]
    Storage[("Storage\nfoto-temuan")]
    Realtime["Realtime Channel"]
  end

  subgraph External["Layanan Eksternal"]
    GoogleOAuth["Google OAuth"]
    GoogleMaps["Google Maps\n(url_launcher)"]
    OSM["OpenStreetMap\nTile Server"]
  end

  Flutter --> Auth
  Flutter --> DB
  Flutter --> Storage
  Flutter --> Realtime
  Flutter --> GoogleOAuth
  Flutter --> GoogleMaps
  Flutter --> OSM

  DB --- Profiles["profiles"]
  DB --- Temuan["temuan"]
  DB --- Sosialisasi["temuan_sosialisasi"]
  DB --- Notif["notifications"]
  DB --- ULPReq["ulp_change_requests"]
```

Catatan implementasi:
- Peta dalam aplikasi menggunakan `flutter_map` + tile OpenStreetMap (bukan Google Maps SDK).
- Tombol "Buka Maps" membuka Google Maps melalui `url_launcher` (external app/browser).

---

## 7. Entity Relationship Diagram

```mermaid
%%{init: {'theme': 'neutral'}}%%
erDiagram
  profiles {
    uuid id PK
    string email
    string full_name
    string nip
    string phone
    string ulp
    string role
    string ulp_status
  }

  temuan {
    uuid id PK
    uuid user_id FK
    string created_by
    string lokasi
    string alamat_temuan
    string nama_pemilik
    date tanggal_temuan
    string deskripsi_temuan
    float latitude
    float longitude
    string_array foto_urls
    string nomor_ams
    string status_temuan
    string tipe_temuan
    string ulp
    string nama_penyulang
    int section
    int zona
    int skor_matriks
    string level_risiko
    date tgl_reminder
    string_array foto_reminder
    string jenis_closing
    date tgl_closing
    string_array foto_closing
  }

  temuan_sosialisasi {
    uuid id PK
    uuid temuan_id FK
    date tgl_sosialisasi
    string_array foto_urls
    string created_by
    timestamp created_at
  }

  notifications {
    uuid id PK
    uuid user_id FK
    uuid temuan_id FK
    string title
    string body
    string type
    boolean is_read
    timestamp created_at
  }

  ulp_change_requests {
    uuid id PK
    uuid user_id FK
    string ulp_lama
    string ulp_baru
    string alasan
    string status
    uuid reviewed_by FK
    timestamp reviewed_at
    timestamp created_at
  }

  profiles ||--o{ temuan : membuat
  profiles ||--o{ notifications : menerima
  profiles ||--o{ ulp_change_requests : mengajukan
  profiles ||--o{ ulp_change_requests : mereview
  temuan ||--o{ temuan_sosialisasi : memiliki
  temuan ||--o{ notifications : memicu
```

---

## 8. State Machine Diagram – Status Temuan

```mermaid
%%{init: {'theme': 'neutral'}}%%
stateDiagram-v2
  [*] --> Draft : User mengisi form
  Draft --> Open : Temuan berhasil disimpan
  Open --> Open : Reminder ditambahkan / diubah
  Open --> Overdue : tgl_reminder lewat >= 19 hari
  Overdue --> Notified : NotificationService membuat notifikasi
  Notified --> Open : Notifikasi dibaca, temuan belum closing
  Open --> Closed : jenis_closing / tgl_closing diisi
  Overdue --> Closed : closing dilakukan saat overdue
  Notified --> Closed : closing dilakukan setelah notifikasi
  Closed --> [*]
```

---

## Catatan Diagram untuk Skripsi

Diagram yang sudah tersedia dalam dokumen ini:

| No | Diagram | Keterangan |
|----|---------|-----------|
| 1 | Use Case Diagram | Aktor, use case, relasi include, layanan eksternal |
| 2a | Class Diagram – Layer UI | Screen, shell, widget; metode publik utama |
| 2b | Class Diagram – Layer Service & Model | Service, model, helper; relasi dependensi |
| 3 | Sequence – Membuat Temuan | Alur lengkap buat temuan + notifikasi overdue |
| 4 | Sequence – Ganti ULP & Approval | Request user → approval/reject admin |
| 5a | Activity – Autentikasi & Tambah Temuan | Login, pilih ULP, buat temuan, error handling |
| 5b | Activity – Fitur Pendukung | Daftar, notifikasi, peta, export, profil, admin |
| 6 | Deployment / Component | Flutter ↔ Supabase ↔ layanan eksternal |
| 7 | ERD | Skema tabel PostgreSQL dan relasi antar tabel |
| 8 | State Machine – Status Temuan | Transisi Draft → Open → Overdue → Closed |

Rekomendasi prioritas untuk skripsi Teknik Informatika:
- **Wajib:** Use Case Diagram, Activity Diagram (5a+5b), Sequence Diagram, Class Diagram (2a+2b), ERD.
- **Sangat disarankan:** Deployment/Component Diagram.
- **Opsional tetapi kuat:** State Machine Diagram status temuan.
