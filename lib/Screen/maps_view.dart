// lib/Screen/maps_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/temuan_service.dart';
import '../config/temuan_model.dart';
import '../config/location_service.dart';
import '../widgets/maps_control_button.dart';

class MapsViewWidget extends StatefulWidget {
  const MapsViewWidget({super.key});

  @override
  State<MapsViewWidget> createState() => _MapsViewWidgetState();
}

class _MapsViewWidgetState extends State<MapsViewWidget> {
  final _temuanService = TemuanService();
  final _locationService = LocationService();
  final MapController _mapController = MapController();

  List<TemuanModel> _temuanList = [];
  List<Marker> _markers = [];
  Marker? _currentLocationMarker;

  bool _isLoading = true;
  bool _isGettingLocation = false;
  bool _showLabels = true;

  final LatLng _center = const LatLng(-7.9666, 112.6326);

  @override
  void initState() {
    super.initState();
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

  void _createMarkers() {
    _markers.clear();
    for (final temuan in _temuanList) {
      if (temuan.latitude == null || temuan.longitude == null) continue;
      _markers.add(
        Marker(
          point: LatLng(temuan.latitude!, temuan.longitude!),
            width: 120,
            height: 60,
            child: GestureDetector(
              onTap: () => _showMarkerInfo(temuan),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[700],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
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
                  const Icon(Icons.location_on, color: Colors.red, size: 32),
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
                color: Colors.blue.withOpacity(0.25),
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
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          temuan.namaPemilik,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lokasi: ${temuan.lokasi}', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                'Tanggal: ${temuan.tanggalTemuan.day}/${temuan.tanggalTemuan.month}/${temuan.tanggalTemuan.year}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text('Deskripsi: ${temuan.deskripsiTemuan}',
                  style: const TextStyle(color: Colors.white)),
              if (temuan.latitude != null && temuan.longitude != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Koordinat: ${temuan.latitude}, ${temuan.longitude}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _openGoogleMaps(temuan.latitude!, temuan.longitude!);
                            },
                            icon: const Icon(Icons.map, size: 16, color: Colors.green),
                            label: const Text('Maps'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _copyCoordinates(temuan.latitude!, temuan.longitude!);
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.blue)),
          ),
        ],
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
    final displayMarkers = _markers.map((m) {
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
            initialCenter: displayMarkers.isNotEmpty
                ? (_currentLocationMarker?.point ?? displayMarkers.first.point)
                : _center,
            initialZoom: displayMarkers.isNotEmpty ? 15 : 13,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
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
                color: Colors.black.withOpacity(0.35),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Peta Lokasi Temuan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _loadTemuanData,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'Refresh',
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: 'Tutup',
                    ),
                  ],
                )
              ],
            ),
          ),
          // Info panel
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Temuan: ${_temuanList.length}',
                      style: const TextStyle(color: Colors.white)),
                  Text('Marker: ${_markers.length}',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.blue),
                        SizedBox(height: 16),
                        Text('Memuat data peta...',
                            style: TextStyle(color: Colors.white)),
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
