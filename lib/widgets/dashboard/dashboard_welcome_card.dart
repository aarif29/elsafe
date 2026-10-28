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

    return Text(
      '$greeting, $userName',
      style: TextStyle(
        color: context.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    );
  }
}
