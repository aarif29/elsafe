# Dashboard ULP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mengubah dashboard menjadi ringkasan temuan `Open` per ULP dengan pilihan ULP untuk admin.

**Architecture:** Gunakan data `TemuanModel` dari `getAllTemuanSilent` yang sudah mengikuti hak akses. Pisahkan penghitungan ringkasan dari widget agar status dan cakupan bisa diuji langsung; layar merender agregat itu dengan kontrol ULP khusus admin.

**Tech Stack:** Flutter 3.29, Dart 3.7, Material 3, `flutter_test`; tanpa dependensi baru.

**Spec:** `docs/superpowers/specs/2026-11-05-dashboard-ulp-design.md`

## Global Constraints

- `Open` saja dihitung sebagai belum ditindaklanjuti.
- Default admin: Semua ULP; petugas: ULP dari profil.
- Seluruh visualisasi utama berbasis temuan `Open` dan tidak menampilkan jenis objek.
- Pertahankan pembukaan detail, navigasi daftar, mode terang/gelap, dan keadaan gagal/memuat.

## Review Focus

- Status kosong dan `On Progress` tidak menambah angka `Open`.
- Nama ULP lama dengan awalan `ULP` masuk kelompok yang sama.
- Admin yang memilih ULP melihat seluruh angka dan daftar berubah konsisten.
- Tidak ada penyulang tetap muncul sebagai kelompok tanpa label lokasi yang menyesatkan.
- Layar 320 px dengan skala teks 1,5 tidak overflow.

---

### Task 1: Agregasi ringkasan

**Files:** Create `lib/widgets/dashboard/dashboard_overview.dart`; Test `test/dashboard_overview_test.dart`.

**Interfaces:** `DashboardOverview.fromFindings(List<TemuanModel> findings, {String? selectedUlp, required bool groupByUlp})`; hasil menyediakan `openCount`, `openKmu`, `openRow`, `openOtherType`, `openByArea`, dan `priorityOpen`.

- [x] Tulis tes status, tipe, normalisasi ULP, kelompok tanpa lokasi, dan urutan prioritas.
- [x] Jalankan tes dan pastikan gagal karena API belum ada.
- [x] Implementasikan agregasi murni tanpa query baru.
- [x] Jalankan tes hingga lulus.

### Task 2: Dashboard responsif dan pemilih ULP admin

**Files:** Modify `lib/Screen/dashboard.dart`, `lib/widgets/dashboard/dashboard_stats_section.dart`, `lib/widgets/dashboard/dashboard_recent_activity.dart`; Create `lib/widgets/dashboard/dashboard_area_section.dart`; Modify `test/dashboard_distill_test.dart` dan `test/support/dashboard_fixture.dart`.

**Interfaces:** Layar memakai `DashboardOverview` dari Task 1; dropdown admin mengubah `selectedUlp`, lalu merender ulang seluruh bagian.

- [x] Tulis tes widget untuk default admin, pergantian ULP, cakupan petugas, keadaan kosong, navigasi, dan lebar sempit.
- [x] Jalankan tes dan pastikan gagal karena perilaku baru belum ada.
- [x] Implementasikan susunan ringkas responsif dan kontrol ULP.
- [x] Jalankan tes dashboard sampai lulus.

### Task 3: Verifikasi akhir

**Files:** Semua file di atas.

- [x] Jalankan `dart format` pada file yang berubah dan `flutter test`; jalankan analisis pada file terkait dashboard.
- [x] Periksa tampilan desktop dan ponsel dalam tema terang/gelap menggunakan pratinjau lokal.
- [x] Jalankan `graphify update .` setelah perubahan kode.
- [x] Periksa diff agar perubahan pengguna yang sudah ada tidak tersentuh.

## Review lanjutan

- [x] Pakai profil yang mencakup `ulp` dan `role` untuk dashboard.
- [x] Sertakan variasi nama ULP lama dan huruf pada query petugas.
- [x] Satukan nama ULP yang setara di grafik dan filter admin.
- [x] Tampilkan status kosong secara jujur pada detail peta.
- [x] Ambil seluruh halaman temuan agar jumlah tidak terpotong batas respons Supabase.

Analisis seluruh proyek masih gagal pada `firebase_options.dart` karena dependensi
`firebase_core` tidak terdaftar; analisis file terkait dashboard lulus tanpa isu.
