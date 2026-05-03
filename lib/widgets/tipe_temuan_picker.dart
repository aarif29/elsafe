import 'package:flutter/material.dart';
import '../config/temuan_types.dart';

class TipeTemuanPicker extends StatelessWidget {
  const TipeTemuanPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pilih Jenis Temuan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih kategori potensi bahaya yang akan dilaporkan',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 20),
          _TipeCard(
            tipe: TipeTemuan.kmu,
            label: TipeTemuan.label(TipeTemuan.kmu),
            deskripsi: 'Proyek bangunan, pasang baliho, pasang umbul-umbul, dsb',
            icon: Icons.bolt,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _TipeCard(
            tipe: TipeTemuan.row,
            label: TipeTemuan.label(TipeTemuan.row),
            deskripsi:
                'Pohon produktif, wilayah rawan layang-layang, dsb',
            icon: Icons.nature,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Center(
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipeCard extends StatelessWidget {
  final String tipe;
  final String label;
  final String deskripsi;
  final IconData icon;
  final Color color;

  const _TipeCard({
    required this.tipe,
    required this.label,
    required this.deskripsi,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context, tipe),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deskripsi,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}
