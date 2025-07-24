// UPDATE UNTUK MapsViewWidget di dashboard.dart
// Ganti method _showMarkerInfo dengan yang ini:

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // ✅ TAMBAHKAN INI untuk Copy
import 'package:url_launcher/url_launcher.dart';  // ✅ TAMBAHKAN INI untuk Maps
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
      MaterialPageRoute(
        builder: (context) => const DaftarTemuanScreen(),
      ),
    );
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
            icon: const Icon(Icons.map_outlined),
            onPressed: () => _showMapsView(context),
            tooltip: 'Lihat Peta',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
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
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.white),
              title: const Text(
                'Dashboard',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Profil',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.white),
              title: const Text(
                'Daftar Temuan',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToDaftarTemuan(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.white),
              title: const Text(
                'Peta Temuan',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showMapsView(context);
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Selamat Datang di Halaman Utama!',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TemuanScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          tooltip: 'Tambah Temuan',
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
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
  List<TemuanModel> _temuanList = [];
  List<Marker> _markers = [];
  bool _isLoading = true;
  
  final LatLng _center = const LatLng(-7.9666, 112.6326);

  @override
  void initState() {
    super.initState();
    _loadTemuanData();
  }

  Future<void> _loadTemuanData() async {
    try {
      print('🗺️ Loading data untuk maps...');
      
      final result = await _temuanService.getAllTemuanSilent();
      
      if (result['success']) {
        setState(() {
          _temuanList = result['data'] ?? [];
          _createMarkers();
          _isLoading = false;
        });
        
        print('✅ Berhasil load ${_temuanList.length} temuan untuk maps');
      } else {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error loading data untuk maps: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _createMarkers() {
    _markers.clear();
    
    for (var temuan in _temuanList) {
      if (temuan.latitude != null && temuan.longitude != null) {
        try {
          _markers.add(
            Marker(
              point: LatLng(temuan.latitude!, temuan.longitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showMarkerInfo(temuan),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
          );
          
          print('📍 Marker ditambahkan: ${temuan.latitude}, ${temuan.longitude}');
        } catch (e) {
          print('❌ Error parsing koordinat untuk temuan ${temuan.id}: $e');
        }
      }
    }
    
    print('🗺️ Total markers: ${_markers.length}');
  }

  // ✅ FUNGSI BARU: Open Google Maps (sama seperti di DaftarTemuanScreen)
  Future<void> _openGoogleMaps(double latitude, double longitude, String lokasi) async {
    try {
      final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      final Uri uri = Uri.parse(googleMapsUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
                child: Text(
                  '🗺️ Membuka lokasi di Google Maps...',
                  textAlign: TextAlign.center,
                ),
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
      print('❌ Error membuka Google Maps: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                '❌ Gagal membuka Google Maps: ${e.toString()}',
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ✅ FUNGSI BARU: Copy Coordinates (sama seperti di DaftarTemuanScreen)
  Future<void> _copyCoordinates(double latitude, double longitude) async {
    try {
      final coordinates = '$latitude, $longitude';
      await Clipboard.setData(ClipboardData(text: coordinates));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              '📋 Koordinat disalin: $coordinates',
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text(
              '❌ Gagal menyalin koordinat',
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ UPDATE: _showMarkerInfo dengan Maps & Copy buttons
  void _showMarkerInfo(TemuanModel temuan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text(
          temuan.namaPemilik,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lokasi: ${temuan.lokasi}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Tanggal: ${temuan.tanggalTemuan.day}/${temuan.tanggalTemuan.month}/${temuan.tanggalTemuan.year}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              'Deskripsi: ${temuan.deskripsiTemuan}',
              style: const TextStyle(color: Colors.white),
            ),
            
            // ✅ TAMBAHAN: Koordinat dengan tombol aksi (sama seperti di DaftarTemuanScreen)
            if (temuan.latitude != null && temuan.longitude != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 2), // Border merah seperti screenshot
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
                        // ✅ Tombol Google Maps
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Tutup dialog dulu
                            _openGoogleMaps(temuan.latitude!, temuan.longitude!, temuan.lokasi);
                          },
                          icon: const Icon(Icons.map, size: 16, color: Colors.green),
                          label: const Text('Maps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        // ✅ Tombol Copy Koordinat
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Tutup dialog dulu
                            _copyCoordinates(temuan.latitude!, temuan.longitude!);
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
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
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _markers.isNotEmpty 
                              ? _markers.first.point 
                              : _center,
                          initialZoom: _markers.isNotEmpty ? 15.0 : 13.0,
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
                          MarkerLayer(markers: _markers),
                          RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}