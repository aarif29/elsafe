import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import 'dashboard_overview.dart';

class DashboardStatsSection extends StatelessWidget {
  final DashboardOverview overview;

  const DashboardStatsSection({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked =
              constraints.maxWidth <
              520 * MediaQuery.textScalerOf(context).scale(1);
          final headline = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Belum ditindaklanjuti',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Semantics(
                label: 'Temuan Open: ${overview.openCount}',
                excludeSemantics: true,
                child: Text(
                  '${overview.openCount}',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 44,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Temuan berstatus Open',
                style: TextStyle(color: context.textSecondary, fontSize: 13),
              ),
            ],
          );
          final typeBreakdown = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tipe temuan Open',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _TypeRow(
                label: 'KMU',
                count: overview.openKmu,
                total: overview.openCount,
                color: scheme.primary,
              ),
              const SizedBox(height: 12),
              _TypeRow(
                label: 'ROW',
                count: overview.openRow,
                total: overview.openCount,
                color: scheme.tertiary,
              ),
              if (overview.openOtherType > 0) ...[
                const SizedBox(height: 10),
                Text(
                  '${overview.openOtherType} temuan belum memiliki tipe',
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
              ],
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headline,
                const SizedBox(height: 20),
                Divider(height: 1, color: context.borderColor),
                const SizedBox(height: 18),
                typeBreakdown,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: headline),
              const SizedBox(width: 28),
              Expanded(child: typeBreakdown),
            ],
          );
        },
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _TypeRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: context.textPrimary, fontSize: 14),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: total == 0 ? 0 : count / total,
          minHeight: 7,
          borderRadius: BorderRadius.circular(4),
          color: color,
          backgroundColor: context.subtleSurface,
          semanticsLabel: '$label: $count dari $total temuan Open',
        ),
      ],
    );
  }
}
