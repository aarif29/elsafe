import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:elsafe/screen/loginscreen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      
      // Navigasi kembali ke LoginScreen setelah logout
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      // Handle error jika ada
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout Gagal: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Selamat Datang di Halaman Utama!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
