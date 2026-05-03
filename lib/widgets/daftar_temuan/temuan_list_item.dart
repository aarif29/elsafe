import 'package:flutter/material.dart';
import '../../config/temuan_model.dart';
import '../../config/temuan_types.dart';
import '../../config/app_theme.dart';

class TemuanListItem extends StatelessWidget {
  final TemuanModel temuan;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TemuanListItem({
    super.key,
    required this.temuan,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _tipeColor {
    if (temuan.tipeTemuan == TipeTemuan.kmu) return Colors.red;
    if (temuan.tipeTemuan == TipeTemuan.row) return Colors.green;
    return Colors.grey;
  }

  Color get _levelRisikoColor {
    switch (temuan.levelRisiko) {
      case 'Medium':
        return Colors.amber;
      case 'High':
        return Colors.orange;
      case 'Extreme':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // Card utama
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderColor, width: 0.5),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Foto leading
                    (temuan.fotoUrls != null && temuan.fotoUrls!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              temuan.fotoUrls!.first,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: context.skeletonBase,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.blue),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 60,
                                height: 60,
                                color: context.skeletonBase,
                                child: Icon(Icons.broken_image,
                                    color: context.textHint),
                              ),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: context.skeletonBase,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.image_not_supported,
                                color: context.textHint),
                          ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  temuan.namaPemilik,
                                  style: TextStyle(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (temuan.fotoUrls != null &&
                                  temuan.fotoUrls!.length > 1)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '+${temuan.fotoUrls!.length - 1}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(temuan.lokasi,
                              style:
                                  TextStyle(color: context.textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            '${temuan.tanggalTemuan.day.toString().padLeft(2, '0')}/${temuan.tanggalTemuan.month.toString().padLeft(2, '0')}/${temuan.tanggalTemuan.year}',
                            style: TextStyle(
                                color: context.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (temuan.tipeTemuan != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        _tipeColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: _tipeColor, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        temuan.tipeTemuan == TipeTemuan.kmu
                                            ? Icons.bolt
                                            : Icons.nature,
                                        color: _tipeColor,
                                        size: 10,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        temuan.tipeTemuan!,
                                        style: TextStyle(
                                          color: _tipeColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (temuan.statusTemuan == 'Open')
                                      ? Colors.red.withValues(alpha: 0.15)
                                      : Colors.green
                                          .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: (temuan.statusTemuan == 'Open')
                                        ? Colors.red
                                        : Colors.green,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  (temuan.statusTemuan == 'Open')
                                      ? 'Open'
                                      : 'Closed',
                                  style: TextStyle(
                                    color: (temuan.statusTemuan == 'Open')
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (temuan.levelRisiko != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _levelRisikoColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: _levelRisikoColor, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shield, color: _levelRisikoColor, size: 10),
                                      const SizedBox(width: 3),
                                      Text(
                                        temuan.levelRisiko!,
                                        style: TextStyle(
                                          color: _levelRisikoColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  temuan.deskripsiTemuan,
                                  style:
                                      TextStyle(color: context.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: onEdit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Left color strip
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: _tipeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
