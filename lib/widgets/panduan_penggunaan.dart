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
                '1. Masukkan email dan password yang telah terdaftar.\n'
                '2. Setelah login, petugas memilih ULP (Unit Layanan Pelanggan) sesuai wilayah tugas.\n'
                '3. Data petugas akan mengikuti ULP yang dipilih.\n'
                '4. Admin dapat melihat data lintas ULP dan meninjau data pengguna.',
          ),
          _buildSection(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            content:
                'Dashboard menampilkan ringkasan kondisi temuan:\n'
                '- Total temuan yang tersedia untuk akun Anda\n'
                '- Jumlah temuan pada bulan berjalan\n'
                '- Aktivitas atau temuan terbaru\n'
                '- Informasi singkat terkait keselamatan dan pemantauan temuan\n'
                'Gunakan tombol refresh di app bar untuk memuat ulang data.',
          ),
          _buildSection(
            context,
            icon: Icons.list_alt,
            title: 'Daftar Temuan',
            content:
                'Menu Daftar Temuan berfungsi untuk melihat dan mengelola temuan:\n'
                '- Melihat daftar temuan yang sesuai hak akses akun\n'
                '- Pencarian berdasarkan nama, lokasi, deskripsi, atau pembuat data\n'
                '- Filter status Open/Close\n'
                '- Filter tipe KMU atau ROW\n'
                '- Filter kategori risiko Medium, High, atau Extreme\n'
                '- Filter ULP tersedia untuk admin\n'
                '- Buka detail temuan, edit data, hapus data, atau buka lokasi di Google Maps.',
          ),
          _buildSection(
            context,
            icon: Icons.map,
            title: 'Peta (Maps View)',
            content:
                'Peta menampilkan lokasi temuan secara visual:\n'
                '- Lihat lokasi temuan pada peta interaktif\n'
                '- Tap marker untuk melihat informasi temuan\n'
                '- Gunakan peta untuk membantu validasi posisi temuan di lapangan\n'
                '- Marker membantu membedakan lokasi temuan yang tercatat.',
          ),
          _buildSection(
            context,
            icon: Icons.add_circle,
            title: 'Buat Temuan Baru',
            content:
                'Cara menambah temuan baru:\n'
                '1. Tap tombol (+) pada bagian bawah layar\n'
                '2. Pilih tipe temuan: KMU (Kecelakaan Masyarakat Umum) atau ROW (Right of Way)\n'
                '3. Isi nama temuan dan deskripsi pendukung\n'
                '4. Isi lokasi secara manual, gunakan lokasi GPS saat ini, atau pilih titik dari peta\n'
                '5. Upload foto temuan sebagai bukti lapangan\n'
                '6. Lengkapi matriks risiko untuk menentukan level Medium, High, atau Extreme\n'
                '7. Jika tersedia, tambahkan foto surat tanda terima, data tindak lanjut, dan foto sosialisasi\n'
                '8. Tap Simpan Temuan untuk menyimpan data.',
          ),
          _buildSection(
            context,
            icon: Icons.notifications,
            title: 'Notifikasi',
            content:
                'Notifikasi berfungsi untuk memberi tahu pengguna tentang informasi penting:\n'
                '- Notifikasi dapat diakses dari tab Notifikasi atau dari AppDrawer\n'
                '- Badge menampilkan jumlah notifikasi yang belum dibaca\n'
                '- Tap notifikasi untuk membuka detail temuan terkait\n'
                '- Gunakan fitur ini untuk memantau temuan baru atau pembaruan data penting.',
          ),
          _buildSection(
            context,
            icon: Icons.person,
            title: 'Profil & Pengaturan',
            content:
                'Menu Profil dan Pengaturan:\n'
                '- Profil menampilkan informasi akun seperti nama, email, role, dan ULP\n'
                '- Mode terang/gelap dapat diganti dari tombol tema di dashboard atau pengaturan aplikasi\n'
                '- AppDrawer menyediakan akses ke Panduan Penggunaan, Tentang Aplikasi, Hubungi Kami, dan Logout\n'
                '- Logout digunakan untuk keluar dari akun aktif.',
          ),
          _buildSection(
            context,
            icon: Icons.admin_panel_settings,
            title: 'Peran Pengguna',
            content:
                'Terdapat dua peran dalam aplikasi:\n'
                '- Admin dapat melihat data dari semua ULP, memakai filter ULP, dan meninjau data secara lebih luas\n'
                '- Petugas melihat data sesuai ULP (Unit Layanan Pelanggan) tempat bertugas\n'
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
