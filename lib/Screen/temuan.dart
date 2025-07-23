import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
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
  double? _currentLatitude;
  double? _currentLongitude;

  @override
  void dispose() {
    _lokasiController.dispose();
    _namaPemilikController.dispose();
    _deskripsiController.dispose();
    super.dispose();
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
        // ← GANTI DENGAN SnackBarUtils
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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

    setState(() {
      _isSubmitting = true;
    });

    try {
      SnackBarUtils.showLoading(context, message: 'Menyimpan data temuan...');

      final temuan = TemuanModel(
        lokasi: _lokasiController.text,
        namaPemilik: _namaPemilikController.text,
        tanggalTemuan: _selectedDate!,
        deskripsiTemuan: _deskripsiController.text,
        latitude: _currentLatitude,
        longitude: _currentLongitude,
      );

      final result = await _temuanService.createTemuanSilent(temuan);

      SnackBarUtils.hide(context);

      if (result['success']) {
        SnackBarUtils.showSuccess(
          context,
          title: 'Berhasil!',
          message: 'Data temuan berhasil disimpan',
        );
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
      
      SnackBarUtils.showError(
        context,
        title: 'Error!',
        message: e.toString(),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            width: screenWidth * 0.7,
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
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
                  const SizedBox(height: 8),
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

                  const SizedBox(height: 20),

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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
