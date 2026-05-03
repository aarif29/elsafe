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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terkini',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (recentTemuan.isNotEmpty)
              TextButton(
                onPressed: onLihatSemua,
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        recentTemuan.isEmpty
            ? _EmptyState()
            : Column(
                children: recentTemuan
                    .map((temuan) => _RecentTemuanCard(
                          temuan: temuan,
                          onTap: onLihatSemua,
                        ))
                    .toList(),
              ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: context.textDisabled, size: 64),
          const SizedBox(height: 16),
          Text(
            'Belum ada temuan',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + di bawah untuk\nmenambah temuan pertama Anda',
            style: TextStyle(color: context.textHint, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentTemuanCard extends StatelessWidget {
  final TemuanModel temuan;
  final VoidCallback onTap;

  const _RecentTemuanCard({required this.temuan, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temuan.namaPemilik,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        temuan.lokasi,
                        style: TextStyle(color: context.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${temuan.tanggalTemuan.day}/${temuan.tanggalTemuan.month}/${temuan.tanggalTemuan.year}',
                        style: TextStyle(color: context.textHint, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
