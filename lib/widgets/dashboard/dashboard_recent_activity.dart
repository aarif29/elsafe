import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../config/temuan_model.dart';

class DashboardRecentActivity extends StatelessWidget {
  final List<TemuanModel> recentTemuan;
  final VoidCallback onLihatSemua;
  final ValueChanged<TemuanModel> onOpenTemuan;

  const DashboardRecentActivity({
    super.key,
    required this.recentTemuan,
    required this.onLihatSemua,
    required this.onOpenTemuan,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 460;
        final heading = Text(
          'Temuan Open prioritas',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        );
        final link = TextButton(
          onPressed: onLihatSemua,
          child: const Text('Buka daftar'),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (compact)
              heading
            else
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [heading, link],
              ),
            if (recentTemuan.isEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tidak ada temuan Open',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Semua temuan dalam cakupan ini sudah memiliki status lain atau belum ada temuan.',
                style: TextStyle(color: context.textSecondary, fontSize: 13),
              ),
            ] else
              for (final temuan in recentTemuan)
                _OpenTemuanRow(
                  temuan: temuan,
                  onTap: () => onOpenTemuan(temuan),
                ),
            if (compact) Align(alignment: Alignment.centerLeft, child: link),
          ],
        );
      },
    );
  }
}

class _OpenTemuanRow extends StatelessWidget {
  final TemuanModel temuan;
  final VoidCallback onTap;

  const _OpenTemuanRow({required this.temuan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = temuan.tanggalTemuan;
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final location =
        temuan.lokasi.trim().isEmpty
            ? 'Lokasi belum diisi'
            : temuan.lokasi.trim();
    final title =
        temuan.namaPemilik.trim().isEmpty
            ? 'Nama pemilik belum diisi'
            : temuan.namaPemilik.trim();
    final area = <String>[
      if (temuan.ulp?.trim().isNotEmpty == true) 'ULP ${temuan.ulp!.trim()}',
      if (temuan.namaPenyulang?.trim().isNotEmpty == true)
        'Penyulang ${temuan.namaPenyulang!.trim()}',
    ].join(' · ');
    final risk = temuan.levelRisiko?.trim();
    final riskColor = switch (risk?.toLowerCase()) {
      'extreme' => Colors.red,
      'high' => Colors.deepOrange,
      'medium' => Colors.orange,
      _ => Colors.grey,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: context.textSecondary),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                location,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
              if (area.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  area,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    temuan.tipeTemuan?.trim().isNotEmpty == true
                        ? temuan.tipeTemuan!.trim()
                        : 'Tipe belum diisi',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    risk?.isNotEmpty == true
                        ? 'Risiko $risk'
                        : 'Risiko belum diisi',
                    style: TextStyle(
                      color:
                          risk?.isNotEmpty == true
                              ? (context.isDark
                                  ? riskColor.shade200
                                  : riskColor.shade800)
                              : context.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: context.borderColor),
            ],
          ),
        ),
      ),
    );
  }
}
