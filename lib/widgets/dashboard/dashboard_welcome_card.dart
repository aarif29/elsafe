import 'package:flutter/material.dart';

class DashboardWelcomeCard extends StatelessWidget {
  final String userName;

  const DashboardWelcomeCard({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
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
            color: gradientStart.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kiri: greeting + tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(greetingIcon, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      greeting,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Selamat datang di ELSAFE!',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Kanan: nama user
          Expanded(
            child: Text(
              userName,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
