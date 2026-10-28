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
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth <
            280 * MediaQuery.textScalerOf(context).scale(1);
        final width =
            stacked ? constraints.maxWidth : (constraints.maxWidth - 24) / 2;
        return Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            SizedBox(
              width: width,
              child: _Statistic(label: 'Total Temuan', value: totalTemuan),
            ),
            SizedBox(
              width: width,
              child: _Statistic(label: 'Bulan Ini', value: temuanBulanIni),
            ),
          ],
        );
      },
    );
  }
}

class _Statistic extends StatelessWidget {
  final String label;
  final int value;

  const _Statistic({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: context.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
