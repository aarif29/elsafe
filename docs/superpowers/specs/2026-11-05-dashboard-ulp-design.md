# Dashboard temuan per ULP

## Tujuan

Dashboard membantu petugas melihat potensi bahaya di ULP akunnya: jumlah temuan yang belum ditindaklanjuti, tipe KMU/ROW, sebaran lokasi, dan temuan yang perlu dibuka. Admin melihat semua ULP secara default dan dapat memilih satu ULP.

## Keputusan desain

- "Belum ditindaklanjuti" berarti status `Open` saja. `On Progress`, `Close`/`Closed`, serta status kosong atau tidak dikenal tidak masuk hitungan `Open`.
- Seluruh angka, perbandingan KMU/ROW, grafik sebaran, dan daftar utama menggunakan kumpulan temuan `Open` yang sama. Tipe kosong tetap masuk total `Open`, dengan keterangan tersendiri agar jumlah tetap jujur.
- Saat admin memilih "Semua ULP", sebaran dikelompokkan per ULP. Saat satu ULP dipilih, termasuk pada akun petugas, sebaran dikelompokkan per penyulang. Nilai lokasi yang kosong diberi label tersendiri.
- Tampilkan maksimal lima kelompok lokasi teratas dengan batang horizontal dan angka eksplisit. Daftar temuan `Open` menampilkan risiko, tipe, penyulang/ULP, lokasi, dan tanggal; urutkan risiko Extreme, High, Medium, lainnya, lalu tanggal temuan paling lama.
- Admin memilih ULP dari data yang tersedia; pemilihan hanya mengubah ringkasan dashboard dan tidak mengubah akses, data, atau ULP profil. Petugas tidak melihat pemilih.
- Gunakan gaya dan navigasi ELSAFE yang ada, tata letak responsif, mode terang/gelap, label terbaca, dan keadaan memuat/kosong/gagal yang jelas. Pertahankan tautan ke daftar temuan dan pembukaan detail.

## Batas

- Dashboard menampilkan tipe KMU/ROW saja; rincian jenis objek tetap pada detail temuan.
- Tidak ada perubahan skema, peran, status, rumus risiko, atau aturan tindak lanjut. Query temuan petugas mencakup variasi nama ULP lama dan mengambil data per halaman agar ringkasan tetap lengkap.
- Peta lengkap tetap berada pada tab Peta. Temuan tanpa koordinat tetap dapat terlihat melalui lokasi teks di daftar.

## Pendekatan yang dipertimbangkan

1. **Ringkasan tindakan (dipilih):** angka `Open`, KMU/ROW, sebaran per wilayah, dan daftar temuan. Ringkas di ponsel dan memanfaatkan tab Peta yang ada.
2. **Peta sebagai fokus:** menonjolkan lokasi geografis, tetapi memakan ruang pada ponsel dan tidak mewakili temuan tanpa koordinat.

## Keadaan data

Tangani 0 temuan, 0 temuan `Open`, status/tipe/risiko/lokasi kosong, beberapa ejaan ULP yang setara, pergantian pilihan admin, pemuatan ulang yang gagal dengan data lama, dan teks besar pada layar sempit.
