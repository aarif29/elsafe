import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../profil/loginscreen.dart';
import '../profil/profil.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 80, 
              decoration: const BoxDecoration(color: Colors.blue),
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
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop(); 
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
            ),
          ],
        ),
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
