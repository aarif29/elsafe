# Plan: Temuan Lifecycle — Matriks, Reminder, Closing, Sosialisasi

## Urutan Implementasi

### Task 1 — Database (Supabase SQL Editor)
Jalankan SQL ini di Supabase:

```sql
-- Kolom matriks
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS jarak_aktivitas TEXT;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS intensitas_aktivitas TEXT;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS jenis_objek TEXT;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS jenis_aset TEXT;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS lokasi_objek TEXT;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS skor_matriks INTEGER;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS level_risiko TEXT;

-- Kolom reminder
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS tgl_reminder DATE;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS foto_reminder TEXT[];

-- Kolom closing
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS jenis_closing TEXT;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS tgl_closing DATE;
ALTER TABLE temuan ADD COLUMN IF NOT EXISTS foto_closing TEXT[];

-- Tabel sosialisasi
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

### Task 2 — `lib/config/temuan_types.dart`
- Tambah `hitungSkor()` dan `levelDariSkor()` static methods

### Task 3 — `lib/config/temuan_model.dart`
- Tambah 12 field baru (matriks, reminder, closing)
- Update constructor, `toJson()`, `fromJson()`

### Task 4 — `lib/config/sosialisasi_model.dart` (file baru)
- Buat `SosialisasiModel` dengan `fromJson()`, `toJson()`

### Task 5 — `lib/config/temuan_service.dart`
- Update `toJson()` di createTemuan/updateTemuan untuk field baru
- Saat `jenisClosing != null` → set `status_temuan: 'Closed'` otomatis
- Tambah `addSosialisasi()`, `getSosialisasiByTemuan()`, `deleteSosialisasi()`

### Task 6 — `lib/widgets/matriks_risiko_widget.dart` (file baru)
- Widget 5 dropdown matriks
- Callback `onChanged(String level, int skor)`
- Tampilkan badge level (Low/Medium/High) real-time setelah semua diisi, tanpa angka skor

### Task 7 — `lib/Screen/temuan.dart` (wizard tambah)
- Ubah form menjadi 4-step wizard (PageView + step indicator)
- Step 1: field existing + date picker tanggal temuan + foto + MatriksRisikoWidget
- Step 2: date picker reminder + foto_reminder
- Step 3: dropdown jenis_closing + date picker tgl_closing + foto_closing + warning auto-close
- Step 4: list sosialisasi (kosong saat tambah baru) + form tambah sosialisasi
- Submit di step 4: panggil createTemuan dengan semua field

### Task 8 — `lib/Screen/edit_temuan.dart` (wizard edit)
- Sama dengan Task 7 tapi pre-fill semua field dari `widget.temuan`
- Step 4 sosialisasi: load dan tampilkan riwayat, bisa tambah entri baru
- Submit: panggil updateTemuan + addSosialisasi jika ada tambah sosialisasi baru

### Task 9 — `lib/widgets/daftar_temuan/temuan_list_item.dart`
- Tambah badge `level_risiko` di subtitle (Low=hijau, Medium=oranye, High=merah)
- Null-safe: kalau belum ada level_risiko, tidak tampil badge

### Task 10 — `lib/widgets/daftar_temuan/temuan_detail_dialog.dart`
- Tambah section Matriks Risiko (badge level)
- Tambah section Reminder (tanggal + foto)
- Tambah section Closing (jenis, tanggal, foto)
- Tambah section Sosialisasi (list riwayat dari DB)

## Catatan
- Data lama (semua kolom NULL) tetap berjalan normal
- Foto reminder & closing ikut pola existing `foto_picker_widget.dart`
- Sosialisasi notification dikembangkan di sprint berikutnya
