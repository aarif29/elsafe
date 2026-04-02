import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../config/snackbar.dart';
import '../config/temuan_model.dart';
import '../config/temuan_service.dart';
import '../widgets/foto_grid_widget.dart';

class EditTemuanScreen extends StatefulWidget {
  final TemuanModel temuan;

  const EditTemuanScreen({super.key, required this.temuan});

  @override
  State<EditTemuanScreen> createState() => _EditTemuanScreenState();
}

class _EditTemuanScreenState extends State<EditTemuanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lokasiController;
  late TextEditingController _namaPemilikController;
  late TextEditingController _deskripsiController;
  late TextEditingController _nomorAmsController;
  final _temuanService = TemuanService();
  final ImagePicker _picker = ImagePicker();

  DateTime? _selectedDate;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  bool _showDateError = false;
  double? _currentLatitude;
  double? _currentLongitude;
  String _statusTemuan = 'Open';

  // ========== FOTO MANAGEMENT ==========
  List<String> _existingFotoUrls = [];
  List<XFile> _newFotoFiles = [];
  List<String> _deletedFotoUrls = [];
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _lokasiController = TextEditingController(text: widget.temuan.lokasi);
    _namaPemilikController = TextEditingController(
      text: widget.temuan.namaPemilik,
    );
    _deskripsiController = TextEditingController(
      text: widget.temuan.deskripsiTemuan,
    );

    _nomorAmsController = TextEditingController(
      text: widget.temuan.nomorAms ?? '',
    );
    _statusTemuan = widget.temuan.statusTemuan ?? 'Open';

    _selectedDate = widget.temuan.tanggalTemuan;
    _currentLatitude = widget.temuan.latitude;
    _currentLongitude = widget.temuan.longitude;

    if (widget.temuan.fotoUrls != null) {
      _existingFotoUrls = List.from(widget.temuan.fotoUrls!);
    }
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _namaPemilikController.dispose();
    _deskripsiController.dispose();
    _nomorAmsController.dispose();
    super.dispose();
  }

  // ========== FOTO FUNCTIONS ==========
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          _newFotoFiles.addAll(images);
        });

        if (mounted) {
          SnackBarUtils.showSuccess(
            context,
            title: 'Berhasil!',
            message: '${images.length} foto berhasil dipilih',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Error!',
          message: 'Gagal memilih foto: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _takePicture() async {
    try {
      if (kIsWeb) {
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.gallery, // ← TAMBAHKAN INI
          imageQuality: 80,
        );

        if (photo != null) {
          setState(() {
            _newFotoFiles.add(photo);
          });

          if (mounted) {
            SnackBarUtils.showSuccess(
              context,
              title: 'Berhasil!',
              message: 'Foto berhasil dipilih dari perangkat',
            );
          }
        }
      } else {
        // 📱 DI MOBILE: Buka kamera native
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera, // ← SUDAH BENAR
          imageQuality: 80,
        );

        if (photo != null) {
          setState(() {
            _newFotoFiles.add(photo);
          });

          if (mounted) {
            SnackBarUtils.showSuccess(
              context,
              title: 'Berhasil!',
              message: 'Foto berhasil diambil dari kamera',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Error!',
          message: 'Gagal mengambil foto: ${e.toString()}',
        );
      }
    }
  }

  void _deleteExistingFoto(String url) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text('Hapus Foto?', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: const Text(
              'Foto akan dihapus permanen saat Anda menyimpan perubahan. Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _existingFotoUrls.remove(url);
                    _deletedFotoUrls.add(url);
                  });

                  Navigator.pop(context);

                  SnackBarUtils.showSuccess(
                    context,
                    title: 'Ditandai untuk Dihapus',
                    message: 'Foto akan dihapus saat menyimpan',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  void _deleteNewFoto(XFile file) {
    setState(() {
      _newFotoFiles.remove(file);
    });

    SnackBarUtils.showSuccess(
      context,
      title: 'Berhasil!',
      message: 'Foto dibatalkan',
    );
  }

  int get _totalFotoCount => _existingFotoUrls.length + _newFotoFiles.length;

  // ========== LOCATION FUNCTIONS ==========
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      if (kIsWeb) {
        // 🌐 Di web, geolocator mungkin tidak support semua browser
        SnackBarUtils.showWarning(
          context,
          title: 'Peringatan!',
          message:
              'Gunakan "Pilih Lokasi dari Peta".',
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      var permission = await Permission.location.request();
      if (permission.isDenied) {
        throw Exception('Izin lokasi ditolak. Silakan aktifkan di pengaturan.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _lokasiController.text =
            'Lat: ${position.latitude.toStringAsFixed(6)}, '
            'Long: ${position.longitude.toStringAsFixed(6)}';
      });

      if (mounted) {
        SnackBarUtils.showSuccess(
          context,
          title: 'Berhasil!',
          message: 'Lokasi berhasil didapatkan',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Error!',
          message: e.toString(),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _pickLocationManually() async {
    LatLng initialPosition = LatLng(
      _currentLatitude ?? -6.2088,
      _currentLongitude ?? 106.8456,
    );

    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(initialPosition: initialPosition),
      ),
    );

    if (result != null) {
      setState(() {
        _currentLatitude = result.latitude;
        _currentLongitude = result.longitude;
        _lokasiController.text =
            'Lat: ${result.latitude.toStringAsFixed(6)}, '
            'Long: ${result.longitude.toStringAsFixed(6)}';
      });

      if (mounted) {
        SnackBarUtils.showSuccess(
          context,
          title: 'Berhasil!',
          message: 'Lokasi berhasil dipilih dari peta',
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _showDateError = false;
      });
    }
  }

  // ========== SUBMIT FORM ==========
  Future<void> _submitForm() async {
    setState(() {
      _showDateError = _selectedDate == null;
    });

    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      SnackBarUtils.showWarning(
        context,
        title: 'Peringatan!',
        message: 'Mohon lengkapi semua field yang diperlukan',
      );
      return;
    }

    final bool hasChanges =
        _newFotoFiles.isNotEmpty ||
        _deletedFotoUrls.isNotEmpty ||
        _lokasiController.text != widget.temuan.lokasi ||
        _namaPemilikController.text != widget.temuan.namaPemilik ||
        _deskripsiController.text != widget.temuan.deskripsiTemuan ||
        _selectedDate != widget.temuan.tanggalTemuan ||
        _nomorAmsController.text != (widget.temuan.nomorAms ?? '') ||
        _statusTemuan != (widget.temuan.statusTemuan ?? 'Open');

    if (!hasChanges) {
      SnackBarUtils.showInfo(
        context,
        title: 'Info',
        message: 'Tidak ada perubahan yang dilakukan',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      SnackBarUtils.showLoading(context, message: 'Memperbarui data temuan...');

      List<String> newUploadedUrls = [];
      List<String> failedUploads = [];

      if (_newFotoFiles.isNotEmpty) {
        setState(() {
          _isUploadingPhoto = true;
        });

        for (int i = 0; i < _newFotoFiles.length; i++) {
          final xfile = _newFotoFiles[i];
          try {
            final result = await _temuanService.uploadFoto(xfile);

            if (result['success']) {
              newUploadedUrls.add(result['url']);
              print('✅ Foto ${i + 1} berhasil diupload');
            } else {
              failedUploads.add('Foto ${i + 1}');
              print('❌ Foto ${i + 1} gagal: ${result['message']}');
            }
          } catch (e) {
            failedUploads.add('Foto ${i + 1}');
            debugPrint('❌ Error uploading foto ${i + 1}: $e');
          }
        }

        setState(() {
          _isUploadingPhoto = false;
        });

        if (failedUploads.isNotEmpty && mounted) {
          SnackBarUtils.hide(context);
          SnackBarUtils.showWarning(
            context,
            title: 'Peringatan!',
            message:
                '${failedUploads.length} foto gagal diupload: ${failedUploads.join(", ")}',
          );
          await Future.delayed(const Duration(seconds: 2));
          SnackBarUtils.showLoading(
            context,
            message: 'Melanjutkan pembaruan...',
          );
        }
      }

      final allFotoUrls = [..._existingFotoUrls, ...newUploadedUrls];

      final updatedTemuan = TemuanModel(
        id: widget.temuan.id,
        lokasi: _lokasiController.text,
        namaPemilik: _namaPemilikController.text,
        tanggalTemuan: _selectedDate!,
        deskripsiTemuan: _deskripsiController.text,
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        fotoUrls: allFotoUrls.isEmpty ? null : allFotoUrls,
        nomorAms:
            _nomorAmsController.text.isEmpty ? null : _nomorAmsController.text,
        statusTemuan: _statusTemuan,
      );

      final result = await _temuanService.updateTemuan(
        widget.temuan.id!,
        updatedTemuan,
      );

      if (_deletedFotoUrls.isNotEmpty) {
        for (var url in _deletedFotoUrls) {
          try {
            await _temuanService.deleteFoto(url);
          } catch (e) {
            debugPrint('Error deleting foto: $e');
          }
        }
      }

      SnackBarUtils.hide(context);

      if (result['success']) {
        SnackBarUtils.showSuccess(
          context,
          title: 'Berhasil!',
          message:
              failedUploads.isEmpty
                  ? 'Data temuan berhasil diperbarui'
                  : 'Data temuan diperbarui (${failedUploads.length} foto gagal diupload)',
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        SnackBarUtils.showError(
          context,
          title: 'Gagal!',
          message: result['message'] ?? 'Terjadi kesalahan saat memperbarui',
        );
      }
    } catch (e) {
      SnackBarUtils.hide(context);

      SnackBarUtils.showError(
        context,
        title: 'Error!',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isUploadingPhoto = false;
        });
      }
    }
  }

  // ========== BUILD UI ==========
  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mengedit data: ${widget.temuan.namaPemilik}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Foto Temuan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    _totalFotoCount > 0
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      _totalFotoCount > 0
                          ? Colors.blue.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Text(
                '$_totalFotoCount foto',
                style: TextStyle(
                  color: _totalFotoCount > 0 ? Colors.blue : Colors.grey[400],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Tombol Tambah Foto
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _isUploadingPhoto || _isSubmitting ? null : _pickImages,
                icon: const Icon(
                  Icons.photo_library,
                  color: Colors.blue,
                  size: 20,
                ),
                label: const Text(
                  'Pilih dari Galeri',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color:
                        _isUploadingPhoto || _isSubmitting
                            ? Colors.grey
                            : Colors.blue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _isUploadingPhoto || _isSubmitting ? null : _takePicture,
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.green,
                  size: 20,
                ),
                label: Text(
                  kIsWeb ? 'Ambil dari Perangkat' : 'Ambil Foto',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color:
                        _isUploadingPhoto || _isSubmitting
                            ? Colors.grey
                            : Colors.green,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Display Existing Photos
        if (_existingFotoUrls.isNotEmpty) ...[
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Foto yang Sudah Ada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_existingFotoUrls.length})',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FotoGridWidget(
            fotoUrls: _existingFotoUrls,
            isEditable: !_isSubmitting,
            onDelete: _deleteExistingFoto,
          ),
          const SizedBox(height: 16),
        ],

        // Display New Photos
        if (_newFotoFiles.isNotEmpty) ...[
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Foto Baru (Belum Disimpan)',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_newFotoFiles.length})',
                style: const TextStyle(color: Colors.orange, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _newFotoFiles.length,
            itemBuilder: (context, index) {
              final xfile = _newFotoFiles[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        kIsWeb
                            ? Image.network(
                              xfile.path,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Preview\nTidak Tersedia',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : FutureBuilder<File>(
                              future: Future.value(File(xfile.path)),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.file(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  );
                                }
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                  // Badge "Baru"
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Text(
                        'BARU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Delete button
                  if (!_isSubmitting)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _deleteNewFoto(xfile),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // Peringatan jika ada foto yang akan dihapus
        if (_deletedFotoUrls.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_deletedFotoUrls.length} foto akan dihapus permanen',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        // Empty state
        if (_totalFotoCount == 0)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text('Belum ada foto', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text(
                    'Tambahkan foto temuan',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Temuan'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: screenWidth > 600 ? screenWidth * 0.7 : double.infinity,
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildUserInfo(),
                  _buildFotoSection(),

                  // ========== LOKASI SECTION ==========
                  const Text(
                    'Lokasi Temuan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _lokasiController,
                    style: const TextStyle(color: Colors.white),
                    enabled: !_isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'Lokasi',
                      labelStyle: const TextStyle(color: Colors.white),
                      hintText: 'Masukkan lokasi atau gunakan GPS',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lokasi harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoadingLocation || _isSubmitting
                              ? null
                              : _getCurrentLocation,
                      icon:
                          _isLoadingLocation
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.my_location, size: 20),
                      label: Text(
                        _isLoadingLocation
                            ? 'Mengambil Lokasi...'
                            : kIsWeb
                            ? 'Pilih lokasi sekarang'
                            : 'Gunakan Lokasi Sekarang',
                        style: const TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: Colors.grey[700],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _pickLocationManually,
                      icon: const Icon(Icons.map, color: Colors.blue, size: 20),
                      label: const Text(
                        'Pilih Lokasi dari Peta',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: _isSubmitting ? Colors.grey : Colors.blue,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ========== NAMA PEMILIK ==========
                  const Text(
                    'Nama Pemilik',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _namaPemilikController,
                    style: const TextStyle(color: Colors.white),
                    enabled: !_isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'Nama Pemilik',
                      labelStyle: const TextStyle(color: Colors.white),
                      hintText: 'Masukkan nama pemilik',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      prefixIcon: const Icon(Icons.person, color: Colors.blue),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama pemilik harus diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // ========== TANGGAL ==========
                  const Text(
                    'Tanggal Temuan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _isSubmitting ? null : _selectDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            _isSubmitting ? Colors.grey[850] : Colors.grey[800],
                        border: Border.all(
                          color:
                              _showDateError && _selectedDate == null
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.grey[600]!,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: _isSubmitting ? Colors.grey : Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Pilih tanggal temuan',
                            style: TextStyle(
                              color: _isSubmitting ? Colors.grey : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showDateError && _selectedDate == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8, left: 12),
                      child: Text(
                        'Tanggal temuan harus dipilih',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ========== DESKRIPSI ==========
                  const Text(
                    'Deskripsi Temuan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _deskripsiController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    enabled: !_isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Temuan',
                      labelStyle: const TextStyle(color: Colors.white),
                      hintText: 'Jelaskan detail temuan',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      prefixIcon: const Icon(
                        Icons.description,
                        color: Colors.blue,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi harus diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // ========== NOMOR AMS ==========
                  Row(
                    children: [
                      const Text(
                        'Nomor AMS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'Tindak Lanjut',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nomorAmsController,
                    style: const TextStyle(color: Colors.white),
                    enabled: !_isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'Nomor AMS',
                      labelStyle: const TextStyle(color: Colors.white),
                      hintText: 'Masukkan nomor AMS',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[600]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      prefixIcon: const Icon(
                        Icons.confirmation_number,
                        color: Colors.orange,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Text(
                        'Status Temuan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _statusTemuan == 'Open'
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                _statusTemuan == 'Open'
                                    ? Colors.red
                                    : Colors.green,
                          ),
                        ),
                        child: Text(
                          _statusTemuan,
                          style: TextStyle(
                            color:
                                _statusTemuan == 'Open'
                                    ? Colors.red
                                    : Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[600]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _statusTemuan,
                        isExpanded: true,
                        dropdownColor: Colors.grey[850],
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: _isSubmitting ? Colors.grey : Colors.white,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Open',
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Open'),
                                const SizedBox(width: 8),
                                Text(
                                  '(Belum Selesai)',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Close',
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Close'),
                                const SizedBox(width: 8),
                                Text(
                                  '(Sudah Selesai)',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onChanged:
                            _isSubmitting
                                ? null
                                : (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _statusTemuan = newValue;
                                    });
                                  }
                                },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ========== SUBMIT BUTTON ==========
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isSubmitting ? Colors.grey[700] : Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: _isSubmitting ? 0 : 2,
                      ),
                      child:
                          _isSubmitting
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isUploadingPhoto
                                        ? 'Mengupload foto...'
                                        : 'Memperbarui...',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              )
                              : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Perbarui Temuan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ========== MAP PICKER SCREEN ==========
class MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapPickerScreen({Key? key, required this.initialPosition})
    : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _selectedPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  void _confirmLocation() {
    Navigator.pop(context, _selectedPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pilih Lokasi Temuan'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: _confirmLocation,
            tooltip: 'Konfirmasi Lokasi',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition,
              initialZoom: 15.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.elsafe',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tap pada peta untuk memilih lokasi',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Latitude:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _selectedPosition.latitude.toStringAsFixed(6),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Longitude:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _selectedPosition.longitude.toStringAsFixed(6),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmLocation,
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text(
                        'Gunakan Lokasi Ini',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
