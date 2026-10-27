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
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth <
                320 * MediaQuery.textScalerOf(context).scale(1);
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
                    icon: Icons.inventory_2,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _StatCard(
                    title: 'Bulan Ini',
                    value: temuanBulanIni.toString(),
                    icon: Icons.calendar_today,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                icon,
                color: context.isDark ? color.shade300 : color.shade800,
                size: 20,
              ),
              Text(
                title,
                style: TextStyle(color: context.textSecondary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
