import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/temuan_service.dart';
import '../config/temuan_model.dart';
import 'temuan.dart';

class DaftarTemuanScreen extends StatefulWidget {
  const DaftarTemuanScreen({super.key});

  @override
  _DaftarTemuanScreenState createState() => _DaftarTemuanScreenState();
}

class _DaftarTemuanScreenState extends State<DaftarTemuanScreen> {
  final _temuanService = TemuanService();
  List<TemuanModel> _temuanList = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasLoadedOnce = false;

  // Fungsi untuk membuka Google Maps
  Future<void> _openGoogleMaps(double latitude, double longitude, String lokasi) async {
    try {
      // URL untuk Google Maps dengan koordinat
      final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      
      // URL alternatif dengan label lokasi
      final String googleMapsUrlWithLabel = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$lokasi';
      
      final Uri uri = Uri.parse(googleMapsUrl);
      
      // Cek apakah bisa dibuka
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Buka di app Google Maps jika ada
        );
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

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
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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

  @override
  void initState() {
    super.initState();
    print('🔄 DaftarTemuanScreen initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      print('🔄 didChangeDependencies - loading data...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }

  Future<void> _loadData() async {
    print('🔄 Memulai _loadData...');
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _temuanService.getAllTemuanSilent();
      
      print('📦 Result dari service: $result');
      
      if (mounted) {  
        setState(() {
          if (result['success']) {
            _temuanList = result['data'] ?? [];
            _errorMessage = null;
            
            if (_temuanList.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text(
                      '✅ Berhasil memuat ${_temuanList.length} data temuan',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            _temuanList = [];
            _errorMessage = result['message'] ?? 'Error tidak diketahui';
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${_errorMessage}'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error di _loadData: $e');
      
      if (mounted) {
        setState(() {
          _temuanList = [];
          _errorMessage = 'Error: ${e.toString()}';
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteTemuan(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: const Text('Konfirmasi Hapus', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text(
          '🗑️ Menghapus data...',
          textAlign: TextAlign.center,
              ),
            ),
            duration: Duration(seconds: 1),
          ),
        );

        final result = await _temuanService.deleteTemuanSilent(id);
        
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Center(
              child: Text(
                '✅ Data berhasil dihapus',
                textAlign: TextAlign.center,
              ),
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
              child: Text(
                '❌ Gagal menghapus: ${result['message']}',
                textAlign: TextAlign.center,
              ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Daftar Temuan'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TemuanScreen()),
          );
          
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Memuat data temuan...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_temuanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Data Temuan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan temuan pertama Anda',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _temuanList.length,
      itemBuilder: (context, index) {
        final temuan = _temuanList[index];
        return Card(
          color: Colors.grey[800],
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              temuan.namaPemilik,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  temuan.lokasi,
                  style: TextStyle(color: Colors.grey[300]),
                ),
                const SizedBox(height: 2),
                Text(
                  '${temuan.tanggalTemuan.day}/${temuan.tanggalTemuan.month}/${temuan.tanggalTemuan.year}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 2),
                Text(
                  temuan.deskripsiTemuan,
                  style: TextStyle(color: Colors.grey[400]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTemuan(temuan.id!),
            ),
            onTap: () {
              // Detail view dengan opsi Google Maps
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[800],
                  title: Text(
                    temuan.namaPemilik, 
                    style: TextStyle(color: Colors.white)
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lokasi: ${temuan.lokasi}', style: TextStyle(color: Colors.white)),
                      Text('Tanggal: ${temuan.tanggalTemuan.day}/${temuan.tanggalTemuan.month}/${temuan.tanggalTemuan.year}', style: TextStyle(color: Colors.white)),
                      Text('Deskripsi: ${temuan.deskripsiTemuan}', style: TextStyle(color: Colors.white)),
                      
                      // Koordinat dengan tombol aksi
                      if (temuan.latitude != null && temuan.longitude != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(8),
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
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Tombol Google Maps
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context); // Tutup dialog dulu
                                      _openGoogleMaps(temuan.latitude!, temuan.longitude!, temuan.lokasi);
                                    },
                                    icon: Icon(Icons.map, size: 16, color: Colors.green),
                                    label: Text('Maps'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[800],
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                  // Tombol Copy Koordinat
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context); // Tutup dialog dulu
                                      _copyCoordinates(temuan.latitude!, temuan.longitude!);
                                    },
                                    icon: Icon(Icons.copy, size: 16),
                                    label: Text('Copy'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[800],
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            },
          ),
        );
      },
    );
  }
}
