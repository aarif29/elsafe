import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_theme.dart';
import 'dashboard.dart';
import 'daftar_temuan.dart';
import 'notifications_screen.dart';
import '../profil/profil.dart';
import '../widgets/tipe_temuan_picker.dart';
import 'temuan.dart';
import 'maps_view.dart';
import '../config/notification_service.dart';
import '../config/temuan_service.dart';
import '../config/ulp_service.dart';
import '../widgets/panduan_penggunaan.dart';
import '../widgets/dashboard/dashboard_drawer.dart';
import 'export_temuan.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _navIndex = 0;
  bool _showPanduan = false;
  bool _isAdmin = false;
  bool _hasLoadedRole = false;
  final _temuanService = TemuanService();
  final _ulpService = UlpService();
  final _dashboardKey = GlobalKey<DashboardScreenState>();
  final _daftarKey = GlobalKey<DaftarTemuanScreenState>();

  // navIndex: 0=Dashboard, 1=Daftar, 2=Peta(modal), 3=Notifikasi, 4=Profil
  // stackIndex: 0=Dashboard, 1=Daftar, 2=Notifikasi, 3=Profil, 4=Panduan
  int get _stackIndex {
    if (_showPanduan) return 4;
    if (_navIndex == 3) return 2;
    if (_navIndex == 4) return 3;
    return _navIndex;
  }

  void openPanduan() {
    setState(() => _showPanduan = true);
  }

  void closePanduan() {
    setState(() => _showPanduan = false);
  }

  void openNotifications() {
    setState(() {
      _showPanduan = false;
      _navIndex = 3;
    });
  }

  void openExport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExportTemuanScreen()),
    );
  }

  void backToDashboard() {
    setState(() {
      _showPanduan = false;
      _navIndex = 0;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: context.surfaceColor,
            title: Text('Logout', style: TextStyle(color: context.textPrimary)),
            content: Text(
              'Apakah Anda yakin ingin logout?',
              style: TextStyle(color: context.textPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Batal',
                  style: TextStyle(color: context.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
    if (confirm == true && mounted) {
      await Supabase.instance.client.auth.signOut();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.initialize();
      _loadRole();
    });
  }

  Future<void> _loadRole() async {
    final isAdmin = await _ulpService.isAdmin();
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
      _hasLoadedRole = true;
    });
  }

  @override
  void dispose() {
    NotificationService.instance.reset();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 2) {
      setState(() => _showPanduan = false);
      _showMapsView();
      return;
    }
    setState(() {
      _showPanduan = false;
      _navIndex = index;
    });
  }

  void _showMapsView() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapsViewWidget()),
    );
  }

  Future<void> _openTambahTemuan() async {
    final nav = Navigator.of(context);
    final String? tipe = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const TipeTemuanPicker(),
    );
    if (tipe != null && mounted) {
      final result = await nav.push(
        MaterialPageRoute(builder: (_) => TemuanScreen(tipeTemuan: tipe)),
      );
      if (result == true) {
        _dashboardKey.currentState?.loadData();
        _daftarKey.currentState?.loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _temuanService.currentUserEmail ?? '';
    final userName = userEmail.isNotEmpty ? userEmail.split('@')[0] : 'User';

    return Scaffold(
      drawer:
          userEmail.isNotEmpty
              ? DashboardDrawer(
                userName: userName,
                userEmail: userEmail,
                onLogout: _handleLogout,
                onOpenNotifications: openNotifications,
                onOpenPanduan: openPanduan,
                onOpenExport: openExport,
              )
              : null,
      body: IndexedStack(
        index: _stackIndex,
        children: [
          DashboardScreen(
            key: _dashboardKey,
            onLihatSemua: () => setState(() => _navIndex = 1),
          ),
          DaftarTemuanScreen(key: _daftarKey, onOpenExport: openExport),
          NotificationsScreen(onBack: backToDashboard),
          const Profile(),
          PanduanPenggunaanScreen(onBack: closePanduan),
        ],
      ),
      floatingActionButton:
          (_showPanduan || _navIndex == 3 || _navIndex == 4)
              ? null
              : _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget? _buildFab() {
    if (!_hasLoadedRole) return null;
    if (_isAdmin) return null;

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
            color: Colors.blue.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _openTambahTemuan,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        tooltip: 'Tambah Temuan',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildBottomNav() {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationService.instance.unreadCount,
      builder: (context, count, _) {
        return BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: _onNavTap,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Daftar',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Peta'),
            // Tab Notifikasi dengan badge
            BottomNavigationBarItem(
              icon: _buildNotifIcon(count),
              label: 'Notifikasi',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotifIcon(int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined),
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
