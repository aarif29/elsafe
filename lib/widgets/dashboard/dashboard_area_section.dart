import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import 'dashboard_overview.dart';

class DashboardAreaSection extends StatelessWidget {
  final DashboardOverview overview;
  final bool groupByUlp;

  const DashboardAreaSection({
    super.key,
    required this.overview,
    required this.groupByUlp,
  });

  @override
  Widget build(BuildContext context) {
    final areas =
        overview.openByArea.entries.toList()..sort((a, b) {
          final count = b.value.compareTo(a.value);
          return count != 0 ? count : a.key.compareTo(b.key);
        });
    final visible = areas.take(5).toList();
    final maxCount = visible.isEmpty ? 1 : visible.first.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          groupByUlp ? 'Temuan Open per ULP' : 'Temuan Open per penyulang',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          groupByUlp
              ? 'Wilayah dengan temuan yang masih Open'
              : 'Penyulang dengan temuan yang masih Open',
          style: TextStyle(color: context.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          Text(
            'Belum ada sebaran temuan Open.',
            style: TextStyle(color: context.textSecondary, fontSize: 14),
          )
        else
          for (final area in visible) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    area.key,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${area.value}',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: area.value / maxCount,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: context.subtleSurface,
              semanticsLabel: '${area.key}: ${area.value} temuan Open',
            ),
            const SizedBox(height: 16),
          ],
        if (areas.length > visible.length)
          Text(
            '+${areas.length - visible.length} wilayah lainnya',
            style: TextStyle(color: context.textSecondary, fontSize: 12),
          ),
      ],
    );
  }
}
