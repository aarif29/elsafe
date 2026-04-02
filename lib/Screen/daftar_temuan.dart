import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/temuan_service.dart';
import '../config/temuan_model.dart';
import '../widgets/foto_grid_widget.dart';
import 'temuan.dart';
import 'edit_temuan.dart';

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

  Future<void> _openGoogleMaps(
    double latitude,
    double longitude,
    String lokasi,
  ) async {
    try {
      final String googleMapsUrlWithLabel =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$lokasi';

      final Uri uri = Uri.parse(googleMapsUrlWithLabel);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

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
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            _temuanList = [];
            _errorMessage = result['message'] ?? 'Error tidak diketahui';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ $_errorMessage'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
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
            duration: const Duration(seconds: 3),
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
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data ini?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
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
              child: Text('🗑️ Menghapus data...', textAlign: TextAlign.center),
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

  // ==================== SHOW DETAIL DIALOG (UPDATED) ====================
  void _showDetailDialog(TemuanModel temuan) {
    // Tentukan status dan warna
    final String status = temuan.statusTemuan ?? 'Open';
    final bool isOpen = status == 'Open';
    final Color statusColor = isOpen ? Colors.red : Colors.green;
    final IconData statusIcon = isOpen ? Icons.lock_open : Icons.lock;
    final String statusText = isOpen ? 'Belum Selesai' : 'Sudah Selesai';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[900],
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
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        temuan.namaPemilik,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content (Scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========== FOTO SECTION ==========
                      if (temuan.fotoUrls != null &&
                          temuan.fotoUrls!.isNotEmpty) ...[
                        const Text(
                          '📸 Foto Temuan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FotoGridWidget(
                          fotoUrls: temuan.fotoUrls!,
                          isEditable: false,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ========== INFO SECTION ==========
                      _buildInfoRow('📍 Lokasi', temuan.lokasi),
                      _buildInfoRow(
                        '📅 Tanggal',
                        '${temuan.tanggalTemuan.day}/${temuan.tanggalTemuan.month}/${temuan.tanggalTemuan.year}',
                      ),
                      _buildInfoRow('📝 Deskripsi', temuan.deskripsiTemuan),

                      // ========== NOMOR AMS (BARU) ==========
                      if (temuan.nomorAms != null &&
                          temuan.nomorAms!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.confirmation_number,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nomor AMS',
                                      style: TextStyle(
                                        color: Colors.orange[300],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      temuan.nomorAms!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ========== KOORDINAT SECTION ==========
                      if (temuan.latitude != null &&
                          temuan.longitude != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🗺️ Koordinat GPS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${temuan.latitude}, ${temuan.longitude}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _openGoogleMaps(
                                          temuan.latitude!,
                                          temuan.longitude!,
                                          temuan.lokasi,
                                        );
                                      },
                                      icon: const Icon(Icons.map, size: 18),
                                      label: const Text('Buka Maps'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _copyCoordinates(
                                          temuan.latitude!,
                                          temuan.longitude!,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.copy,
                                        size: 18,
                                      ),
                                      label: const Text('Copy'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ========== STATUS TEMUAN (BARU) ==========
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor.withOpacity(0.2),
                              statusColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                statusIcon,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status Temuan',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  statusColor.withOpacity(0.3),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          statusText,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
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
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
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
            // ========== THUMBNAIL FOTO ==========
            leading: (temuan.fotoUrls != null && temuan.fotoUrls!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      temuan.fotoUrls!.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[700],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),

            title: Row(
              children: [
                Expanded(
                  child: Text(
                    temuan.namaPemilik,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Badge jumlah foto (jika lebih dari 1)
                if (temuan.fotoUrls != null && temuan.fotoUrls!.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${temuan.fotoUrls!.length - 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(temuan.lokasi, style: TextStyle(color: Colors.grey[300])),
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Edit
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTemuanScreen(temuan: temuan),
                      ),
                    );

                    if (result == true) {
                      _loadData();
                    }
                  },
                ),
                // Tombol Delete
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTemuan(temuan.id!),
                ),
              ],
            ),
            onTap: () => _showDetailDialog(temuan),
          ),
        );
      },
    );
  }
}
