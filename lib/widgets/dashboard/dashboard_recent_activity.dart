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
          for (final temuan in recentTemuan) ...[
            Divider(height: 1, color: context.borderColor),
            _RecentTemuanRow(temuan: temuan, onTap: onLihatSemua),
          ],
      ],
    );
  }
}

class _RecentTemuanRow extends StatelessWidget {
  final TemuanModel temuan;
  final VoidCallback onTap;

  const _RecentTemuanRow({required this.temuan, required this.onTap});

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
    final details = [
      _status,
      if (temuan.levelRisiko?.trim().isNotEmpty == true)
        'Risiko ${temuan.levelRisiko}',
      if (temuan.tipeTemuan?.trim().isNotEmpty == true) temuan.tipeTemuan!,
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide =
                  constraints.maxWidth >=
                  900 * MediaQuery.textScalerOf(context).scale(1);
              final identity = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    temuan.namaPemilik,
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    temuan.lokasi,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
              final metadata = [
                for (final detail in details)
                  Text(
                    detail,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                    ),
                  ),
              ];
              final dateText = Text(
                dateLabel,
                style: TextStyle(color: context.textSecondary, fontSize: 14),
              );
              if (wide) {
                final columns = [
                  _status,
                  if (temuan.levelRisiko?.trim().isNotEmpty == true)
                    'Risiko ${temuan.levelRisiko}'
                  else
                    '',
                  temuan.tipeTemuan?.trim() ?? '',
                ];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: identity),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < columns.length; i++)
                            Expanded(
                              flex: i == 1 ? 4 : 3,
                              child: Text(
                                columns[i],
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    dateText,
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: context.textSecondary,
                      size: 20,
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  identity,
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [...metadata, dateText],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
