import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class PanduanPenggunaanScreen extends StatelessWidget {
  final VoidCallback onBack;

  const PanduanPenggunaanScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: onBack,
        ),
        title: Text(
          'Panduan Penggunaan',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            icon: Icons.info_outline,
            title: 'Pendahuluan',
            content:
                'ELSAFE (Electricity Safe) adalah aplikasi untuk mencatat, memantau, dan menindaklanjuti temuan potensi bahaya listrik. Aplikasi ini mendukung pencatatan lokasi, foto bukti, kategori risiko, status temuan, serta pemantauan data berdasarkan ULP.',
          ),
          _buildSection(
            context,
            icon: Icons.login,
            title: 'Login & Pemilihan ULP',
            content:
                '1. Tap "Masuk dengan Google", lalu pilih akun Google Anda.\n'
                '2. Jika ULP belum disetel, pilih ULP (Unit Layanan Pelanggan) sesuai wilayah tugas.\n'
                '3. Data petugas akan mengikuti ULP yang dipilih.\n'
                '4. Admin dapat melihat temuan lintas ULP dan meninjau permintaan ganti ULP.',
          ),
          _buildSection(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            content:
                'Dashboard menampilkan ringkasan kondisi temuan:\n'
                '- Total temuan yang tersedia untuk akun Anda\n'
                '- Jumlah temuan yang ditemukan pada bulan berjalan\n'
                '- Temuan terbaru: tap kartu untuk membuka dialog detail, atau tap Lihat Semua untuk membuka Daftar Temuan\n'
                '- Informasi singkat terkait keselamatan dan pemantauan temuan\n'
                'Gunakan tombol refresh di app bar untuk memuat ulang data.',
          ),
          _buildSection(
            context,
            icon: Icons.list_alt,
            title: 'Daftar Temuan',
            content:
                'Menu Daftar Temuan berfungsi untuk melihat dan mengelola temuan:\n'
                '- Cari berdasarkan nama pemilik, lokasi, atau deskripsi\n'
                '- Filter status Open/On Progress/Closed, tipe KMU/ROW, level risiko, dan penyulang; filter ULP tersedia untuk admin\n'
                '- Tap kartu temuan untuk membuka dialog detail. Di sana Anda dapat melihat tanggal ditemukan, foto, dan koordinat serta membuka Maps atau menyalin koordinat\n'
                '- Petugas dapat mengedit dari dialog detail atau tombol pada kartu. Tombol Hapus ada pada kartu daftar dan meminta konfirmasi; admin hanya dapat melihat data\n\n'
                'Menutup temuan:\n'
                '1. Buka detail, lalu tap Edit.\n'
                '2. Buka Step 3: Closing dan pilih Jenis Closing (PFK atau Preventif). Isi tanggal dan foto tindak lanjut jika tersedia.\n'
                '3. Simpan perubahan. Status menjadi Closed otomatis; tidak ada field Status untuk diubah langsung.',
          ),
          _buildSection(
            context,
            icon: Icons.map,
            title: 'Peta (Maps View)',
            content:
                'Peta menampilkan lokasi temuan secara visual:\n'
                '- Lihat lokasi temuan pada peta interaktif\n'
                '- Tap marker untuk melihat informasi temuan pada panel detail\n'
                '- Gunakan filter status, tipe, risiko, dan penyulang; admin juga dapat memfilter ULP\n'
                '- Gunakan peta untuk membantu validasi posisi temuan di lapangan\n'
                '- Marker membantu membedakan lokasi temuan yang tercatat.',
          ),
          _buildSection(
            context,
            icon: Icons.add_circle,
            title: 'Buat Temuan Baru',
            content:
                'Petugas dapat membuat temuan dari tombol (+) di tab Dashboard atau Daftar:\n'
                '1. Pilih tipe potensi bahaya KMU atau ROW.\n'
                '2. Di Step 1: Temuan, isi lokasi (manual, GPS, atau pilih titik peta), nama pemilik, nomor HP, Tanggal Temuan, deskripsi, dan foto bukti.\n'
                '3. Tanggal Temuan adalah tanggal bahaya ditemukan, bukan tanggal data dimasukkan. Pilih tanggal sebenarnya meski baru bisa mengisi temuan di lain waktu.\n'
                '4. Lengkapi matriks risiko dari jarak aktivitas, intensitas, jenis objek, jenis aset, dan lokasi objek. Level Medium/High/Extreme dihitung otomatis.\n'
                '5. Step 2: Reminder bersifat opsional; isi tanggal reminder dan foto surat tanda terima jika sudah mengingatkan pemilik.\n'
                '6. Step 3: Closing bersifat opsional; jika tindak lanjut sudah selesai, pilih jenis closing dan tambahkan tanggal serta foto tindak lanjut jika tersedia. Temuan menjadi Closed saat disimpan.\n'
                '7. Lanjutkan sampai akhir form dan tap Simpan Temuan. Step 4: Sosialisasi baru dapat diisi setelah temuan tersimpan dan di-closing.',
          ),
          _buildSection(
            context,
            icon: Icons.record_voice_over_outlined,
            title: 'Sosialisasi Setelah Closing',
            content:
                'Sosialisasi dicatat setelah temuan disimpan dan di-closing:\n'
                '1. Buka temuan yang data Closing-nya sudah disimpan, lalu tap Edit.\n'
                '2. Buka Step 4: Sosialisasi, pilih tanggal, dan tambahkan foto sosialisasi.\n'
                '3. Simpan perubahan. Jika closing baru saja diisi, simpan dulu lalu buka kembali Edit agar form sosialisasi tersedia.\n'
                'Sosialisasi dapat ditambahkan kembali secara berkala meski temuan sudah Closed.',
          ),
          _buildSection(
            context,
            icon: Icons.notifications,
            title: 'Notifikasi',
            content:
                'Buka tab Notifikasi untuk melihat pengingat tindak lanjut dan informasi perubahan ULP:\n'
                '- Badge menampilkan jumlah notifikasi yang belum dibaca\n'
                '- Pengingat muncul untuk temuan Open yang belum di-closing saat mencapai 19 hari sejak Tanggal Reminder. Jumlah hari pada kartu mengikuti hari saat ditampilkan\n'
                '- Tap pengingat temuan untuk membuka dialog detail; petugas dapat melanjutkan ke Edit dari sana\n'
                '- Persetujuan ganti ULP juga muncul di sini. Notifikasi tanpa temuan terkait hanya ditandai sudah dibaca saat ditap\n'
                '- Gunakan Tandai semua dibaca atau tombol muat ulang sesuai kebutuhan.',
          ),
          _buildSection(
            context,
            icon: Icons.file_download_outlined,
            title: 'Export Data',
            content:
                'Dari Daftar Temuan, tap ikon Export Data di app bar:\n'
                '1. Atur filter tanggal, status, level risiko, jenis temuan, atau filter lanjutan seperti penyulang. Admin juga dapat memilih ULP.\n'
                '2. Tap Terapkan Filter. Semua hasil otomatis terpilih; hilangkan centang pada data yang tidak ingin diekspor.\n'
                '3. Tap Preview PDF untuk memeriksa isi, lalu pilih Export PDF atau Export Excel.\n'
                '4. Tap Kembali untuk kembali ke Daftar Temuan.',
          ),
          _buildSection(
            context,
            icon: Icons.person,
            title: 'Profil & Akun',
            content:
                'Menu Profil dan akun:\n'
                '- Profil menampilkan informasi akun seperti nama, email, role, dan ULP\n'
                '- Mode terang/gelap dapat diganti dari tombol tema di app bar Dashboard\n'
                '- Tombol menu di setiap tab utama membuka drawer berisi Panduan Penggunaan, Tentang Aplikasi, Hubungi Kami, Ganti Password (segera hadir), dan Logout\n'
                '- Logout akan menampilkan konfirmasi sebelum keluar dari akun aktif.',
          ),
          _buildSection(
            context,
            icon: Icons.business_outlined,
            title: 'Mengganti ULP',
            content:
                'Petugas tidak dapat langsung mengubah ULP dari Profil:\n'
                '1. Tap Minta Ganti ULP, pilih ULP baru, dan isi alasan jika perlu.\n'
                '2. Tap Kirim Permintaan. Statusnya menunggu persetujuan admin.\n'
                '3. Admin membuka Profil > Kelola Persetujuan ULP untuk menyetujui atau menolak permintaan.\n'
                '4. Jika disetujui, ULP akun berubah dan petugas menerima notifikasi.',
          ),
          _buildSection(
            context,
            icon: Icons.admin_panel_settings,
            title: 'Peran Pengguna',
            content:
                'Terdapat dua peran dalam aplikasi:\n'
                '- Admin dapat melihat dan mengekspor data dari semua ULP serta mengelola persetujuan ganti ULP, tetapi tidak dapat menambah, mengedit, atau menghapus temuan\n'
                '- Petugas melihat dan mengelola temuan sesuai ULP (Unit Layanan Pelanggan) tempat bertugas\n'
                '- Jika ULP belum disetel, aplikasi akan mengarahkan pengguna untuk memilih ULP terlebih dahulu\n'
                '- Hak akses data mengikuti role dan profil pengguna yang tersimpan.',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue[700], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
