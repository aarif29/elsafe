import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class DashboardWelcomeCard extends StatelessWidget {
  final String userName;

  const DashboardWelcomeCard({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = switch (hour) {
      >= 5 && < 12 => 'Selamat Pagi',
      >= 12 && < 15 => 'Selamat Siang',
      >= 15 && < 18 => 'Selamat Sore',
      _ => 'Selamat Malam',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Colors.white, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  userName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
