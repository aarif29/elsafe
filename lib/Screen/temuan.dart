import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:file_picker/file_picker.dart';
import '../config/snackbar.dart';
import '../config/temuan_model.dart';
import '../config/temuan_service.dart';

class TemuanScreen extends StatefulWidget {
  const TemuanScreen({super.key});

  @override
  State<TemuanScreen> createState() => _TemuanScreenState();
}

class _TemuanScreenState extends State<TemuanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lokasiController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _temuanService = TemuanService();

  DateTime? _selectedDate;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  bool _showDateError = false;
  bool _showPhotoError = false;
  double? _currentLatitude;
  double? _currentLongitude;
  
  List<PlatformFile> _selectedPhotos = [];

  @override
  void dispose() {
    _lokasiController.dispose();
    _namaPemilikController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }
  Future<void> _pickImages() async {
    if (_selectedPhotos.length >= 3) {
      SnackBarUtils.showWarning(
        context,
        title: 'Peringatan!',
        message: 'Maksimal 3 foto',
      );
      return;
    }

    try {
      int remainingSlots = 3 - _selectedPhotos.length;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: true,
        withData: kIsWeb,
        withReadStream: !kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        List<PlatformFile> newPhotos = result.files.take(remainingSlots).toList();

        if (newPhotos.isNotEmpty) {
          setState(() {
            _selectedPhotos.addAll(newPhotos);
            _showPhotoError = false;
          });

          if (mounted) {
            SnackBarUtils.showSuccess(
              context,
              title: 'Berhasil!',
              message:
                  '${newPhotos.length} foto berhasil dipilih (${_selectedPhotos.length}/3)',
            );
          }

          for (var file in newPhotos) {
            if (kIsWeb) {
              print('📸 Web - File: ${file.name}, Size: ${file.bytes?.length ?? 0} bytes');
            } else {
              print('📸 Mobile - File: ${file.path}');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error picking images: $e');
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
    if (kIsWeb) {
      SnackBarUtils.showWarning(
        context,
        title: 'Info',
        message: 'Kamera tidak didukung di Web. Silakan pilih dari galeri.',
      );
      await _pickImages();
      return;
    }

    if (_selectedPhotos.length >= 3) {
      SnackBarUtils.showWarning(
        context,
        title: 'Peringatan!',
        message: 'Maksimal 3 foto',
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withReadStream: true,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedPhotos.add(result.files.single);
          _showPhotoError = false;
        });

        if (mounted) {
          SnackBarUtils.showSuccess(
            context,
            title: 'Berhasil!',
            message: 'Foto berhasil dipilih (${_selectedPhotos.length}/3)',
          );
        }
      }
    } catch (e) {
      print('❌ Error taking picture: $e');
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Error!',
          message: 'Gagal mengambil foto: ${e.toString()}',
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });

    SnackBarUtils.showSuccess(
      context,
      title: 'Berhasil!',
      message: 'Foto dihapus (${_selectedPhotos.length}/3)',
    );
  }

  void _showPhotoSourceDialog() {
    if (kIsWeb) {
      _pickImages();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text(
                  'Kamera',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _takePicture();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.green),
                ),
                title: const Text(
                  'Galeri',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImages();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Foto Temuan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: const Text(
                'Min. 1 foto',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Upload minimal 1 foto, maksimal 3 foto (${_selectedPhotos.length}/3)',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        const SizedBox(height: 12),

        // Grid Preview Foto
        if (_selectedPhotos.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedPhotos.length,
            itemBuilder: (context, index) {
              final platformFile = _selectedPhotos[index];
              
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                      color: Colors.grey[800],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: kIsWeb
                          ? (platformFile.bytes != null
                              ? Image.memory(
                                  platformFile.bytes!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ))
                          : (platformFile.path != null
                              ? Image.file(
                                  File(platformFile.path!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                )),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(index),
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
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

        const SizedBox(height: 12),

        // Tombol Tambah Foto
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _selectedPhotos.length < 3 ? _showPhotoSourceDialog : null,
            icon: Icon(
              Icons.add_photo_alternate,
              color: _selectedPhotos.length < 3 ? Colors.blue : Colors.grey,
            ),
            label: Text(
              _selectedPhotos.isEmpty
                  ? 'Tambah Foto (Wajib)'
                  : _selectedPhotos.length < 3
                      ? 'Tambah Foto Lagi'
                      : 'Maksimal 3 Foto',
              style: TextStyle(
                color: _selectedPhotos.length < 3 ? Colors.white : Colors.grey,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _showPhotoError && _selectedPhotos.isEmpty
                    ? Colors.red
                    : _selectedPhotos.length < 3
                        ? Colors.blue
                        : Colors.grey,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        if (_showPhotoError && _selectedPhotos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Minimal 1 foto harus diupload',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      var permission = await Permission.location.request();
      if (permission.isDenied) {
        throw Exception('Permission ditolak');
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
  Future<void> _submitForm() async {
    setState(() {
      _showPhotoError = _selectedPhotos.isEmpty;
      _showDateError = _selectedDate == null;
    });

    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedPhotos.isEmpty) {
      SnackBarUtils.showWarning(
        context,
        title: 'Peringatan!',
        message: 'Mohon lengkapi semua field yang diperlukan',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // ========== UPLOAD FOTO SATU PER SATU ==========
      List<String> uploadedUrls = [];

      for (int i = 0; i < _selectedPhotos.length; i++) {
        final platformFile = _selectedPhotos[i];

        SnackBarUtils.hide(context);
        SnackBarUtils.showLoading(
          context,
          message: 'Mengupload foto ${i + 1}/${_selectedPhotos.length}...',
        );

        final result = await _temuanService.uploadFoto(platformFile);

        if (result['success']) {
          uploadedUrls.add(result['url']);
          print('✅ Foto ${i + 1} berhasil diupload: ${result['url']}');
        } else {
          throw Exception('Gagal upload foto ${i + 1}: ${result['message']}');
        }
      }

      // ========== SIMPAN DATA TEMUAN ==========
      SnackBarUtils.hide(context);
      SnackBarUtils.showLoading(context, message: 'Menyimpan data temuan...');

      final temuan = TemuanModel(
        lokasi: _lokasiController.text,
        namaPemilik: _namaPemilikController.text,
        tanggalTemuan: _selectedDate!,
        deskripsiTemuan: _deskripsiController.text,
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        fotoUrls: uploadedUrls.isEmpty ? null : uploadedUrls,
      );

      final result = await _temuanService.createTemuan(temuan);

      SnackBarUtils.hide(context);

      if (result['success']) {
        SnackBarUtils.showSuccess(
          context,
          title: 'Berhasil!',
          message: 'Data temuan berhasil disimpan',
        );

        // Reset form
        _formKey.currentState!.reset();
        _lokasiController.clear();
        _namaPemilikController.clear();
        _deskripsiController.clear();
        setState(() {
          _selectedDate = null;
          _selectedPhotos.clear();
          _currentLatitude = null;
          _currentLongitude = null;
        });

        Navigator.of(context).pop(true);
      } else {
        SnackBarUtils.showError(
          context,
          title: 'Gagal!',
          message: result['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      SnackBarUtils.hide(context);
      SnackBarUtils.showError(context, title: 'Error!', message: e.toString());
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _clearForm() {
    _lokasiController.clear();
    _namaPemilikController.clear();
    _deskripsiController.clear();
    setState(() {
      _selectedDate = null;
      _currentLatitude = null;
      _currentLongitude = null;
      _showDateError = false;
      _showPhotoError = false;
      _selectedPhotos.clear();
    });
  }

  Widget _buildUserInfo() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _temuanService.getCurrentUserProfile(),
      builder: (context, snapshot) {
        String displayName = 'Unknown User';

        if (snapshot.hasData && snapshot.data != null) {
          final profile = snapshot.data!;
          final fullName = profile['full_name'] as String?;
          final nip = profile['nip'] as String?;

          if (fullName != null && fullName.isNotEmpty) {
            displayName = fullName;
          } else if (nip != null && nip.isNotEmpty) {
            displayName = nip;
          } else {
            displayName = _temuanService.currentUserEmail ?? 'Unknown User';
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          displayName = 'Loading...';
        } else {
          displayName = _temuanService.currentUserEmail ?? 'Unknown User';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Center(
            child: Text(
              'Dibuat oleh: $displayName',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Form Temuan'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _clearForm,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
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

                  // LOKASI
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
                      onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                      icon: _isLoadingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        _isLoadingLocation
                            ? 'Mengambil Lokasi...'
                            : 'Gunakan Lokasi Sekarang',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _pickLocationManually,
                      icon: const Icon(Icons.map, color: Colors.blue),
                      label: const Text(
                        'Pilih Lokasi dari Peta',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // NAMA PEMILIK
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

                  // TANGGAL
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
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        border: Border.all(
                          color: _showDateError && _selectedDate == null
                              ? Colors.red.withOpacity(0.5)
                              : Colors.grey[600]!,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Pilih tanggal temuan',
                            style: const TextStyle(color: Colors.white),
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

                  // FOTO SECTION
                  _buildPhotoSection(),

                  const SizedBox(height: 20),

                  // DESKRIPSI
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

                  const SizedBox(height: 24),

                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSubmitting ? Colors.grey : Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Menyimpan...'),
                              ],
                            )
                          : const Text(
                              'Simpan Temuan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
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
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tap pada peta untuk memilih lokasi',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lat: ${_selectedPosition.latitude.toStringAsFixed(6)}\n'
                    'Long: ${_selectedPosition.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmLocation,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Gunakan Lokasi Ini'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
