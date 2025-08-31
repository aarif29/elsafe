import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../profil/loginscreen.dart';
import '../profil/profil.dart';
import '../config/temuan_service.dart';
import '../config/temuan_model.dart';
import 'temuan.dart';
import 'daftar_temuan.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout Gagal: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showMapsView(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MapsViewWidget(),
    );
  }

  void _navigateToDaftarTemuan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DaftarTemuanScreen()),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Profile()),
    );
  }

  void _navigateToTambahTemuan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TemuanScreen()),
    );
  }

  void _closeDrawer(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: const Center(
        child: Text(
          'Selamat Datang di ELSAFE!',
            style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(color: Colors.grey[800]),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => _closeDrawer(context),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Profil',
            onTap: () {
              _closeDrawer(context);
              _navigateToProfile(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
        onPressed: () => _navigateToTambahTemuan(context),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        tooltip: 'Tambah Temuan',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.grey[900],
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.list, color: Colors.white),
              onPressed: () => _navigateToDaftarTemuan(context),
              tooltip: 'Daftar Temuan',
            ),
            IconButton(
              icon: const Icon(Icons.map, color: Colors.white),
              onPressed: () => _showMapsView(context),
              tooltip: 'Peta Temuan',
            ),
          ],
        ),
      ),
    );
  }
}

class MapsViewWidget extends StatefulWidget {
  const MapsViewWidget({super.key});

  @override
  State<MapsViewWidget> createState() => _MapsViewWidgetState();
}

class _MapsViewWidgetState extends State<MapsViewWidget> {
  final _temuanService = TemuanService();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _createMarkers() {
    _markers.clear();
    for (var temuan in _temuanList) {
      if (temuan.latitude != null && temuan.longitude != null) {
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
                  // Label (akan disembunyikan secara dinamis di _buildMap)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[700],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    if (_currentLocationMarker != null) {
      _markers.add(_currentLocationMarker!);
    }
  }

  Future<bool> _ensureLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ GPS tidak aktif. Aktifkan lokasi Anda.'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Izin lokasi ditolak.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Izin lokasi permanen ditolak. Buka pengaturan.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final ok = await _ensureLocationService();
      if (!ok) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal mengambil lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);

    final pos = await _getCurrentPosition();
    if (pos != null) {
      final current = LatLng(pos.latitude, pos.longitude);

      _currentLocationMarker = Marker(
        point: current,
        width: 50,
        height: 50,
        child: Container(
          alignment: Alignment.center,
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
        ),
      );

      setState(() {
        _createMarkers();
      });

      _mapController.move(current, 17);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Lokasi Anda ditemukan'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    if (mounted) setState(() => _isGettingLocation = false);
  }

  void _zoomIn() {
    final zoom = _mapController.camera.zoom + 1;
    _mapController.move(_mapController.camera.center, zoom.clamp(3, 19));
  }

  void _zoomOut() {
    final zoom = _mapController.camera.zoom - 1;
    _mapController.move(_mapController.camera.center, zoom.clamp(3, 19));
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
      minLat = m.point.latitude < minLat ? m.point.latitude : minLat;
      maxLat = m.point.latitude > maxLat ? m.point.latitude : maxLat;
      minLng = m.point.longitude < minLng ? m.point.longitude : minLng;
      maxLng = m.point.longitude > maxLng ? m.point.longitude : maxLng;
    }

    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    final latDiff = (maxLat - minLat).abs();
    final lngDiff = (maxLng - minLng).abs();
    double span = latDiff > lngDiff ? latDiff : lngDiff;

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

  Future<void> _openGoogleMaps(
    double latitude,
    double longitude,
    String lokasi,
  ) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: Text('🗺️ Membuka lokasi di Google Maps...'),
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Tidak dapat membuka Google Maps');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal membuka Google Maps: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _copyCoordinates(double latitude, double longitude) async {
    try {
      final coords = '$latitude, $longitude';
      await Clipboard.setData(ClipboardData(text: coords));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('📋 Koordinat disalin: $coords')),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('❌ Gagal menyalin koordinat')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMarkerInfo(TemuanModel temuan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text(
          temuan.namaPemilik,
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    border: Border.all(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              _openGoogleMaps(
                                temuan.latitude!,
                                temuan.longitude!,
                                temuan.lokasi,
                              );
                            },
                            icon: const Icon(
                              Icons.map,
                              size: 16,
                              color: Colors.green,
                            ),
                            label: const Text('Maps'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _copyCoordinates(
                                temuan.latitude!,
                                temuan.longitude!,
                              );
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
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
            child: const Text(
              'Tutup',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    // Transform markers kalau label disembunyikan
    final displayMarkers = _markers.map((m) {
      if (!_showLabels &&
          m.child is GestureDetector &&
          ((m.child as GestureDetector).child) is Column) {
        final col = ((m.child as GestureDetector).child) as Column;
        if (col.children.length >= 2) {
          final iconPart = col.children.last;
          return Marker(
            point: m.point,
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: (m.child as GestureDetector).onTap,
              child: iconPart,
            ),
          );
        }
      }
      return m;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: displayMarkers.isNotEmpty
                    ? (_currentLocationMarker?.point ?? displayMarkers.first.point)
                    : _center,
                initialZoom: displayMarkers.isNotEmpty ? 15.0 : 13.0,
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

            // Attribution kecil
            Positioned(
              left: 8,
              bottom: 6,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
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

            // Panel kontrol kanan atas
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                  _MapControlButton(
                    icon: Icons.my_location,
                    tooltip: 'Lokasi Saya',
                    onTap: _isGettingLocation ? null : _goToCurrentLocation,
                    isBusy: _isGettingLocation,
                  ),
                  const SizedBox(height: 8),
                  _MapControlButton(
                    icon: Icons.zoom_in,
                    tooltip: 'Zoom In',
                    onTap: _zoomIn,
                  ),
                  const SizedBox(height: 6),
                  _MapControlButton(
                    icon: Icons.zoom_out,
                    tooltip: 'Zoom Out',
                    onTap: _zoomOut,
                  ),
                  const SizedBox(height: 6),
                  _MapControlButton(
                    icon: Icons.center_focus_strong,
                    tooltip: 'Fit Semua Marker',
                    onTap: _fitAllMarkers,
                  ),
                  const SizedBox(height: 6),
                  _MapControlButton(
                    icon: _showLabels ? Icons.label_important : Icons.label_off,
                    tooltip: _showLabels ? 'Sembunyikan Label' : 'Tampilkan Label',
                    onTap: _toggleLabels,
                  ),
                ],
              ),
            ),

            // Gradient bawah halus (optional)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xAA000000),
                        Color(0x00000000),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
          Container(
            padding: const EdgeInsets.all(16),
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
                ),
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
                Text(
                  'Total Temuan: ${_temuanList.length}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Marker: ${_markers.length}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isBusy;

  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: disabled ? 0.55 : 1.0,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey[850]!.withOpacity(0.95),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white10,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
