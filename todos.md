# 📋 todos.md - Export Temuan ke PDF

Setiap rencana & perubahan, akan ditulis dan diupdate di file ini. Jika sudah selesai bisa ditandai checklist step yang sudah, yang belum bisa dilanjutkan dilain sesi dengan berdasar dari file todos.md.

---

## 🚀 Step by Step Plan

### Phase 1: Setup & Assets

- [x] 1.1 Tambahkan dependencies di `pubspec.yaml`:
  ```yaml
  pdf: ^3.11.1
  printing: ^5.13.3
  ```

- [x] 1.2 Verifikasi logo ada di assets:
  - [x] `assets/Logo_PLN.png`
  - [x] `assets/Logo_HSSE_PLN.png`

---

### Phase 2: UI Halaman Export

- [x] 2.1 Buat halaman baru `lib/Screen/export_temuan.dart`
- [x] 2.2 Implementasi filter controls:
  - [x] Date range picker (tanggal dari - sampai)
  - [x] Multi-select untuk Status (Open, Closed, On Progress)
  - [x] Multi-select untuk Level Risiko (Tinggi, Sedang, Rendah)
  - [x] Multi-select untuk ULP (admin only)
  - [x] Multi-select untuk Zona (1-5)
  - [x] Multi-select untuk Section (1-10)
  - [x] Combo untuk Penyulang

- [x] 2.3 Tampilkan list temuan yang sudah difilter
- [x] 2.4 Checkbox untuk pilih/tidak dipilih per temuan
- [x] 2.5 Button "Pilih Semua" / "Unselect Semua"
- [x] 2.6 Button "Preview PDF" dan "Export & Share" (stub - implement di Phase 3)

**Integrasi:**
- [x] Tambah menu "Export Temuan ke PDF" di drawer
- [x] Connect ke main_shell.dart

---

### Phase 3: PDF Generation

- [ ] 3.1 Buat `lib/utils/pdf_generator.dart`
- [ ] 3.2 Implementasi header PDF:
  - Logo PLN (kanan atas)
  - Logo HSSE K3 PLN (kiri atas)
  - Judul: "LAPORAN TEMUAN INSIDEN/KELIHATAN"
  - Periode dan ULP

- [ ] 3.3 Implementasi tabel data PDF dengan kolom:
  - No, Tanggal, Lokasi, Penyulang, Zona, Section, Status, Level Risiko

- [ ] 3.4 Implementasi footer PDF:
  - Total temuan, breakdown by status
  - Tanggal generate

---

### Phase 4: Integrasi

- [ ] 4.1 Tambah menu/button Export di dashboard atau drawer
- [ ] 4.2 Testing dengan data dummy

---

## 📝 Catatan
- User role Admin bisa filter semua ULP, user biasa hanya ULP sendiri
- Logo sudah ada di folder assets sesuai request
- PDF bisa di-preview sebelum didownload/share