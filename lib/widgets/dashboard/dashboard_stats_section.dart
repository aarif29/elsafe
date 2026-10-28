import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class DashboardStatsSection extends StatelessWidget {
  final int totalTemuan;
  final int temuanBulanIni;

  const DashboardStatsSection({
    super.key,
    required this.totalTemuan,
    required this.temuanBulanIni,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Temuan',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth <
                340 * MediaQuery.textScalerOf(context).scale(1);
            final width =
                stacked
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: _StatCard(
                    title: 'Total Temuan',
                    value: totalTemuan.toString(),
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _StatCard(
                    title: 'Bulan Ini',
                    value: temuanBulanIni.toString(),
                    icon: Icons.calendar_month_outlined,
                    color: Colors.orange,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final MaterialColor color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: context.isDark ? color.shade300 : color.shade800,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
