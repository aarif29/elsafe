import 'package:flutter/material.dart';
import '../../config/temuan_model.dart';
import '../../config/app_theme.dart';

class DashboardRecentActivity extends StatelessWidget {
  final List<TemuanModel> recentTemuan;
  final VoidCallback onLihatSemua;

  const DashboardRecentActivity({
    super.key,
    required this.recentTemuan,
    required this.onLihatSemua,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 16,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Temuan Terbaru',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (recentTemuan.isNotEmpty)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor:
                      context.isDark
                          ? Colors.blue.shade300
                          : Colors.blue.shade800,
                ),
                onPressed: onLihatSemua,
                child: const Text('Lihat Semua'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (recentTemuan.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum ada temuan',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada temuan yang dapat ditampilkan untuk akun Anda.',
                  style: TextStyle(color: context.textSecondary, fontSize: 14),
                ),
              ],
            ),
          )
        else
          for (final temuan in recentTemuan)
            _RecentTemuanCard(temuan: temuan, onTap: onLihatSemua),
      ],
    );
  }
}

class _RecentTemuanCard extends StatelessWidget {
  final TemuanModel temuan;
  final VoidCallback onTap;

  const _RecentTemuanCard({required this.temuan, required this.onTap});

  String get _status {
    final value = temuan.statusTemuan?.trim();
    return switch (value?.toLowerCase()) {
      'open' => 'Open',
      'on progress' => 'On Progress',
      'close' || 'closed' => 'Closed',
      null || '' => 'Status belum tersedia',
      _ => value!,
    };
  }

  @override
  Widget build(BuildContext context) {
    final date = temuan.tanggalTemuan;
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final status = temuan.statusTemuan?.trim().toLowerCase();
    final statusColor = switch (status) {
      'open' => Colors.blue,
      'on progress' => Colors.orange,
      'close' || 'closed' => Colors.green,
      _ => Colors.grey,
    };
    final risk = temuan.levelRisiko?.trim();
    final riskColor = switch (risk?.toLowerCase()) {
      'extreme' => Colors.red,
      'high' => Colors.deepOrange,
      'medium' => Colors.orange,
      _ => Colors.grey,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.blue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            temuan.namaPemilik,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            temuan.lokasi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: context.textSecondary),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatusTag(label: _status, color: statusColor),
                    if (risk?.isNotEmpty == true)
                      _StatusTag(label: 'Risiko $risk', color: riskColor),
                    if (temuan.tipeTemuan?.trim().isNotEmpty == true)
                      _NeutralTag(label: temuan.tipeTemuan!.trim()),
                    _NeutralTag(label: dateLabel),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String label;
  final MaterialColor color;

  const _StatusTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: context.isDark ? 0.22 : 0.10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: context.isDark ? color.shade200 : color.shade800,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _NeutralTag extends StatelessWidget {
  final String label;

  const _NeutralTag({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color:
          context.isDark
              ? Colors.white10
              : Colors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(color: context.textSecondary, fontSize: 12),
    ),
  );
}
