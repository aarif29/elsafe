// lib/Screen/maps_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/temuan_service.dart';
import '../config/temuan_model.dart';
import '../config/location_service.dart';
import '../config/ulp_service.dart';
import '../config/temuan_types.dart';
import '../widgets/maps_control_button.dart';

class MapsViewWidget extends StatefulWidget {
  const MapsViewWidget({super.key});

  @override
  State<MapsViewWidget> createState() => _MapsViewWidgetState();
}

class _MarkerDetailSheet extends StatelessWidget {
  final TemuanModel temuan;
  final Color pinColor;
  final Color labelBgColor;
  final VoidCallback onOpenMaps;
  final VoidCallback onCopyCoords;

  const _MarkerDetailSheet({
    required this.temuan,
    required this.pinColor,
    required this.labelBgColor,
    required this.onOpenMaps,
    required this.onCopyCoords,
  });

  String _fmt(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _val(String? v) => (v == null || v.trim().isEmpty) ? '-' : v;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 14),
                    _buildSection('Info Temuan', Icons.badge_outlined, _buildIdentitas()),
                    _buildSection('Lokasi', Icons.place_outlined, _buildLokasi()),
                    _buildSection('Deskripsi Temuan', Icons.description_outlined, _buildDeskripsi()),
                    _buildSection('Jaringan Listrik', Icons.electric_bolt, _buildJaringan()),
                    if (_hasMatriks()) _buildSection('Matriks Risiko', Icons.assessment_outlined, _buildMatriks()),
                    if (temuan.statusTemuan == 'Closed' || temuan.statusTemuan == 'Close')
                      _buildSection('Closing', Icons.check_circle_outline, _buildClosing()),
                    if (temuan.tglReminder != null)
                      _buildSection('Reminder', Icons.notifications_outlined, _buildReminder()),
                    if (temuan.fotoUrls != null && temuan.fotoUrls!.isNotEmpty)
                      _buildSection('Foto Temuan', Icons.photo_library_outlined, _buildFoto(context)),
                    if (temuan.latitude != null && temuan.longitude != null) ...[
                      const SizedBox(height: 4),
                      _buildCoordButtons(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final statusColor = (temuan.statusTemuan == 'Open') ? Colors.green : Colors.blueGrey;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                temuan.namaPemilik,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (temuan.nomorAms != null) ...[
                const SizedBox(height: 2),
                Text(
                  'AMS: ${temuan.nomorAms}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          alignment: WrapAlignment.end,
          children: [
            if (temuan.tipeTemuan != null)
              _badge(temuan.tipeTemuan!, labelBgColor, Colors.white),
            if (temuan.levelRisiko != null)
              _badge(temuan.levelRisiko!, pinColor.withValues(alpha: 0.25), pinColor,
                  border: pinColor, icon: Icons.bolt),
            _badge(temuan.statusTemuan ?? 'Open', statusColor.withValues(alpha: 0.2), statusColor,
                border: statusColor),
          ],
        ),
      ],
    );
  }

  Widget _badge(String label, Color bg, Color textColor, {Color? border, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: border != null ? Border.all(color: border, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: textColor),
            const SizedBox(width: 2),
          ],
          Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFF3A3A3A), height: 20),
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        content,
      ],
    );
  }

  Widget _buildIdentitas() {
    return Column(
      children: [
        _row(Icons.calendar_today, 'Tanggal Temuan', _fmt(temuan.tanggalTemuan)),
        if (temuan.ulp != null) _row(Icons.location_city, 'ULP', _val(temuan.ulp)),
        if (temuan.createdBy != null) _row(Icons.person_outline, 'Diupload oleh', _val(temuan.createdBy)),
        if (temuan.createdAt != null) _row(Icons.access_time, 'Dibuat', _fmt(temuan.createdAt)),
      ],
    );
  }

  Widget _buildLokasi() {
    return Column(
      children: [
        if (temuan.alamatTemuan != null && temuan.alamatTemuan!.trim().isNotEmpty)
          _row(Icons.home_outlined, 'Alamat', _val(temuan.alamatTemuan)),
        if (temuan.latitude != null)
          _row(Icons.gps_fixed, 'Koordinat',
              '${temuan.latitude!.toStringAsFixed(6)}, ${temuan.longitude!.toStringAsFixed(6)}'),
      ],
    );
  }

  Widget _buildDeskripsi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _val(temuan.deskripsiTemuan),
        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _buildJaringan() {
    return Column(
      children: [
        _row(Icons.electric_bolt, 'Penyulang', _val(temuan.namaPenyulang)),
        _row(Icons.radar, 'Zona', temuan.zona != null ? 'Zona ${temuan.zona}' : '-'),
        _row(Icons.account_tree, 'Section', temuan.section != null ? 'Section ${temuan.section}' : '-'),
      ],
    );
  }

  bool _hasMatriks() =>
      temuan.jenisObjek != null ||
      temuan.jenisAset != null ||
      temuan.lokasiObjek != null ||
      temuan.jarakAktivitas != null ||
      temuan.intensitasAktivitas != null ||
      temuan.skorMatriks != null;

  Widget _buildMatriks() {
    return Column(
      children: [
        if (temuan.jenisObjek != null) _row(Icons.category, 'Jenis Objek', _val(temuan.jenisObjek)),
        if (temuan.jenisAset != null) _row(Icons.cable, 'Jenis Aset', _val(temuan.jenisAset)),
        if (temuan.lokasiObjek != null) _row(Icons.location_searching, 'Lokasi Objek', _val(temuan.lokasiObjek)),
        if (temuan.jarakAktivitas != null) _row(Icons.straighten, 'Jarak Aktivitas', _val(temuan.jarakAktivitas)),
        if (temuan.intensitasAktivitas != null) _row(Icons.trending_up, 'Intensitas', _val(temuan.intensitasAktivitas)),
        if (temuan.levelRisiko != null)
          _row(Icons.bar_chart, 'Level Risiko', _val(temuan.levelRisiko),
              valueColor: pinColor),
      ],
    );
  }

  Widget _buildClosing() {
    return Column(
      children: [
        if (temuan.jenisClosing != null) _row(Icons.handyman, 'Jenis Closing', _val(temuan.jenisClosing)),
        _row(Icons.event_available, 'Tanggal Closing', _fmt(temuan.tglClosing)),
        if (temuan.fotoClosing != null && temuan.fotoClosing!.isNotEmpty)
          _row(Icons.photo, 'Foto Closing', '${temuan.fotoClosing!.length} foto'),
      ],
    );
  }

  Widget _buildReminder() {
    return Column(
      children: [
        _row(Icons.alarm, 'Tanggal Reminder', _fmt(temuan.tglReminder)),
        if (temuan.fotoReminder != null && temuan.fotoReminder!.isNotEmpty)
          _row(Icons.photo, 'Foto Reminder', '${temuan.fotoReminder!.length} foto'),
      ],
    );
  }

  Widget _buildFoto(BuildContext context) {
    final urls = temuan.fotoUrls!;
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _openFoto(context, urls, i),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              urls[i],
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 90,
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openFoto(BuildContext context, List<String> urls, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FotoViewer(urls: urls, initialIndex: initialIndex),
      ),
    );
  }

  Widget _buildCoordButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onOpenMaps();
            },
            icon: const Icon(Icons.map, size: 16, color: Colors.green),
            label: const Text('Buka Maps'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onCopyCoords();
            },
            icon: const Icon(Icons.copy, size: 16, color: Colors.blue),
            label: const Text('Salin Koordinat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey[500]),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 12,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FotoViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _FotoViewer({required this.urls, required this.initialIndex});

  @override
  State<_FotoViewer> createState() => _FotoViewerState();
}

class _FotoViewerState extends State<_FotoViewer> {
  late int _current;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_current + 1} / ${widget.urls.length}'),
      ),
      body: PageView.builder(
        controller: _pageCtrl,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(
              widget.urls[i],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _LegendItem({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _MapsViewWidgetState extends State<MapsViewWidget> {
  final _temuanService = TemuanService();
  final _locationService = LocationService();
  final _ulpService = UlpService();
  final MapController _mapController = MapController();

  List<TemuanModel> _temuanList = [];
  final List<Marker> _markers = [];
  Marker? _currentLocationMarker;

  bool _isLoading = true;
  bool _isGettingLocation = false;
  bool _showLabels = true;
  bool _isAdmin = false;
  String? _currentUserUlp;
  String _filterUlp = 'Semua';
  String _filterStatus = 'Semua';
  String _filterTipe = 'Semua';
  String _filterKategori = 'Semua';
  String _filterPenyulang = 'Semua';

  final LatLng _center = const LatLng(-7.9666, 112.6326);

  List<String> get _ulpOptions {
    final ulps = _temuanList
        .map((t) => t.ulp ?? '')
        .where((u) => u.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Semua', ...ulps];
  }

  List<String> get _penyulangOptions {
    if (_isAdmin) {
      if (_filterUlp == 'Semua') return Penyulang.semua;
      return Penyulang.perUlp[_filterUlp] ?? [];
    }
    return Penyulang.perUlp[_currentUserUlp] ?? [];
  }

  List<TemuanModel> get _filteredTemuan {
    var result = _temuanList;
    if (_filterUlp != 'Semua') result = result.where((t) => t.ulp == _filterUlp).toList();
    if (_filterStatus != 'Semua') result = result.where((t) => t.statusTemuan == _filterStatus).toList();
    if (_filterTipe != 'Semua') result = result.where((t) => t.tipeTemuan == _filterTipe).toList();
    if (_filterKategori != 'Semua') result = result.where((t) => t.levelRisiko == _filterKategori).toList();
    if (_filterPenyulang != 'Semua') result = result.where((t) => t.namaPenyulang == _filterPenyulang).toList();
    return result;
  }

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    final profile = await _ulpService.getCurrentUserProfile();
    _isAdmin = profile?['role'] == 'admin';
    _currentUserUlp = profile?['ulp'] as String?;
    _loadTemuanData();
  }

  Future<void> _loadTemuanData() async {
    try {
      final result = await _temuanService.getAllTemuanSilent();
      if (!mounted) return;
      if (result['success']) {
        setState(() {
          _temuanList = result['data'] ?? [];
          _createMarkers();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showSnack('❌ ${result['message']}', Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('❌ Error: $e', Colors.red);
    }
  }

  // ===== Marker color helpers =====

  Color _labelBgColor(String? tipe) {
    if (tipe == 'KMU') return Colors.red[700]!;
    if (tipe == 'ROW') return Colors.green[700]!;
    return Colors.blueGrey[700]!;
  }

  Color _labelBorderColor(String? tipe) {
    if (tipe == 'KMU') return Colors.red[300]!;
    if (tipe == 'ROW') return Colors.green[300]!;
    return Colors.white;
  }

  IconData _pinIcon(String? level) {
    if (level == 'Medium' || level == 'High' || level == 'Extreme') {
      return Icons.bolt;
    }
    return Icons.location_on;
  }

  Color _pinColor(String? tipe, String? level) {
    if (level == 'Medium') return Colors.amber;
    if (level == 'High') return Colors.orange;
    if (level == 'Extreme') return Colors.red;
    // No level: fallback to tipe color
    if (tipe == 'KMU') return Colors.red;
    if (tipe == 'ROW') return Colors.green;
    return Colors.red;
  }

  void _createMarkers() {
    _markers.clear();
    for (final temuan in _filteredTemuan) {
      if (temuan.latitude == null || temuan.longitude == null) continue;

      final labelBg = _labelBgColor(temuan.tipeTemuan);
      final labelBorder = _labelBorderColor(temuan.tipeTemuan);
      final pinIcon = _pinIcon(temuan.levelRisiko);
      final pinColor = _pinColor(temuan.tipeTemuan, temuan.levelRisiko);

      _markers.add(
        Marker(
          point: LatLng(temuan.latitude!, temuan.longitude!),
          width: 120,
          height: 64,
          child: GestureDetector(
            onTap: () => _showMarkerInfo(temuan),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: labelBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: labelBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    temuan.namaPemilik.length > 15
                        ? '${temuan.namaPemilik.substring(0, 15)}...'
                        : temuan.namaPemilik,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 2),
                Icon(pinIcon, color: pinColor, size: 32),
              ],
            ),
          ),
        ),
      );
    }
    if (_currentLocationMarker != null) {
      _markers.add(_currentLocationMarker!);
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);

    final pos = await _locationService.getCurrentPosition();
    if (pos != null) {
      final current = LatLng(pos.latitude, pos.longitude);
      _currentLocationMarker = Marker(
        point: current,
        width: 50,
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        ),
      );
      setState(() => _createMarkers());
      _mapController.move(current, 17);
      _showSnack('📍 Lokasi Anda ditemukan', Colors.blue);
    } else {
      _showSnack('⚠️ Lokasi tidak tersedia', Colors.orange);
    }

    if (mounted) setState(() => _isGettingLocation = false);
  }

  void _zoomIn() {
    final z = _mapController.camera.zoom + 1;
    _mapController.move(_mapController.camera.center, z.clamp(3, 19));
  }

  void _zoomOut() {
    final z = _mapController.camera.zoom - 1;
    _mapController.move(_mapController.camera.center, z.clamp(3, 19));
  }

  void _fitAllMarkers() {
    if (_markers.isEmpty) return;
    if (_markers.length == 1) {
      _mapController.move(_markers.first.point, 17);
      return;
    }
    double minLat = _markers.first.point.latitude;
    double maxLat = _markers.first.point.latitude;
    double minLng = _markers.first.point.longitude;
    double maxLng = _markers.first.point.longitude;

    for (final m in _markers) {
      if (m.point.latitude < minLat) minLat = m.point.latitude;
      if (m.point.latitude > maxLat) maxLat = m.point.latitude;
      if (m.point.longitude < minLng) minLng = m.point.longitude;
      if (m.point.longitude > maxLng) maxLng = m.point.longitude;
    }

    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final span = (latDiff > lngDiff ? latDiff : lngDiff).abs();

    double targetZoom;
    if (span < 0.0008) {
      targetZoom = 19;
    } else if (span < 0.0015) {
      targetZoom = 18;
    } else if (span < 0.003) {
      targetZoom = 17;
    } else if (span < 0.006) {
      targetZoom = 16;
    } else if (span < 0.012) {
      targetZoom = 15;
    } else if (span < 0.025) {
      targetZoom = 14;
    } else if (span < 0.05) {
      targetZoom = 13;
    } else if (span < 0.1) {
      targetZoom = 12;
    } else {
      targetZoom = 11;
    }

    _mapController.move(center, targetZoom);
  }

  void _toggleLabels() {
    setState(() => _showLabels = !_showLabels);
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        _showSnack('🗺️ Membuka Google Maps...', Colors.blue);
      } else {
        throw Exception('Tidak bisa buka');
      }
    } catch (e) {
      _showSnack('❌ Gagal membuka Maps: $e', Colors.red);
    }
  }

  Future<void> _copyCoordinates(double lat, double lng) async {
    final txt = '$lat, $lng';
    await Clipboard.setData(ClipboardData(text: txt));
    _showSnack('📋 Disalin: $txt', Colors.green);
  }

  void _showMarkerInfo(TemuanModel temuan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MarkerDetailSheet(
        temuan: temuan,
        pinColor: _pinColor(temuan.tipeTemuan, temuan.levelRisiko),
        labelBgColor: _labelBgColor(temuan.tipeTemuan),
        onOpenMaps: () => _openGoogleMaps(temuan.latitude!, temuan.longitude!),
        onCopyCoords: () => _copyCoordinates(temuan.latitude!, temuan.longitude!),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildMap() {
    // Hide label if _showLabels == false
    final displayMarkers =
        _markers.map((m) {
          if (!_showLabels &&
              m.child is GestureDetector &&
              (m.child as GestureDetector).child is Column) {
            final col = (m.child as GestureDetector).child as Column;
            if (col.children.length >= 2) {
              final iconOnly = col.children.last;
              return Marker(
                point: m.point,
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: (m.child as GestureDetector).onTap,
                  child: iconOnly,
                ),
              );
            }
          }
          return m;
        }).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter:
                displayMarkers.isNotEmpty
                    ? (_currentLocationMarker?.point ??
                        displayMarkers.first.point)
                    : _center,
            initialZoom: displayMarkers.isNotEmpty ? 15 : 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.elsafe',
              maxZoom: 19,
            ),
            MarkerLayer(markers: displayMarkers),
          ],
        ),
        Positioned(
          left: 8,
          bottom: 6,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '© OpenStreetMap',
                style: TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Column(
            children: [
              MapControlButton(
                icon: Icons.my_location,
                tooltip: 'Lokasi Saya',
                onTap: _isGettingLocation ? null : _goToCurrentLocation,
                isBusy: _isGettingLocation,
              ),
              const SizedBox(height: 8),
              MapControlButton(
                icon: Icons.zoom_in,
                tooltip: 'Zoom In',
                onTap: _zoomIn,
              ),
              const SizedBox(height: 6),
              MapControlButton(
                icon: Icons.zoom_out,
                tooltip: 'Zoom Out',
                onTap: _zoomOut,
              ),
              const SizedBox(height: 6),
              MapControlButton(
                icon: Icons.center_focus_strong,
                tooltip: 'Fit Semua Marker',
                onTap: _fitAllMarkers,
              ),
              const SizedBox(height: 6),
              MapControlButton(
                icon: _showLabels ? Icons.label_important : Icons.label_off,
                tooltip: _showLabels ? 'Sembunyikan Label' : 'Tampilkan Label',
                onTap: _toggleLabels,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapDropdown({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required void Function(String) onSave,
    String Function(String)? itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: Colors.white70),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                '$label:',
                style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white, fontSize: 11),
            icon: const Icon(Icons.arrow_drop_down, size: 16, color: Colors.white70),
            items: items.map((item) {
              final display = itemBuilder != null ? itemBuilder(item) : item;
              return DropdownMenuItem(
                value: item,
                child: Text(display, style: const TextStyle(color: Colors.white, fontSize: 11)),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) setState(() { onSave(v); _createMarkers(); });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Peta Lokasi Temuan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _loadTemuanData,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                if (_isAdmin) ...[
                  Expanded(
                    child: _buildMapDropdown(
                      icon: Icons.location_on,
                      label: 'ULP',
                      value: _filterUlp,
                      items: _ulpOptions,
                      itemBuilder: (u) => u == 'Semua' ? 'Semua ULP' : u,
                      onSave: (v) { _filterUlp = v; _filterPenyulang = 'Semua'; },
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: _buildMapDropdown(
                    icon: Icons.assessment,
                    label: 'Status',
                    value: _filterStatus,
                    items: const ['Semua', 'Open', 'Closed'],
                    onSave: (v) => _filterStatus = v,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildMapDropdown(
                    icon: Icons.category,
                    label: 'Tipe',
                    value: _filterTipe,
                    items: const ['Semua', 'KMU', 'ROW'],
                    onSave: (v) => _filterTipe = v,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildMapDropdown(
                    icon: Icons.warning_amber,
                    label: 'Risiko',
                    value: _filterKategori,
                    items: const ['Semua', 'Medium', 'High', 'Extreme'],
                    onSave: (v) => _filterKategori = v,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildMapDropdown(
                    icon: Icons.electric_bolt,
                    label: 'Penyulang',
                    value: _filterPenyulang,
                    items: ['Semua', ..._penyulangOptions],
                    onSave: (v) => _filterPenyulang = v,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Info panel — satu baris: Total (kiri) + Legenda (kanan)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  'Total: ${_filteredTemuan.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Row(
                      children: [
                        _LegendItem(icon: Icons.bolt, color: Colors.red, label: 'Extreme'),
                        const SizedBox(width: 8),
                        _LegendItem(icon: Icons.bolt, color: Colors.orange, label: 'High'),
                        const SizedBox(width: 8),
                        _LegendItem(icon: Icons.bolt, color: Colors.amber, label: 'Medium'),
                        const SizedBox(width: 8),
                        _LegendItem(icon: Icons.location_on, color: Colors.green, label: 'ROW'),
                        const SizedBox(width: 8),
                        _LegendItem(icon: Icons.location_on, color: Colors.red, label: 'KMU'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.blue),
                          SizedBox(height: 16),
                          Text(
                            'Memuat data peta...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                    : Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[600]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildMap(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
