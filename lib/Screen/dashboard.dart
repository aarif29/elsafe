import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../profil/loginscreen.dart';
import '../profil/profil.dart';
import 'temuan.dart';
import 'daftar_temuan.dart';
import 'maps_view.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
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
          SnackBar(content: Text('Logout Gagal: ${e.toString()}')),
        );
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
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Profile()),
    );
  }

  void _navigateToTambahTemuan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TemuanScreen()),
    );
  }

  void _closeDrawer(BuildContext context) {
    Navigator.of(context).pop();
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
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: const Center(
        child: Text(
          'Selamat Datang di ELSAFE!',
            style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(color: Colors.grey[800]),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => _closeDrawer(context),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Profil',
            onTap: () {
              _closeDrawer(context);
              _navigateToProfile(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
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

  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.grey[900],
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.list, color: Colors.white),
              onPressed: () => _navigateToDaftarTemuan(context),
              tooltip: 'Daftar Temuan',
            ),
            IconButton(
              icon: const Icon(Icons.map, color: Colors.white),
              onPressed: () => _showMapsView(context),
              tooltip: 'Peta Temuan',
            ),
          ],
        ),
      ),
    );
  }
}


