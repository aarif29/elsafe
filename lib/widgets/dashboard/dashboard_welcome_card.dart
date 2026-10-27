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
      padding: const EdgeInsets.all(16),
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
          Icon(greetingIcon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
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
