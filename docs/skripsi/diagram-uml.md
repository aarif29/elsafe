# Diagram UML Aplikasi Elsafe

Dokumen ini disusun dari graphify `GRAPH_REPORT.md` dan pembacaan modul inti aplikasi Flutter/Supabase. Fokus sistem adalah pencatatan, pemantauan, tindak lanjut, notifikasi, pemetaan, dan export laporan temuan potensi bahaya KMU/ROW.

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

## 1. Use Case Diagram

```mermaid
flowchart LR
  petugas[Petugas / User]
  admin[Admin]
  supabase[(Supabase Auth, DB, Storage, Realtime)]
  google[Google OAuth / Google Maps]

  subgraph sistem[Elsafe App]
    ucLogin((Login dengan Google))
    ucRegister((Registrasi Email))
    ucReset((Reset Password))
    ucPilihUlp((Memilih ULP Awal))
    ucDashboard((Melihat Dashboard))
    ucTambah((Membuat Temuan KMU/ROW))
    ucUpload((Upload Foto Temuan))
    ucRisiko((Menghitung Matriks Risiko))
    ucLokasi((Memilih / Mengambil Lokasi))
    ucDaftar((Melihat Daftar Temuan))
    ucDetail((Melihat Detail Temuan))
    ucEdit((Mengubah Temuan))
    ucHapus((Menghapus Temuan))
    ucReminder((Mengisi Reminder))
    ucClosing((Mengisi Closing))
    ucSosialisasi((Mengelola Sosialisasi))
    ucNotif((Melihat dan Membaca Notifikasi))
    ucMaps((Melihat Temuan pada Peta))
    ucExport((Filter dan Export PDF))
    ucProfil((Mengelola Profil))
    ucReqUlp((Mengajukan Ganti ULP))
    ucApprove((Menyetujui / Menolak Ganti ULP))
    ucReadOnly((Melihat Semua Temuan Read-only))
    ucPanduan((Melihat Panduan Penggunaan))
  end

  petugas --> ucLogin
  petugas --> ucRegister
  petugas --> ucReset
  petugas --> ucPilihUlp
  petugas --> ucDashboard
  petugas --> ucTambah
  petugas --> ucDaftar
  petugas --> ucDetail
  petugas --> ucEdit
  petugas --> ucHapus
  petugas --> ucNotif
  petugas --> ucMaps
  petugas --> ucExport
  petugas --> ucProfil
  petugas --> ucReqUlp
  petugas --> ucPanduan

  admin --> ucLogin
  admin --> ucDashboard
  admin --> ucReadOnly
  admin --> ucNotif
  admin --> ucExport
  admin --> ucApprove
  admin --> ucPanduan

  ucTambah -. includes .-> ucUpload
  ucTambah -. includes .-> ucRisiko
  ucTambah -. includes .-> ucLokasi
  ucTambah -. includes .-> ucReminder
  ucEdit -. includes .-> ucClosing
  ucEdit -. includes .-> ucSosialisasi
  ucEdit -. includes .-> ucUpload
  ucExport -. includes .-> ucDaftar

  ucLogin --> google
  ucLokasi --> google
  ucMaps --> google

  ucLogin --> supabase
  ucRegister --> supabase
  ucReset --> supabase
  ucPilihUlp --> supabase
  ucTambah --> supabase
  ucUpload --> supabase
  ucDaftar --> supabase
  ucEdit --> supabase
  ucHapus --> supabase
  ucNotif --> supabase
  ucReqUlp --> supabase
  ucApprove --> supabase
  ucExport --> supabase
```

## 2. Class Diagram

```mermaid
classDiagram
  class MyApp {
    -GlobalKey navigatorKey
    -StreamSubscription authSubscription
    -bool isRedirecting
    +build()
    -setupAuthListener()
    -redirect()
    -navigateAfterLogin(nav, userId)
  }

  class ElsafeSplashScreen {
    +build()
    +initState()
    +dispose()
  }

  class ThemeService {
    +ThemeService instance
    +ValueNotifier themeMode
    +static light()
    +static dark()
    +loadTheme()
    +setTheme(mode)
  }

  class MainShell {
    -TemuanService temuanService
    -UlpService ulpService
    -int navIndex
    -bool isAdmin
    -bool hasLoadedRole
    -bool showPanduan
    -bool showExport
    +build()
    -loadRole()
    -openTambahTemuan()
    -handleLogout()
    +openPanduan()
    +closePanduan()
    +openExport()
    +closeExport()
    +backToDashboard()
    +openNotifications()
  }

  class DashboardScreen {
    -TemuanService temuanService
    +loadData()
    -loadDashboardData()
  }

  class DaftarTemuanScreen {
    -TemuanService temuanService
    -UlpService ulpService
    +loadData()
    -loadMoreData()
    -deleteTemuan(id)
    -showDetailDialog(temuan)
  }

  class TemuanScreen {
    -TemuanService temuanService
    +submitForm()
    -uploadFiles(files)
    -getCurrentLocation()
    -pickLocationManually()
  }

  class EditTemuanScreen {
    -TemuanService temuanService
    +loadSosialisasi()
    +submitForm()
    -uploadFiles(files)
  }

  class ExportTemuanScreen {
    -TemuanService temuanService
    -loadData()
    -applyFilters()
    -previewPdf()
    -exportPdf()
  }

  class MapsViewWidget {
    -TemuanService temuanService
    +build()
    -loadTemuan()
    -buildMarkers(list)
    -showMarkerDetail(temuan)
  }

  class NotificationsScreen {
    -NotificationService service
    -TemuanService temuanService
    -UlpService ulpService
    -load()
    -onTapNotif(notif)
    -markAllRead()
  }

  class AdminApprovalScreen {
    -UlpService ulpService
    +loadRequests()
    -approve(id)
    -reject(id)
  }

  class Profile {
    -SupabaseClient supabase
    -UlpService ulpService
    +loadProfile()
    -saveProfile()
    -showGantiUlpDialog()
  }

  class TemuanService {
    -SupabaseClient supabase
    -UlpService ulpService
    +currentUserId
    +currentUserEmail
    +getCurrentUserProfile()
    +uploadFoto(file)
    +deleteFoto(url)
    +deleteFotos(photoUrls)
    +createTemuan(temuan)
    +getTemuanPaginated(page, pageSize)
    +getAllTemuanSilent()
    +getTemuanById(id)
    +getTemuanByIdAny(id)
    +updateTemuan(id, temuan)
    +deleteTemuanSilent(id)
    +getUserStatistics()
    +addSosialisasi(sosialisasi)
    +getSosialisasiByTemuan(temuanId)
    +deleteSosialisasi(id)
  }

  class UlpService {
    -SupabaseClient supabase
    +getCurrentUserProfile()
    +isAdmin()
    +setUserUlp(ulp)
    +requestGantiUlp(ulpBaru, alasan)
    +hasPendingRequest()
    +getPendingRequests()
    +approveRequest(requestId)
    +rejectRequest(requestId)
  }

  class NotificationService {
    +NotificationService instance
    +ValueNotifier unreadCount
    -RealtimeChannel channel
    +initialize()
    +refreshUnreadCount()
    -subscribeRealtime()
    +getNotifications()
    +markAsRead(id)
    +markAllAsRead()
    +checkAndNotifyOverdue(temuanId, namaPemilik, lokasi, tglReminder)
    +clearReminderNotifIfNotOverdue(temuanId, tglReminder)
    +reset()
  }

  class TemuanModel {
    +String id
    +String lokasi
    +String alamatTemuan
    +String namaPemilik
    +DateTime tanggalTemuan
    +String deskripsiTemuan
    +double latitude
    +double longitude
    +List~String~ fotoUrls
    +String statusTemuan
    +String tipeTemuan
    +String ulp
    +String namaPenyulang
    +int section
    +int zona
    +int skorMatriks
    +String levelRisiko
    +DateTime tglReminder
    +DateTime tglClosing
    +Map toJson()
    +fromJson(json)
  }

  class SosialisasiModel {
    +String id
    +String temuanId
    +DateTime tglSosialisasi
    +List~String~ fotoUrls
    +String createdBy
    +Map toJson()
    +fromJson(json)
  }

  class MatriksRisiko {
    +hitungSkor(jarak, intensitas, objek, aset, lokasi)
    +levelDariSkor(skor)
    +skorDariNilai(options, value)
  }

  class Penyulang {
    +Map perUlp
    +untukUlp(ulp)
    +semua
  }

  class ExportTemuanPdfGenerator {
    +generate(temuan, startDate, endDate, ulpLabel)
  }

  class SupabaseConfig {
    +supabaseUrl
    +supabaseAnonKey
    +initialize()
  }

  MyApp --> SupabaseConfig
  MyApp --> ThemeService
  MyApp --> ElsafeSplashScreen
  MyApp --> MainShell
  MainShell --> DashboardScreen
  MainShell --> DaftarTemuanScreen
  MainShell --> TemuanScreen
  MainShell --> ExportTemuanScreen
  MainShell --> MapsViewWidget
  MainShell --> NotificationsScreen
  MainShell --> TemuanService
  MainShell --> UlpService
  MainShell --> NotificationService

  DashboardScreen --> TemuanService
  DaftarTemuanScreen --> TemuanService
  DaftarTemuanScreen --> UlpService
  TemuanScreen --> TemuanService
  TemuanScreen --> NotificationService
  EditTemuanScreen --> TemuanService
  EditTemuanScreen --> NotificationService
  ExportTemuanScreen --> TemuanService
  ExportTemuanScreen --> ExportTemuanPdfGenerator
  MapsViewWidget --> TemuanService
  NotificationsScreen --> NotificationService
  NotificationsScreen --> TemuanService
  NotificationsScreen --> UlpService
  AdminApprovalScreen --> UlpService
  Profile --> UlpService
  Profile --> AdminApprovalScreen

  TemuanService --> TemuanModel
  TemuanService --> SosialisasiModel
  TemuanService --> UlpService
  TemuanScreen --> MatriksRisiko
  TemuanScreen --> Penyulang
  EditTemuanScreen --> MatriksRisiko
  EditTemuanScreen --> Penyulang
  ExportTemuanPdfGenerator --> TemuanModel
  SosialisasiModel --> TemuanModel : temuanId
```

## 3. Sequence Diagram - Membuat Temuan

```mermaid
sequenceDiagram
  actor User as Petugas/User
  participant MainShell
  participant Form as TemuanScreen
  participant Lokasi as Location/Map Picker
  participant Risiko as MatriksRisiko
  participant TS as TemuanService
  participant US as UlpService
  participant NS as NotificationService
  participant SB as Supabase

  User->>MainShell: Pilih menu tambah temuan
  MainShell->>Form: Buka TemuanScreen
  Form->>US: getCurrentUserProfile()
  US->>SB: select profiles
  SB-->>US: profil user dan ULP
  US-->>Form: profil

  User->>Form: Isi data temuan, tipe KMU/ROW, penyulang, zona, section
  User->>Form: Pilih lokasi otomatis/manual
  Form->>Lokasi: Ambil GPS atau pilih titik peta
  Lokasi-->>Form: latitude, longitude, alamat/lokasi

  User->>Form: Isi parameter risiko
  Form->>Risiko: hitungSkor()
  Risiko-->>Form: skor dan level risiko

  User->>Form: Pilih foto temuan/reminder/closing/sosialisasi
  loop setiap file
    Form->>TS: uploadFoto(file)
    TS->>US: getCurrentUserProfile()
    US->>SB: select profiles
    SB-->>US: role dan ULP
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
    TS-->>Form: gagal, admin read-only
  else role user
    TS->>SB: insert table temuan
    SB-->>TS: row temuan
    TS-->>Form: sukses
    opt tgl_reminder sudah overdue >= 19 hari dan status Open
      Form->>NS: checkAndNotifyOverdue()
      NS->>SB: insert notifications untuk creator dan admin
    end
    Form-->>MainShell: pop(true)
    MainShell->>MainShell: refresh dashboard/list
  end
```

## 4. Sequence Diagram - Request Ganti ULP dan Approval Admin

```mermaid
sequenceDiagram
  actor User as Petugas/User
  actor Admin
  participant Profile
  participant Approval as AdminApprovalScreen
  participant US as UlpService
  participant SB as Supabase

  User->>Profile: Pilih ganti ULP
  Profile->>US: requestGantiUlp(ulpBaru, alasan)
  US->>SB: select profiles untuk ULP lama
  SB-->>US: profil user
  US->>SB: cek ulp_change_requests status pending
  alt sudah ada request pending
    US-->>Profile: gagal, request masih pending
  else belum ada request pending
    US->>SB: insert ulp_change_requests(status=pending)
    US-->>Profile: sukses, menunggu admin
  end

  Admin->>Approval: Buka persetujuan ULP (dari halaman Profil)
  Approval->>US: getPendingRequests()
  US->>SB: select ulp_change_requests pending
  US->>SB: select profiles pemohon
  SB-->>US: daftar request diperkaya profil
  US-->>Approval: data pending

  alt Admin menyetujui
    Admin->>Approval: Approve request
    Approval->>US: approveRequest(requestId)
    US->>SB: update request status approved
    US->>SB: update profiles.ulp user pemohon
    US-->>Approval: sukses
  else Admin menolak
    Admin->>Approval: Reject request
    Approval->>US: rejectRequest(requestId)
    US->>SB: update request status rejected
    US-->>Approval: sukses
  end
```

## 5. Activity Diagram - Workflow Pengelolaan Temuan

```mermaid
flowchart TD
  A([Mulai]) --> A0[Tampilkan SplashScreen]
  A0 --> B{Sesi autentikasi tersedia?}
  B -- Tidak --> C[Login Google / registrasi / reset password]
  C --> D{Session valid?}
  D -- Tidak --> C
  D -- Ya --> E{ULP sudah disetel?}
  B -- Ya --> E

  E -- Tidak --> F[Pilih ULP awal]
  F --> G[Simpan ULP ke profil]
  E -- Ya --> H[Masuk MainShell]
  G --> H

  H --> I[Dashboard]
  I --> J{Pilih fitur}

  J --> K[Tambah Temuan]
  K --> L[Isi identitas temuan dan tipe KMU/ROW]
  L --> M[Pilih lokasi dan penyulang]
  M --> N[Isi parameter matriks risiko]
  N --> O[Upload foto]
  O --> P[Isi reminder/closing/sosialisasi jika ada]
  P --> Q{Validasi form lengkap?}
  Q -- Tidak --> L
  Q -- Ya --> R[Simpan ke Supabase]
  R --> S{Simpan berhasil?}
  S -- Tidak --> T[Tampilkan error]
  T --> L
  S -- Ya --> U{Reminder overdue dan status Open?}
  U -- Ya --> V[Buat notifikasi user dan admin]
  U -- Tidak --> W[Refresh data]
  V --> W

  J --> X[Daftar Temuan]
  X --> Y[Search, filter, pagination]
  Y --> Z{Pilih aksi}
  Z --> AA[Lihat detail]
  Z --> AB[Edit temuan]
  Z --> AC[Hapus temuan]
  AB --> R
  AC --> AD{Role admin?}
  AD -- Ya --> AE[Ditolak: admin read-only]
  AD -- Tidak --> AF[Hapus data dan foto]
  AF --> W

  J --> AG[Notifikasi]
  AG --> AH[Tandai dibaca / buka temuan]
  AH --> AA

  J --> AI[Peta Temuan]
  AI --> AJ[Lihat marker dan detail lokasi]

  J --> AK[Export PDF]
  AK --> AL[Filter periode, status, risiko, ULP, penyulang, zona, section, tipe]
  AL --> AM[Pilih data]
  AM --> AN[Generate PDF]

  J --> AO[Profil]
  AO --> AP{Ajukan ganti ULP?}
  AP -- Ya --> AQ[Kirim request pending]
  AP -- Tidak --> J

  J --> AR{Admin?}
  AR -- Ya --> AS[Kelola approval ganti ULP]
  AS --> AT[Approve / reject request]
  AT --> J
  AR -- Tidak --> J

  W --> I
  AN --> I
  AE --> I
```

## 6. Deployment / Component Diagram

Diagram ini menjelaskan komponen-komponen utama dan layanan eksternal yang digunakan aplikasi.

```mermaid
flowchart LR
  subgraph Client[Client Device]
    Flutter[Flutter App\nAndroid / iOS / Web / Desktop]
  end

  subgraph SupabaseCloud[Supabase Cloud]
    Auth[Supabase Auth]
    DB[(PostgreSQL Database)]
    Storage[(Storage Bucket foto-temuan)]
    Realtime[Realtime Channel]
  end

  subgraph External[External Services]
    GoogleOAuth[Google OAuth]
    GoogleMaps[Google Maps\nvia url_launcher]
    OSM[OpenStreetMap\nTile Server]
  end

  Flutter --> Auth
  Flutter --> DB
  Flutter --> Storage
  Flutter --> Realtime
  Flutter --> GoogleOAuth
  Flutter --> GoogleMaps
  Flutter --> OSM

  DB --- Profiles[profiles]
  DB --- Temuan[temuan]
  DB --- Sosialisasi[temuan_sosialisasi]
  DB --- Notif[notifications]
  DB --- ULPReq[ulp_change_requests]
```

Catatan implementasi:
- Peta dalam aplikasi menggunakan `flutter_map` + tile OpenStreetMap (bukan Google Maps SDK).
- Tombol "Buka Maps" membuka Google Maps melalui `url_launcher` (external app/browser).

## 7. Entity Relationship Diagram

```mermaid
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

## Diagram Tambahan untuk Skripsi

Diagram yang sebaiknya ditambahkan selain empat UML utama:

1. ERD / Database Schema Diagram: penting karena aplikasi sangat bergantung pada tabel `profiles`, `temuan`, `temuan_sosialisasi`, `notifications`, dan `ulp_change_requests`.
2. Component Diagram: menunjukkan pembagian Flutter App, Supabase Auth, Database, Storage, Realtime, Google OAuth, OpenStreetMap, dan Google Maps.
3. Deployment Diagram: menjelaskan aplikasi berjalan di perangkat client dan berkomunikasi dengan Supabase Cloud serta layanan eksternal.
4. State Machine Diagram untuk status temuan: cocok untuk menjelaskan transisi `Open` ke `Closed`, serta kondisi reminder overdue.
5. Wireframe atau Navigation Flow: berguna di bab perancangan antarmuka untuk menjelaskan alur dari splash screen, login, dashboard, tambah temuan, daftar, peta, notifikasi, export, dan profil.

Rekomendasi prioritas untuk skripsi Teknik Informatika:
- Wajib: Use Case Diagram, Activity Diagram, Sequence Diagram, Class Diagram, ERD.
- Sangat disarankan: Component/Deployment Diagram.
- Opsional tetapi kuat: State Machine Diagram status temuan dan Navigation Flow.

## State Machine Diagram Tambahan - Status Temuan

```mermaid
stateDiagram-v2
  [*] --> Draft: User mengisi form
  Draft --> Open: Temuan berhasil disimpan
  Open --> Open: Reminder ditambahkan/diubah
  Open --> Overdue: tgl_reminder lewat >= 19 hari
  Overdue --> Notified: NotificationService membuat notifikasi
  Notified --> Open: Notifikasi dibaca, temuan belum closing
  Open --> Closed: jenis_closing/tgl_closing diisi
  Overdue --> Closed: closing dilakukan
  Notified --> Closed: closing dilakukan
  Closed --> [*]
```
