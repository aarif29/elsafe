import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Aplikasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'TAMPILAN',
              style: TextStyle(
                color: context.textHint,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor),
              ),
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeService.instance.themeMode,
                builder: (context, mode, _) {
                  return Column(
                    children: [
                      _ThemeOption(
                        icon: Icons.dark_mode_outlined,
                        title: 'Gelap',
                        subtitle: 'Nyaman di kondisi gelap / mode hemat daya',
                        selected: mode == ThemeMode.dark,
                        onTap: () => ThemeService.instance.setTheme(ThemeMode.dark),
                        isFirst: true,
                      ),
                      Divider(height: 1, color: context.borderColor, indent: 16, endIndent: 16),
                      _ThemeOption(
                        icon: Icons.light_mode_outlined,
                        title: 'Terang',
                        subtitle: 'Cocok untuk penggunaan di luar ruangan',
                        selected: mode == ThemeMode.light,
                        onTap: () => ThemeService.instance.setTheme(ThemeMode.light),
                        isFirst: false,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool isFirst;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isFirst ? Radius.zero : const Radius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.blue.withValues(alpha: 0.15)
                    : context.subtleSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.blue : context.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? const Icon(Icons.check_circle, color: Colors.blue, size: 22, key: ValueKey('check'))
                  : SizedBox(
                      width: 22,
                      height: 22,
                      child: Icon(Icons.circle_outlined, color: context.borderColor, size: 22, key: const ValueKey('empty')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
