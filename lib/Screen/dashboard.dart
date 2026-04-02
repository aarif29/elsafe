import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../profil/loginscreen.dart';
import '../profil/profil.dart';
import '../config/temuan_service.dart';
import '../config/temuan_model.dart';
import 'temuan.dart';
import 'daftar_temuan.dart';
import 'maps_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _temuanService = TemuanService();
  int _currentIndex = 0;
  int _totalTemuan = 0;
  int _temuanBulanIni = 0;
  String _userName = 'User';
  bool _isLoading = true;
  List<TemuanModel> _recentTemuan = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user profile
      final profile = await _temuanService.getCurrentUserProfile();
      if (profile != null) {
        setState(() {
          _userName = profile['full_name'] ?? 
                      profile['nip'] ?? 
                      _temuanService.currentUserEmail?.split('@')[0] ?? 
                      'User';
        });
      }

      // Get all temuan
      final allTemuan = await _temuanService.getAllTemuanSilent();
      if (allTemuan['success']) {
        final temuanList = allTemuan['data'] as List<TemuanModel>;
        final now = DateTime.now();
        
        setState(() {
          _totalTemuan = temuanList.length;
          _temuanBulanIni = temuanList.where((temuan) {
            final tanggal = temuan.tanggalTemuan;
            return tanggal.month == now.month && tanggal.year == now.year;
          }).length;
          _recentTemuan = temuanList.take(3).toList();
        });
      }
    } catch (e) {
      print('Error loading dashboard: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Apakah Anda yakin ingin keluar?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client.auth.signOut();
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout Gagal: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showMapsView(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MapsViewWidget(),
    );
  }

  void _navigateToDaftarTemuan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DaftarTemuanScreen()),
    ).then((_) => _loadDashboardData());
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Profile()),
    ).then((_) => _loadDashboardData());
  }

  void _navigateToTambahTemuan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TemuanScreen()),
    ).then((result) {
      if (result == true) {
        _loadDashboardData();
      }
    });
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Dashboard - sudah di sini
        break;
      case 1:
        _navigateToDaftarTemuan(context);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _currentIndex = 0;
            });
          }
        });
        break;
      case 2:
        _showMapsView(context);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _currentIndex = 0;
            });
          }
        });
        break;
      case 3:
        _navigateToProfile(context);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _currentIndex = 0;
            });
          }
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _isLoading 
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: Colors.blue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),

                    // Statistics Cards
                    _buildStatisticsCards(),
                    const SizedBox(height: 20),

                    // Recent Activity
                    _buildRecentActivity(),
                    const SizedBox(height: 20),

                    // Info Section
                    _buildInfoSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting = 'Selamat Pagi';
    IconData greetingIcon = Icons.wb_sunny;
    Color gradientStart = const Color(0xFF1E88E5);
    Color gradientEnd = const Color(0xFF1565C0);
    
    if (hour >= 12 && hour < 15) {
      greeting = 'Selamat Siang';
      greetingIcon = Icons.wb_sunny_outlined;
      gradientStart = const Color(0xFFFFA726);
      gradientEnd = const Color(0xFFFF6F00);
    } else if (hour >= 15 && hour < 18) {
      greeting = 'Selamat Sore';
      greetingIcon = Icons.wb_twilight;
      gradientStart = const Color(0xFFFF7043);
      gradientEnd = const Color(0xFFE64A19);
    } else if (hour >= 18 || hour < 5) {
      greeting = 'Selamat Malam';
      greetingIcon = Icons.nightlight_round;
      gradientStart = const Color(0xFF5E35B1);
      gradientEnd = const Color(0xFF311B92);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(greetingIcon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                greeting,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Selamat datang di ELSAFE!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Temuan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Temuan',
                value: _totalTemuan.toString(),
                icon: Icons.inventory_2,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Bulan Ini',
                value: _temuanBulanIni.toString(),
                icon: Icons.calendar_today,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas Terkini',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_recentTemuan.isNotEmpty)
              TextButton(
                onPressed: () => _navigateToDaftarTemuan(context),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _recentTemuan.isEmpty
            ? _buildEmptyState()
            : Column(
                children: _recentTemuan.map((temuan) {
                  return _buildRecentTemuanCard(temuan);
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: Colors.grey[600], size: 64),
          const SizedBox(height: 16),
          Text(
            'Belum ada temuan',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + di bawah untuk\nmenambah temuan pertama Anda',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTemuanCard(TemuanModel temuan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToDaftarTemuan(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temuan.namaPemilik,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        temuan.lokasi,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${temuan.tanggalTemuan.day}/${temuan.tanggalTemuan.month}/${temuan.tanggalTemuan.year}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.security,
                title: 'ELSAFE',
                subtitle: 'Electricity Safe',
                color: Colors.blue,
              ),
              const Divider(color: Colors.grey, height: 24),
              _buildInfoRow(
                icon: Icons.lightbulb_outline,
                title: 'Tips',
                subtitle: 'Selalu update lokasi temuan dengan akurat',
                color: Colors.amber,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DRAWER (MENU SEKUNDER) ====================
  
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header dengan info user
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 28, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _temuanService.currentUserEmail ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Section: PENGATURAN
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              'PENGATURAN',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur Notifikasi (Coming Soon)'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Pengaturan Aplikasi',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur Pengaturan (Coming Soon)'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          // ❌ MENU BAHASA DIHAPUS

          const Divider(color: Colors.grey, height: 24, indent: 16, endIndent: 16),

          // Section: BANTUAN
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Text(
              'BANTUAN',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.help_outline,
            title: 'Panduan Penggunaan',
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog(context);
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.contact_support_outlined,
            title: 'Hubungi Kami',
            onTap: () {
              Navigator.pop(context);
              _showContactDialog(context);
            },
          ),

          const Divider(color: Colors.grey, height: 24, indent: 16, endIndent: 16),

          // Section: AKUN
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Text(
              'AKUN',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          _buildDrawerItem(
            context,
            icon: Icons.lock_outline,
            title: 'Ganti Password',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur Ganti Password (Coming Soon)'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              _handleLogout(context);
            },
          ),

          // Footer
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  'Electricity Safe',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'made with ♥ by M. Arif Trianto',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.white,
          fontSize: 13,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // ==================== DIALOG FUNCTIONS ====================
  
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.help_outline, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Panduan ELSAFE', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cara menggunakan aplikasi:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildHelpItem('Tap tombol + untuk menambah temuan baru'),
              _buildHelpItem('Gunakan GPS atau pilih lokasi dari peta'),
              _buildHelpItem('Lihat semua temuan di menu Daftar'),
              _buildHelpItem('Lihat peta lokasi temuan di menu Peta'),
              _buildHelpItem('Edit atau hapus temuan dari daftar'),
              _buildHelpItem('Swipe down untuk refresh data'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti', style: TextStyle(color: Colors.blue, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info_outline, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Tentang ELSAFE', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Electricity Safe',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aplikasi untuk mengelola data temuan potensi bahaya dengan sistem tracking lokasi berbasis GPS.',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey),
            const SizedBox(height: 12),
            _buildAboutItem('Versi', '1.0.0'),
            _buildAboutItem('Developer', 'M. Arif Trianto - Tumpang'),
            _buildAboutItem('Tahun', '2025'),
            _buildAboutItem('Platform', 'Android'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.blue, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.contact_support_outlined, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Hubungi Kami', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Butuh bantuan? Hubungi kami melalui:',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            const SizedBox(height: 20),
            _buildContactItem(Icons.email, 'Email', 'k3ltumpang@gmail.com'),
            const SizedBox(height: 12),
            _buildContactItem(Icons.phone, 'Telepon', '085155177829'),
            const SizedBox(height: 12),
            _buildContactItem(Icons.location_on, 'Alamat', 'Malang, Indonesia'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.blue, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ❌ FUNCTION _showLanguageDialog DIHAPUS

  // ==================== BOTTOM NAVIGATION (MENU UTAMA) ====================
  
  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _navigateToTambahTemuan(context),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        tooltip: 'Tambah Temuan',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onBottomNavTap,
      backgroundColor: Colors.grey[900],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Daftar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Peta',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
