import 'package:flutter/material.dart';
import '../../Screen/settings_screen.dart';
import '../../Screen/notifications_screen.dart';
import '../../config/app_theme.dart';
import '../../config/notification_service.dart';

class DashboardDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const DashboardDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.surfaceColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
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
                    userName,
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
                    userEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // PENGATURAN
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              'PENGATURAN',
              style: TextStyle(
                color: context.textHint,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          _DrawerItem(
            icon: Icons.settings_outlined,
            title: 'Pengaturan Aplikasi',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: NotificationService.instance.unreadCount,
            builder: (context, count, _) => _DrawerItem(
              icon: Icons.notifications_outlined,
              title: count > 0 ? 'Notifikasi ($count)' : 'Notifikasi',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
            ),
          ),

          Divider(color: context.borderColor, height: 24, indent: 16, endIndent: 16),

          // BANTUAN
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Text(
              'BANTUAN',
              style: TextStyle(
                color: context.textHint,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          _DrawerItem(
            icon: Icons.help_outline,
            title: 'Panduan Penggunaan',
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog(context);
            },
          ),
          _DrawerItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
          _DrawerItem(
            icon: Icons.contact_support_outlined,
            title: 'Hubungi Kami',
            onTap: () {
              Navigator.pop(context);
              _showContactDialog(context);
            },
          ),

          Divider(color: context.borderColor, height: 24, indent: 16, endIndent: 16),

          // AKUN
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Text(
              'AKUN',
              style: TextStyle(
                color: context.textHint,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          _DrawerItem(
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
          _DrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              onLogout();
            },
          ),

          // Footer
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  'Electricity Safe',
                  style: TextStyle(color: context.textDisabled, fontSize: 9),
                ),
                const SizedBox(height: 2),
                Text(
                  'made with ♥ by M. Arif Trianto',
                  style: TextStyle(color: context.textDisabled, fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.help_outline, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Panduan ELSAFE',
                style: TextStyle(color: context.textPrimary, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cara menggunakan aplikasi:',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _helpItem(context, 'Tap tombol + untuk menambah temuan baru'),
              _helpItem(context, 'Gunakan GPS atau pilih lokasi dari peta'),
              _helpItem(context, 'Lihat semua temuan di menu Daftar'),
              _helpItem(context, 'Lihat peta lokasi temuan di menu Peta'),
              _helpItem(context, 'Edit atau hapus temuan dari daftar'),
              _helpItem(context, 'Swipe down untuk refresh data'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti',
                style: TextStyle(color: Colors.blue, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _helpItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(color: context.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info_outline, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Tentang ELSAFE',
                style: TextStyle(color: context.textPrimary, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Electricity Safe',
              style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Aplikasi untuk mengelola data temuan potensi bahaya dengan sistem tracking lokasi berbasis GPS.',
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Divider(color: context.borderColor),
            const SizedBox(height: 12),
            _aboutItem(context, 'Versi', '1.0.0'),
            _aboutItem(context, 'Developer', 'M. Arif Trianto'),
            _aboutItem(context, 'Tahun', '2026'),
            _aboutItem(context, 'Platform', 'Android & Web App'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup',
                style: TextStyle(color: Colors.blue, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _aboutItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: context.textSecondary, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.contact_support_outlined,
                  color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Hubungi Kami',
                style: TextStyle(color: context.textPrimary, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Butuh bantuan? Hubungi kami melalui:',
              style: TextStyle(color: context.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _contactItem(context, Icons.email, 'Email', 'k3ltumpang@gmail.com'),
            const SizedBox(height: 12),
            _contactItem(context, Icons.phone, 'Telepon', '085155177829'),
            const SizedBox(height: 12),
            _contactItem(context, Icons.location_on, 'Alamat', 'Malang, Indonesia'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup',
                style: TextStyle(color: Colors.blue, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _contactItem(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: context.textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(color: context.textPrimary, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? context.textPrimary, size: 20),
      title: Text(
        title,
        style: TextStyle(color: color ?? context.textPrimary, fontSize: 13),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
