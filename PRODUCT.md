# ELSAFE — Product

<!-- impeccable:product-schema 1 -->

## Platform

web

Web responsif untuk desktop dan ponsel adalah acuan utama desain, dikonfirmasi pengguna saat init pada 27 Oktober 2026. Implementasi menggunakan Flutter/Dart. Keberadaan scaffold native tidak menetapkan Android atau iOS sebagai target utama.

## Users

- Petugas PLN per ULP (Unit Layanan Pelanggan): mencatat dan menindaklanjuti temuan potensi bahaya listrik di wilayah tugasnya.
- Admin: memantau temuan lintas ULP dan meninjau data pengguna. Implementasi saat ini membatasi admin sebagai pembaca untuk temuan; admin tidak membuat, mengedit, atau menghapus temuan.

Audiens dan tujuan di atas dikonfirmasi pengguna; rincian pembatasan admin dicocokkan dengan implementasi dan `test/admin_read_only_test.dart`.

## Product Purpose

ELSAFE (Electricity Safe) membantu pencatatan, pemantauan, dan tindak lanjut potensi bahaya listrik. Keberhasilan utamanya adalah temuan terdokumentasi dan tindak lanjutnya dapat dipantau oleh pihak yang memiliki hak akses.

Catatan temuan menghubungkan lokasi, foto bukti, kategori risiko, status, serta wilayah ULP agar informasi lapangan dapat ditinjau dalam satu alur.

## Operating Context

- Petugas menggunakan data wilayah ULP sebagai konteks pekerjaannya; admin memerlukan pemantauan lintas ULP.
- Alur masuk yang ditampilkan saat ini menggunakan Google, kemudian pemilihan ULP bila profil belum memilikinya.
- Pengguna mengakses ringkasan dashboard, daftar temuan, pencarian/filter, detail, peta, dan notifikasi.
- Pencatatan temuan mendukung lokasi manual, GPS atau pemilihan titik di peta, foto, informasi jaringan listrik, dan penilaian risiko.
- Formulir memuat tahap Temuan, Reminder, Closing, serta Sosialisasi. Pertahankan aturan kelengkapan dan transisi yang berlaku dalam implementasi saat mengubah antarmuka.
- Ekspor PDF dan Excel mendukung penggunaan data laporan di luar aplikasi.
- Bahasa antarmuka yang ada adalah Bahasa Indonesia, dengan istilah operasional seperti ULP, penyulang, section, zona, Reminder, dan Closing.

## Capabilities and Constraints

- Dua tipe temuan utama: KMU (Kecelakaan Masyarakat Umum) dan ROW (Right of Way), dalam konteks pencatatan potensi bahaya.
- Hak akses mengikuti peran serta profil pengguna. Desain harus mempertahankan cakupan ULP dan pembatasan operasi yang sudah berlaku.
- Status yang ditangani daftar meliputi Open, On Progress, serta Close/Closed. Nilai kosong atau tidak dikenal tidak boleh ditampilkan seolah temuan sudah selesai.
- Kategori risiko saat ini adalah Medium, High, dan Extreme. Perhitungan mengikuti `lib/config/temuan_types.dart`; panduan tertulis yang berbeda tidak menjadi dasar perubahan rumus.
- Login email/password dan reset password tidak ditawarkan pada layar login saat ini. Keberadaan implementasi lama tidak berarti fitur tersebut sudah menjadi alur pengguna aktif.
- Mode terang/gelap dan tata letak yang menyesuaikan lebar layar sudah tersedia.
- Inisialisasi konteks produk tidak mengubah workflow, autentikasi, hak akses, perhitungan risiko, atau data aplikasi.

## Brand Commitments

Nama produk adalah ELSAFE (Electricity Safe). Repository menyediakan aset identitas ELSAFE, PLN, dan HSSE PLN. Gunakan aset yang tersedia sesuai konteks produk; keberadaannya bukan bukti sertifikasi atau klaim persetujuan kelembagaan tambahan.

## Evidence on Hand

- `lib/widgets/panduan_penggunaan.dart`: penjelasan pengguna, tujuan produk, dan alur penggunaan. Cocokkan rincian dengan kode aktif karena sebagian teks panduan belum mengikuti implementasi terbaru.
- `lib/Screen/main_shell.dart`, `lib/Screen/daftar_temuan.dart`, dan `test/admin_read_only_test.dart`: navigasi serta pembatasan peran pada temuan.
- `lib/Screen/temuan.dart`, `lib/Screen/edit_temuan.dart`, dan `lib/config/temuan_model.dart`: formulir dan data temuan/tindak lanjut.
- `lib/config/temuan_types.dart`: istilah tipe, perhitungan risiko, dan daftar penyulang per ULP.
- `lib/Screen/export_temuan.dart`, `lib/utils/pdf_generator.dart`, dan `lib/utils/excel_generator.dart`: fasilitas ekspor.
- `assets/LOGO_ELSAFE.png`, `assets/Logo_PLN.png`, `assets/Logo_HSSE_PLN.png`, dan `assets/Logo_Resmi_HSSE_PLN.png`: aset identitas yang tersedia.
- `docs/CODEX_HANDOFF.md`: riwayat keputusan dan pemeriksaan UI; status build, tes, dan deployment di dalamnya adalah catatan historis, bukan verifikasi terkini.

## Product Principles

1. Utamakan kelengkapan informasi temuan dan keterlacakan tindak lanjut.
2. Pertahankan batas peran dan cakupan wilayah pada setiap alur.
3. Sajikan status serta risiko secara akurat; jangan menyamakan data tidak diketahui dengan kondisi selesai.
4. Dukung pekerjaan petugas dan pemantauan admin pada layar ponsel maupun desktop.
5. Pertahankan istilah operasional agar data yang dicatat dan ditinjau tetap konsisten.

## Open Decisions

- Target native di luar web responsif belum ditetapkan.
- Kebutuhan aksesibilitas khusus atau standar kepatuhan belum ditentukan pengguna. Dukungan ukuran layar dan pembesaran teks yang sudah tersedia tetap perlu dijaga.
- Dukungan offline, SLA, ukuran keberhasilan kuantitatif, dan klaim pembeda terhadap produk lain belum dikonfirmasi.
- Tidak ada klaim sertifikasi, testimoni, atau hasil peningkatan keselamatan yang dikonfirmasi dalam init ini.
