import 'package:flutter/material.dart';
import '../../config/temuan_model.dart';
import '../../config/temuan_types.dart';
import '../../config/app_theme.dart';
import '../../config/sosialisasi_model.dart';
import '../../config/temuan_service.dart';
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
    if (widget.temuan.id != null) {
      _loadSosialisasi();
    }
  }

  Future<void> _loadSosialisasi() async {
    setState(() => _isLoadingSosialisasi = true);
    final result = await _temuanService.getSosialisasiByTemuan(widget.temuan.id!);
    if (mounted) {
      setState(() {
        _sosialisasiList = result['data'] as List<SosialisasiModel>? ?? [];
        _isLoadingSosialisasi = false;
      });
    }
  }

  Color _levelRisikoColor(String? level) {
    switch (level) {
      case 'Medium': return Colors.amber;
      case 'High': return Colors.orange;
      case 'Extreme': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final temuan = widget.temuan;
    final String status = temuan.statusTemuan ?? 'Open';
    final bool isOpen = status == 'Open';
    final Color statusColor = isOpen ? Colors.red : Colors.green;
    final IconData statusIcon = isOpen ? Icons.lock_open : Icons.lock;
    final String statusText = isOpen ? 'Belum Selesai' : 'Sudah Selesai';

    return Dialog(
      backgroundColor: context.surfaceColor,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(temuan.namaPemilik,
                        style: TextStyle(color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto temuan
                    if (temuan.fotoUrls != null && temuan.fotoUrls!.isNotEmpty) ...[
                      Text('📸 Foto Temuan', style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      FotoGridWidget(fotoUrls: temuan.fotoUrls!, isEditable: false),
                      const SizedBox(height: 20),
                    ],

                    // Tipe badge
                    if (temuan.tipeTemuan != null) ...[
                      _TipeBadgeRow(tipeTemuan: temuan.tipeTemuan!),
                      const SizedBox(height: 12),
                    ],

                    // Info dasar
                    _InfoRow(label: '📍 Lokasi', value: temuan.lokasi),
                    _InfoRow(label: '📅 Tanggal', value: _formatDate(temuan.tanggalTemuan)),
                    _InfoRow(label: '📝 Deskripsi', value: temuan.deskripsiTemuan),

                    // Nomor AMS
                    if (temuan.nomorAms != null && temuan.nomorAms!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.confirmation_number, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nomor AMS', style: TextStyle(color: Colors.orange[300], fontSize: 12, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text(temuan.nomorAms!, style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Penyulang & Section
                    if (temuan.namaPenyulang != null || temuan.section != null) ...[
                      const SizedBox(height: 12),
                      if (temuan.namaPenyulang != null)
                        _InfoRow(label: '⚡ Penyulang', value: temuan.namaPenyulang!),
                      if (temuan.section != null)
                        _InfoRow(label: '🔢 Section', value: 'Section ${temuan.section}'),
                    ],

                    // Koordinat GPS
                    if (temuan.latitude != null && temuan.longitude != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('🗺️ Koordinat GPS', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('${temuan.latitude}, ${temuan.longitude}', style: TextStyle(color: context.textSecondary, fontSize: 14)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      widget.onOpenMaps(temuan.latitude!, temuan.longitude!, temuan.lokasi);
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.map, size: 18),
                                    label: const Text('Buka Maps'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => widget.onCopyCoordinates(temuan.latitude!, temuan.longitude!),
                                    icon: const Icon(Icons.copy, size: 18),
                                    label: const Text('Copy'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Status Temuan
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [statusColor.withValues(alpha: 0.2), statusColor.withValues(alpha: 0.05)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor, width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                            child: Icon(statusIcon, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status Temuan', style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                                      child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w600))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ===== SECTION: MATRIKS RISIKO =====
                    if (temuan.levelRisiko != null) ...[
                      const SizedBox(height: 20),
                      _SectionHeader(label: '🛡️ Matriks Risiko'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _levelRisikoColor(temuan.levelRisiko).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _levelRisikoColor(temuan.levelRisiko).withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.shield, color: _levelRisikoColor(temuan.levelRisiko), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Level Risiko: ${temuan.levelRisiko}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _levelRisikoColor(temuan.levelRisiko)),
                                ),
                              ],
                            ),
                            if (temuan.jarakAktivitas != null) ...[
                              const SizedBox(height: 8),
                              _MatriksRow('Jarak Aktivitas', temuan.jarakAktivitas!),
                            ],
                            if (temuan.intensitasAktivitas != null)
                              _MatriksRow('Intensitas Aktivitas', temuan.intensitasAktivitas!),
                            if (temuan.jenisObjek != null)
                              _MatriksRow('Jenis Objek', temuan.jenisObjek!),
                            if (temuan.jenisAset != null)
                              _MatriksRow('Jenis Aset', temuan.jenisAset!),
                            if (temuan.lokasiObjek != null)
                              _MatriksRow('Lokasi Objek', temuan.lokasiObjek!),
                          ],
                        ),
                      ),
                    ],

                    // ===== SECTION: REMINDER =====
                    if (temuan.tglReminder != null) ...[
                      const SizedBox(height: 20),
                      _SectionHeader(label: '🔔 Reminder'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.blue, size: 16),
                                const SizedBox(width: 8),
                                Text(_formatDate(temuan.tglReminder!), style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            if (temuan.fotoReminder != null && temuan.fotoReminder!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text('Foto Surat Tanda Terima', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                              const SizedBox(height: 8),
                              FotoGridWidget(fotoUrls: temuan.fotoReminder!, isEditable: false),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // ===== SECTION: CLOSING =====
                    if (temuan.jenisClosing != null) ...[
                      const SizedBox(height: 20),
                      _SectionHeader(label: '✅ Closing'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  temuan.jenisClosing == 'pfk' ? 'PFK' : 'Preventif',
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            if (temuan.tglClosing != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.green, size: 14),
                                  const SizedBox(width: 6),
                                  Text(_formatDate(temuan.tglClosing!), style: TextStyle(color: context.textPrimary)),
                                ],
                              ),
                            ],
                            if (temuan.fotoClosing != null && temuan.fotoClosing!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text('Foto Tindaklanjut', style: TextStyle(color: context.textSecondary, fontSize: 12)),
                              const SizedBox(height: 8),
                              FotoGridWidget(fotoUrls: temuan.fotoClosing!, isEditable: false),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // ===== SECTION: SOSIALISASI =====
                    const SizedBox(height: 20),
                    _SectionHeader(label: '📢 Sosialisasi'),
                    if (temuan.jenisClosing == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '(Tersedia setelah closing)',
                        style: TextStyle(
                          color: context.textHint,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (_isLoadingSosialisasi)
                      const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                    else if (_sosialisasiList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(10)),
                        child: Text('Belum ada riwayat sosialisasi.', style: TextStyle(color: context.textSecondary), textAlign: TextAlign.center),
                      )
                    else
                      ..._sosialisasiList.map((s) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.event, color: Colors.purple, size: 16),
                                const SizedBox(width: 8),
                                Text(_formatDate(s.tglSosialisasi), style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            if (s.fotoUrls != null && s.fotoUrls!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              FotoGridWidget(fotoUrls: s.fotoUrls!, isEditable: false),
                            ],
                          ],
                        ),
                      )),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.onEdit != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onEdit!();
                      },
                      icon: const Icon(Icons.edit, size: 16, color: Colors.orange),
                      label: const Text('Edit', style: TextStyle(color: Colors.orange)),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup', style: TextStyle(color: Colors.blue)),
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

// ====== Helper Widgets ======

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextStyle(color: context.textPrimary, fontSize: 15, fontWeight: FontWeight.bold));
  }
}

class _MatriksRow extends StatelessWidget {
  final String label;
  final String value;
  const _MatriksRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: context.textSecondary, fontSize: 12)),
          Expanded(child: Text(value, style: TextStyle(color: context.textPrimary, fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _TipeBadgeRow extends StatelessWidget {
  final String tipeTemuan;

  const _TipeBadgeRow({required this.tipeTemuan});

  @override
  Widget build(BuildContext context) {
    final isKmu = tipeTemuan == TipeTemuan.kmu;
    final color = isKmu ? Colors.red : Colors.green;
    final icon = isKmu ? Icons.bolt : Icons.nature;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(TipeTemuan.label(tipeTemuan), style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: context.textPrimary, fontSize: 14)),
        ],
      ),
    );
  }
}
