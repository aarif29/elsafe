import 'package:flutter/material.dart';
import '../../config/temuan_model.dart';
import '../../config/app_theme.dart';

class TemuanListItem extends StatelessWidget {
  final TemuanModel temuan;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canModify;

  const TemuanListItem({
    super.key,
    required this.temuan,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.canModify = true,
  });

  String get _statusLabel {
    final value = temuan.statusTemuan?.trim();
    switch (value?.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'on progress':
        return 'On Progress';
      case 'close':
      case 'closed':
        return 'Closed';
      case null:
      case '':
        return 'Status belum tersedia';
      default:
        return value!;
    }
  }

  Color _statusColor(BuildContext context) {
    final MaterialColor? color = switch (_statusLabel) {
      'Open' => Colors.red,
      'On Progress' => Colors.orange,
      'Closed' => Colors.green,
      _ => null,
    };
    return color == null
        ? context.textSecondary
        : color[context.isDark ? 300 : 800]!;
  }

  Color _levelRisikoColor(BuildContext context) {
    switch (temuan.levelRisiko) {
      case 'Medium':
        return context.isDark ? Colors.amber.shade300 : Colors.amber.shade900;
      case 'High':
        return context.isDark
            ? Colors.deepOrange.shade300
            : Colors.deepOrange.shade800;
      case 'Extreme':
        return context.isDark ? Colors.red.shade300 : Colors.red.shade800;
      default:
        return context.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temuan.lokasi.trim().isEmpty
                          ? temuan.namaPemilik
                          : temuan.lokasi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      temuan.deskripsiTemuan,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _metadataLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textHint,
                        fontSize: 11.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 5,
                      children: [
                        _buildSignalLabel(_statusLabel, _statusColor(context)),
                        if (temuan.levelRisiko?.trim().isNotEmpty == true)
                          _buildSignalLabel(
                            temuan.levelRisiko!,
                            _levelRisikoColor(context),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (canModify) ...[
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      tooltip: 'Edit temuan',
                      icon: Icons.edit_outlined,
                      onPressed: onEdit,
                      color: context.textSecondary,
                    ),
                    _buildActionButton(
                      tooltip: 'Hapus temuan',
                      icon: Icons.delete_outline,
                      onPressed: onDelete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String get _metadataLabel {
    final parts = [
      temuan.namaPemilik,
      '${temuan.tanggalTemuan.day.toString().padLeft(2, '0')}/${temuan.tanggalTemuan.month.toString().padLeft(2, '0')}/${temuan.tanggalTemuan.year}',
      if (temuan.tipeTemuan?.trim().isNotEmpty == true) temuan.tipeTemuan!,
    ].where((part) => part.trim().isNotEmpty);
    return parts.join('  |  ');
  }

  Widget _buildThumbnail(BuildContext context) {
    final urls = temuan.fotoUrls;
    final photoUrl = urls?.isNotEmpty == true ? urls!.first : null;
    const size = 52.0;

    Widget placeholder() => Container(
      width: size,
      height: size,
      color: context.skeletonBase,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: context.textHint, size: 20),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child:
            photoUrl != null
                ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return placeholder();
                      },
                      errorBuilder:
                          (context, error, stackTrace) => placeholder(),
                    ),
                    if (urls!.length > 1)
                      Positioned(
                        right: 3,
                        bottom: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.68),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '+${urls.length - 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
                : placeholder(),
      ),
    );
  }

  Widget _buildSignalLabel(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      padding: EdgeInsets.zero,
      iconSize: 18,
      color: color,
      icon: Icon(icon),
    );
  }
}
