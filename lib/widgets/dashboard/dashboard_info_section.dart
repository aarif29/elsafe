import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class DashboardInfoSection extends StatelessWidget {
  const DashboardInfoSection({super.key});

  static const _tips = [
    'Tidak ada yang lebih penting dari jiwa manusia.',
    'Bekerja itu jalan rezeki, berdoa itu sumber rezeki.',
    'Zero Harm, Zero Loss. Safety First.',
    'Zero accident, no tolerance!',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1, color: context.borderColor),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(
            'Tips K3',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            for (final tip in _tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tip,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
