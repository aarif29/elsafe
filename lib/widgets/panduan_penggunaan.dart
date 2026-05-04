import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class PanduanPenggunaanScreen extends StatelessWidget {
  const PanduanPenggunaanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
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
                'ELSAFE (Electrical Safety) adalah aplikasi untuk mengelola temuan inspeksi keselamatan listrik. Aplikasi ini membantu pengguna mencatat, memantau, dan menyelesaikan temuan bahaya listrik di berbagai lokasi.',
          ),
          _buildSection(
            context,
            icon: Icons.login,
            title: 'Login & Pemilihan ULP',
            content:
                '1. Masukkan email dan password yang telah terdaftar.\n'
                '2. Untuk peran Petugas, pilih Unit Layanan Pengadaan (ULP) tempat Anda bertugas setelah login.\n'
                '3. Admin dapat mengakses semua data tanpa pemilihan ULP.',
          ),
          _buildSection(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            content:
                'Dashboard menampilkan statistik temuan secara real-time:\n'
                '• Total Temuan: Jumlah keseluruhan temuan\n'
                '• Open: Temuan yang belum diselesaikan\n'
                '• Closed: Temuan yang telah diselesaikan\n'
                '• Filter berdasarkan Kategori Risiko (Medium, High, Extreme)\n'
                '• Filter berdasarkan Tipe Temuan (KMU - Kelainan Menyimpang Umum, ROW - Risk of Work)',
          ),
          _buildSection(
            context,
            icon: Icons.list_alt,
            title: 'Daftar Temuan',
            content:
                'Menu Daftar Temuan berfungsi untuk melihat dan mengelola semua temuan:\n'
                '• Melihat daftar lengkap semua temuan\n'
                '• Filter berdasarkan ULP (hanya untuk Admin)\n'
                '• Filter berdasarkan Status (Open/Closed)\n'
                '• Filter berdasarkan Tipe (KMU/ROW)\n'
                '• Filter berdasarkan Kategori Risiko\n'
                '• Pencarian berdasarkan nama, lokasi, atau deskripsi\n'
                '• Tap item untuk melihat detail\n'
                '• Edit atau hapus temuan dari menu actions',
          ),
          _buildSection(
            context,
            icon: Icons.map,
            title: 'Peta (Maps View)',
            content:
                'Peta menampilkan lokasi temuan secara visual:\n'
                '• Lihat semua lokasi temuan pada peta interaktif\n'
                '• Filter berdasarkan Status (Open/Closed)\n'
                '• Tap marker untuk melihat detail temuan\n'
                '•Marker menunjukkan kategori risiko dengan warna berbeda',
          ),
          _buildSection(
            context,
            icon: Icons.add_circle,
            title: 'Buat Temuan Baru',
            content:
                'Cara menambah temuan baru:\n'
                '1. Tap tombol (+) pada bagian bawah layar\n'
                '2. Isi Nama Temuan (identifikasi temuan)\n'
                '3. Pilih Lokasi:\n'
                '   • Gunakan GPS untuk lokasi otomatis\n'
                '   • Atau pilih lokasi dari peta\n'
                '4. Pilih Kategori Risiko:\n'
                '   • Medium - Risiko rendah\n'
                '   • High - Risiko tinggi\n'
                '   • Extreme - Risiko sangat tinggi\n'
                '5. Pilih Tipe Temuan:\n'
                '   • KMU (Kelainan Menyimpang Umum)\n'
                '   • ROW (Risk of Work)\n'
                '6. Isi Deskripsi pendukung\n'
                '7. Upload Foto bukti temuan\n'
                '8. Tap Simpan untuk menyimpan',
          ),
          _buildSection(
            context,
            icon: Icons.notifications,
            title: 'Notifikasi',
            content:
                'Notifikasi berfungsi untuk memberi tahu pengguna tentang informasi penting:\n'
                '• Admin menerima notifikasi ketika ada temuan baru yang perlu ditinjau\n'
                '• Petugas tidak menerima notifikasi untuk fokus pada tugas lapangan\n'
                '• Notifikasi dapat diakses di tab Notifikasi pada menu bawah\n'
                '• Tap notifikasi untuk melihat detail',
          ),
          _buildSection(
            context,
            icon: Icons.person,
            title: 'Profil & Pengaturan',
            content:
                'Menu Profil dan Pengaturan:\n'
                '• Profil: Melihat nama, email, dan role pengguna\n'
                '• Pengaturan Aplikasi:\n'
                '  - Dark Mode: Mengaktifkan tema gelap\n'
                '  - Notifikasi: Mengaktifkan/mematikan notifikasi\n'
                '• Logout: Keluar dari aplikasi',
          ),
          _buildSection(
            context,
            icon: Icons.admin_panel_settings,
            title: 'Peran Pengguna',
            content:
                'Terdapat dua peran dalam aplikasi:\n'
                '• Admin:\n'
                '  - Dapat melihat semua data dari semua ULP\n'
                '  - Menerima notifikasi temuan baru\n'
                '  - Dapat filter data berdasarkan ULP manapun\n'
                '• Petugas/ULP:\n'
                '  - Hanya melihat data ULP tempat bertugas\n'
                '  - Tidak menerima notifikasi\n'
                '  - Data difilter otomatis berdasarkan ULP session',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Geser ke bawah untuk refresh data di setiap halaman.',
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
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