# Spec: Temuan Lifecycle — Matriks, Reminder, Closing, Sosialisasi

## Overview

Tambah temuan dan edit temuan diubah menjadi wizard 4 step. Step 1 (Temuan) wajib, steps 2–4 opsional dan bisa diisi kapan saja via edit.

---

## Database

### Kolom baru di tabel `temuan`

```sql
-- Matriks risiko
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS jarak_aktivitas TEXT;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS intensitas_aktivitas TEXT;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS jenis_objek TEXT;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS jenis_aset TEXT;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS lokasi_objek TEXT;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS skor_matriks INTEGER;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS level_risiko TEXT;
-- CHECK: NULL | 'Low' | 'Medium' | 'High'

-- Reminder (1x per temuan)
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS tgl_reminder DATE;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS foto_reminder TEXT[];

-- Closing (1x per temuan)
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS jenis_closing TEXT;
-- CHECK: NULL | 'pfk' | 'preventif'
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS tgl_closing DATE;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS foto_closing TEXT[];
```

Saat `jenis_closing` diisi, service otomatis set `status_temuan = 'Closed'`.

### Tabel baru `temuan_sosialisasi`

```sql
CREATE TABLE IF NOT EXISTS temuan_sosialisasi (
  id              UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  temuan_id       UUID        NOT NULL REFERENCES temuan(id) ON DELETE CASCADE,
  tgl_sosialisasi DATE        NOT NULL,
  foto_urls       TEXT[],
  created_at      TIMESTAMPTZ DEFAULT now(),
  created_by      TEXT
);

ALTER TABLE temuan_sosialisasi ENABLE ROW LEVEL SECURITY;
CREATE POLICY "user_own_sosialisasi" ON temuan_sosialisasi
  USING (temuan_id IN (SELECT id FROM temuan WHERE user_id = auth.uid()));
```

---

## Matriks Risiko

| Dropdown | Pilihan | Nilai |
|----------|---------|-------|
| Jarak aktivitas terdekat | < 1 meter | 3 |
| | < 2 meter | 2 |
| | < 3 meter | 1 |
| Intensitas aktivitas pihak ketiga | Sering | 3 |
| | Jarang | 1 |
| Jenis objek potensi bahaya | Bangunan baru | 3 |
| | Bangunan lama | 3 |
| | Baliho / umbul-umbul | 3 |
| | Pohon | 1 |
| | Rawan layang-layang | 2 |
| Jenis aset | SUTM | 3 |
| | Trafo | 2 |
| | MVTIC | 1 |
| Lokasi objek | Samping jaringan | 3 |
| | Atas jaringan | 2 |
| | Bawah jaringan | 2 |

**Threshold:** Low = 6–9, Medium = 10–12, High = 13–15  
**Tampilan:** Hanya label level (Low/Medium/High), tanpa angka skor.  
**Kalkulasi:** Di client sebelum submit, hasil disimpan ke `skor_matriks` + `level_risiko`.

---

## Data Model (Dart)

### `TemuanModel` — field tambahan

```dart
// Matriks
final String? jarakAktivitas;
final String? intensitasAktivitas;
final String? jenisObjek;
final String? jenisAset;
final String? lokasiObjek;
final int?    skorMatriks;
final String? levelRisiko;

// Reminder
final DateTime?     tglReminder;
final List<String>? fotoReminder;

// Closing
final String?       jenisClosing;
final DateTime?     tglClosing;
final List<String>? fotoClosing;
```

### `SosialisasiModel` (baru)

```dart
class SosialisasiModel {
  final String?       id;
  final String        temuanId;
  final DateTime      tglSosialisasi;
  final List<String>? fotoUrls;
  final DateTime?     createdAt;
  final String?       createdBy;
}
```

### `TipeTemuan` — extension (di `temuan_types.dart`)

```dart
static int hitungSkor({required int jarak, required int intensitas,
    required int objek, required int aset, required int lokasi}) =>
    jarak + intensitas + objek + aset + lokasi;

static String levelDariSkor(int skor) {
  if (skor <= 9)  return 'Low';
  if (skor <= 12) return 'Medium';
  return 'High';
}
```

---

## Form Wizard

Wizard berlaku untuk `temuan.dart` (tambah) dan `edit_temuan.dart` (edit).

### Step 1 — Temuan (wajib)
- Field existing: lokasi, nama pemilik, nomor AMS, deskripsi, koordinat
- Field baru: tanggal temuan (date picker), foto temuan
- Matriks: 5 dropdown, tampilkan badge level (Low/Medium/High) real-time setelah semua dropdown diisi

### Step 2 — Reminder (opsional)
- Tanggal reminder (date picker)
- Foto surat tanda terima

### Step 3 — Closing (opsional)
- Warning: mengisi closing akan menutup temuan
- Jenis closing: dropdown PFK / Preventif
- Tanggal closing (date picker)
- Foto tindaklanjut

### Step 4 — Sosialisasi (opsional, recurring)
- Riwayat sosialisasi (list dari `temuan_sosialisasi`)
- Form tambah sosialisasi baru: tanggal + foto

---

## UI Updates

### `temuan_list_item.dart`
- Tambah badge `level_risiko` (Low=hijau, Medium=oranye, High=merah) di baris subtitle

### `temuan_detail_dialog.dart`
- Tambah section Matriks Risiko (tampilkan level badge)
- Tambah section Reminder (tanggal + foto)
- Tambah section Closing (jenis, tanggal, foto)
- Tambah section Sosialisasi (list riwayat)

### `TemuanService`
- `updateTemuan()` sudah cukup untuk reminder & closing
- Tambah `addSosialisasi()`, `getSosialisasiByTemuan()`, `deleteSosialisasi()`
- Saat closing diisi → otomatis set `status_temuan: 'Closed'` dalam payload yang sama

---

## Out of Scope (dikembangkan nanti)
- Push notification sosialisasi tiap semester
