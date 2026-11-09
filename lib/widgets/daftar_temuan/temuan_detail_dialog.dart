import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../config/sosialisasi_model.dart';
import '../../config/temuan_model.dart';
import '../../config/temuan_service.dart';
import '../../config/temuan_types.dart';
import '../foto_grid_widget.dart';

class TemuanDetailDialog extends StatefulWidget {
  final TemuanModel temuan;
  final void Function(double lat, double lng, String lokasi) onOpenMaps;
  final void Function(double lat, double lng) onCopyCoordinates;
  final VoidCallback? onEdit;

  const TemuanDetailDialog({
    super.key,
    required this.temuan,
    required this.onOpenMaps,
    required this.onCopyCoordinates,
    this.onEdit,
  });

  @override
  State<TemuanDetailDialog> createState() => _TemuanDetailDialogState();
}

class _TemuanDetailDialogState extends State<TemuanDetailDialog> {
  final _temuanService = TemuanService();
  List<SosialisasiModel> _sosialisasiList = [];
  bool _isLoadingSosialisasi = false;

  @override
  void initState() {
    super.initState();
    if (widget.temuan.id != null) _loadSosialisasi();
  }

  Future<void> _loadSosialisasi() async {
    setState(() => _isLoadingSosialisasi = true);
    final result = await _temuanService.getSosialisasiByTemuan(
      widget.temuan.id!,
    );
    if (mounted) {
      setState(() {
        _sosialisasiList = result['data'] as List<SosialisasiModel>? ?? [];
        _isLoadingSosialisasi = false;
      });
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final temuan = widget.temuan;
    final rawStatus = temuan.statusTemuan?.trim();
    final (status, statusText, statusBase) = switch (rawStatus?.toLowerCase()) {
      'open' => ('Open', 'Belum Selesai', Colors.red),
      'on progress' => ('On Progress', 'Sedang Ditindaklanjuti', Colors.orange),
      'close' || 'closed' => ('Closed', 'Sudah Selesai', Colors.green),
      _ => (
        rawStatus?.isNotEmpty == true ? rawStatus! : 'Status belum tersedia',
        'Status perlu dikonfirmasi',
        Colors.grey,
      ),
    };
    final riskBase = switch (temuan.levelRisiko?.trim().toLowerCase()) {
      'medium' => Colors.orange,
      'high' => Colors.deepOrange,
      'extreme' => Colors.red,
      _ => Colors.grey,
    };
    final statusColor = statusBase[context.isDark ? 300 : 800]!;
    final riskColor = riskBase[context.isDark ? 300 : 800]!;

    return Dialog(
      backgroundColor: context.surfaceColor,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          temuan.namaPemilik.trim().isEmpty
                              ? 'Nama pemilik belum diisi'
                              : temuan.namaPemilik,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ditemukan pada ${_formatDate(temuan.tanggalTemuan)}',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.borderColor),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 20,
                      runSpacing: 12,
                      children: [
                        _SummaryItem(
                          label: 'Status temuan',
                          value: status,
                          detail: statusText,
                          color: statusColor,
                        ),
                        _SummaryItem(
                          label: 'Level risiko',
                          value:
                              temuan.levelRisiko?.trim().isNotEmpty == true
                                  ? temuan.levelRisiko!.trim()
                                  : 'Belum tersedia',
                          color: riskColor,
                        ),
                      ],
                    ),
                    if (temuan.fotoUrls != null &&
                        temuan.fotoUrls!.isNotEmpty) ...[
                      const _SectionTitle('Foto temuan'),
                      FotoGridWidget(
                        fotoUrls: temuan.fotoUrls!,
                        isEditable: false,
                      ),
                    ],
                    const _SectionTitle('Informasi temuan'),
                    if (temuan.tipeTemuan != null)
                      _InfoRow(
                        'Tipe temuan',
                        TipeTemuan.label(temuan.tipeTemuan!),
                      ),
                    _InfoRow('Lokasi', temuan.lokasi),
                    _InfoRow('Deskripsi', temuan.deskripsiTemuan),
                    if (temuan.nomorAms != null && temuan.nomorAms!.isNotEmpty)
                      _InfoRow('Nomor AMS', temuan.nomorAms!),
                    if (temuan.namaPenyulang != null)
                      _InfoRow('Penyulang', temuan.namaPenyulang!),
                    if (temuan.section != null)
                      _InfoRow('Section', 'Section ${temuan.section}'),
                    if (temuan.latitude != null &&
                        temuan.longitude != null) ...[
                      const _SectionTitle('Koordinat GPS'),
                      Text(
                        '${temuan.latitude}, ${temuan.longitude}',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              widget.onOpenMaps(
                                temuan.latitude!,
                                temuan.longitude!,
                                temuan.lokasi,
                              );
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.map_outlined, size: 18),
                            label: const Text('Buka Maps'),
                          ),
                          TextButton.icon(
                            onPressed:
                                () => widget.onCopyCoordinates(
                                  temuan.latitude!,
                                  temuan.longitude!,
                                ),
                            icon: const Icon(Icons.copy_outlined, size: 18),
                            label: const Text('Copy'),
                          ),
                        ],
                      ),
                    ],
                    if (temuan.levelRisiko != null) ...[
                      const _SectionTitle('Matriks risiko'),
                      _InfoRow('Level risiko', temuan.levelRisiko!),
                      if (temuan.jarakAktivitas != null)
                        _InfoRow('Jarak aktivitas', temuan.jarakAktivitas!),
                      if (temuan.intensitasAktivitas != null)
                        _InfoRow(
                          'Intensitas aktivitas',
                          temuan.intensitasAktivitas!,
                        ),
                      if (temuan.jenisObjek != null)
                        _InfoRow('Jenis objek', temuan.jenisObjek!),
                      if (temuan.jenisAset != null)
                        _InfoRow('Jenis aset', temuan.jenisAset!),
                      if (temuan.lokasiObjek != null)
                        _InfoRow('Lokasi objek', temuan.lokasiObjek!),
                    ],
                    if (temuan.tglReminder != null) ...[
                      const _SectionTitle('Reminder'),
                      _InfoRow('Tanggal', _formatDate(temuan.tglReminder!)),
                      if (temuan.fotoReminder != null &&
                          temuan.fotoReminder!.isNotEmpty) ...[
                        _PhotoLabel('Foto Surat Tanda Terima'),
                        FotoGridWidget(
                          fotoUrls: temuan.fotoReminder!,
                          isEditable: false,
                        ),
                      ],
                    ],
                    if (temuan.jenisClosing != null) ...[
                      const _SectionTitle('Closing'),
                      _InfoRow(
                        'Jenis',
                        temuan.jenisClosing == 'pfk' ? 'PFK' : 'Preventif',
                      ),
                      if (temuan.tglClosing != null)
                        _InfoRow('Tanggal', _formatDate(temuan.tglClosing!)),
                      if (temuan.fotoClosing != null &&
                          temuan.fotoClosing!.isNotEmpty) ...[
                        _PhotoLabel('Foto Tindaklanjut'),
                        FotoGridWidget(
                          fotoUrls: temuan.fotoClosing!,
                          isEditable: false,
                        ),
                      ],
                    ],
                    const _SectionTitle('Sosialisasi'),
                    if (temuan.jenisClosing == null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '(Tersedia setelah closing)',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (_isLoadingSosialisasi)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_sosialisasiList.isEmpty)
                      Text(
                        'Belum ada riwayat sosialisasi.',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                      )
                    else
                      for (final s in _sosialisasiList) ...[
                        _InfoRow('Tanggal', _formatDate(s.tglSosialisasi)),
                        if (s.fotoUrls != null && s.fotoUrls!.isNotEmpty)
                          FotoGridWidget(
                            fotoUrls: s.fotoUrls!,
                            isEditable: false,
                          ),
                      ],
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: context.borderColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.onEdit != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onEdit!();
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final String? detail;
  final Color color;
  const _SummaryItem({
    required this.label,
    required this.value,
    this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: TextStyle(color: context.textSecondary, fontSize: 12)),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      if (detail != null)
        Text(
          detail!,
          style: TextStyle(color: context.textSecondary, fontSize: 12),
        ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 1, color: context.borderColor),
        const SizedBox(height: 16),
        Text(
          label,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: context.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: context.textPrimary, fontSize: 14)),
      ],
    ),
  );
}

class _PhotoLabel extends StatelessWidget {
  final String label;
  const _PhotoLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: TextStyle(color: context.textSecondary, fontSize: 12),
    ),
  );
}
