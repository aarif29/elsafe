# Changelog UI/UX ELSAFE

Catatan perubahan UI/UX per sesi kerja major.

## 2026-10-27 — Perapian UI/UX temuan 1–6

### Diubah

- **Tema formulir dan daftar:** formulir tambah/edit temuan, pemilih tanggal/tipe/foto, dialog, serta keadaan kosong/error mengikuti tema aktif.
- **Tampilan mobile:** filter daftar temuan membungkus sesuai lebar dan skala teks; area filter dan keadaan kosong dapat digulir. Badge kartu temuan terpisah dari deskripsi agar lebih mudah dibaca.
- **Label status:** Open, On Progress, Closed, dan status kosong/tidak dikenal dibedakan pada kartu dan detail. Filter Closed juga mengenali nilai lama `Close`.
- **Navigasi desktop:** layar lebar memakai NavigationRail; layar kecil tetap memakai navigasi bawah. State halaman dipertahankan saat ukuran berubah.
- **Login desktop/mobile:** panel dibatasi maksimum 440 px. Logo Google disatukan dalam tombol login.
- **Login sementara hanya Google:** placeholder opsi login, tautan daftar email, dan tautan lupa password disembunyikan dari halaman login. Alur reset password dan registrasi yang sudah ada di kode tidak dihapus; login email/password tidak diaktifkan.
- **Dashboard lebih ringkas:** sapaan dan nama pengguna memakai ruang lebih kecil; angka statistik lebih menonjol. Kartu statistik menyesuaikan layar sempit dan teks besar. Judul aktivitas diganti menjadi “Temuan Terbaru”. Perhitungan KPI tetap sama.
- **Panduan:** instruksi login diselaraskan dengan Google; petunjuk reset password dihapus.

### Verifikasi

- `flutter test --no-pub -r expanded` — **63 tes lulus**.
- `flutter test --no-pub test/widget_test.dart -r expanded` — **lulus** setelah pembaruan panduan.
- `flutter analyze --no-pub` pada enam file yang diubah untuk revisi dashboard/login/panduan — **No issues found**.
- `flutter build web --no-pub` — **berhasil**. Build menampilkan peringatan lama terkait registrasi service worker manual di `web/index.html`.
- `git diff --check` — tidak ada error whitespace.
- Halaman login hasil build diperiksa di browser pada desktop 1440×900 dan mobile 375×812; tidak ada error console.
- `graphify update .` berhasil setelah perubahan source.

### Batasan

- Login email/password belum tersedia dari halaman login. Tombol daftar email disembunyikan agar tidak membuka alur yang belum bisa digunakan untuk masuk.
- Tautan reset password disembunyikan dari login, tetapi implementasi reset dan callback recovery masih ada di source.
- Dashboard belum menambahkan KPI status Open/On Progress/Closed. Perubahan sesi ini merapikan penyajian KPI yang sudah ada tanpa mengubah workflow.
- Belum ada smoke test memakai akun/data riil. Pada saat catatan sesi ini dibuat, perubahan belum di-commit atau di-deploy.
