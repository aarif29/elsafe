import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../profil/loginscreen.dart';
import '../config/app_logger.dart';
import '../config/app_theme.dart';
import '../config/temuan_service.dart';
import '../config/temuan_model.dart';
import '../widgets/dashboard/dashboard_welcome_card.dart';
import '../widgets/dashboard/dashboard_stats_section.dart';
import '../widgets/dashboard/dashboard_recent_activity.dart';
import '../widgets/dashboard/dashboard_info_section.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onLihatSemua;

  const DashboardScreen({super.key, this.onLihatSemua});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final _temuanService = TemuanService();
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

  void loadData() => _loadDashboardData();

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final profile = await _temuanService.getCurrentUserProfile();
      if (profile != null) {
        setState(() {
          _userName = profile['full_name'] ??
              profile['nip'] ??
              _temuanService.currentUserEmail?.split('@')[0] ??
              'User';
        });
      }

      final allTemuan = await _temuanService.getAllTemuanSilent();
      if (allTemuan['success']) {
        final temuanList = allTemuan['data'] as List<TemuanModel>;
        final now = DateTime.now();
        setState(() {
          _totalTemuan = temuanList.length;
          _temuanBulanIni = temuanList
              .where((t) =>
                  t.tanggalTemuan.month == now.month &&
                  t.tanggalTemuan.year == now.year)
              .length;
          _recentTemuan = temuanList.take(3).toList();
        });
      }
    } catch (e) {
      appLog.e('Error loading dashboard', error: e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout',
            style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin keluar?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Batal', style: TextStyle(color: Colors.grey)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.instance.themeMode,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(mode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                onPressed: () {
                  ThemeService.instance.setTheme(mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
                },
                tooltip: mode == ThemeMode.dark ? 'Mode Terang' : 'Mode Gelap',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue))
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: Colors.blue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardWelcomeCard(userName: _userName),
                    const SizedBox(height: 20),
                    DashboardStatsSection(
                      totalTemuan: _totalTemuan,
                      temuanBulanIni: _temuanBulanIni,
                    ),
                    const SizedBox(height: 20),
                    DashboardRecentActivity(
                      recentTemuan: _recentTemuan,
                      onLihatSemua: widget.onLihatSemua ?? () {},
                    ),
                    const SizedBox(height: 20),
                    const DashboardInfoSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}
