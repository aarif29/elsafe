import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:file_picker/file_picker.dart';
import '../config/snackbar.dart';
import '../widgets/foto_picker_widget.dart';
import '../widgets/matriks_risiko_widget.dart';
import '../config/temuan_model.dart';
import '../config/temuan_types.dart';
import '../config/temuan_service.dart';
import '../config/sosialisasi_model.dart';
import '../config/notification_service.dart';
import '../config/ulp_service.dart';

class TemuanScreen extends StatefulWidget {
  final String tipeTemuan;

  const TemuanScreen({super.key, required this.tipeTemuan});

  @override
  State<TemuanScreen> createState() => _TemuanScreenState();
}

class _TemuanScreenState extends State<TemuanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lokasiController = TextEditingController();
  final _alamatTemuanController = TextEditingController();
  final _namaPemilikController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _nomorAmsController = TextEditingController();
  final _temuanService = TemuanService();
  final _pageController = PageController();

  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1 - Temuan
  DateTime? _selectedDate;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  bool _showDateError = false;
  bool _showPhotoError = false;
  bool _isAdmin = false;
  double? _currentLatitude;
  double? _currentLongitude;
  List<PlatformFile> _selectedPhotos = [];
  Future<Map<String, dynamic>?>? _userProfileFuture;

  // Jaringan listrik
  String? _currentUlp;
  String? _namaPenyulang;
  int? _section;
  int? _zona;

  // Matriks risiko
  String? _jarakAktivitas;
  String? _intensitasAktivitas;
  String? _jenisObjek;
  String? _jenisAset;
  String? _lokasiObjek;
  int _skorMatriks = 0;
  String? _levelRisiko;

  // Step 2 - Reminder
  DateTime? _tglReminder;
  List<PlatformFile> _fotoReminder = [];

  // Step 3 - Closing
  String? _jenisClosing;
  DateTime? _tglClosing;
  List<PlatformFile> _fotoClosing = [];

  // Step 4 - Sosialisasi
  DateTime? _tglSosialisasi;
  List<PlatformFile> _fotoSosialisasi = [];

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _temuanService.getCurrentUserProfile();
    UlpService().getCurrentUserProfile().then((profile) {
      if (profile != null && mounted) {
        setState(() {
          _currentUlp = profile['ulp'] as String?;
          _isAdmin = profile['role'] == 'admin';
        });
      }
    });
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _alamatTemuanController.dispose();
    _namaPemilikController.dispose();
    _deskripsiController.dispose();
    _nomorAmsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step < 0 || step >= _totalSteps) return;
    // Validasi step 1 sebelum lanjut
    if (_currentStep == 0 && step > 0) {
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
          message: 'Lengkapi data temuan di Step 1 terlebih dahulu',
        );
        return;
      }
    }
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      var permission = await Permission.location.request();
      if (permission.isDenied) throw Exception('Permission ditolak');

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final lokasiText =
          'Lat: ${position.latitude.toStringAsFixed(6)}, '
          'Long: ${position.longitude.toStringAsFixed(6)}';
      final alamatText = await _addressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _lokasiController.text = lokasiText;
        if (_alamatTemuanController.text.trim().isEmpty &&
            alamatText.isNotEmpty) {
          _alamatTemuanController.text = alamatText;
        }
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
      setState(() => _isLoadingLocation = false);
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
      final lokasiText =
          'Lat: ${result.latitude.toStringAsFixed(6)}, '
          'Long: ${result.longitude.toStringAsFixed(6)}';
      final alamatText = await _addressFromCoordinates(
        result.latitude,
        result.longitude,
      );

      setState(() {
        _currentLatitude = result.latitude;
        _currentLongitude = result.longitude;
        _lokasiController.text = lokasiText;
        if (_alamatTemuanController.text.trim().isEmpty &&
            alamatText.isNotEmpty) {
          _alamatTemuanController.text = alamatText;
        }
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

  Future<String> _addressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return '';
      final p = placemarks.first;
      final parts =
          [
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
          ].where((s) => s != null && s.isNotEmpty).cast<String>().toList();
      return parts.join(', ');
    } catch (_) {
      return '';
    }
  }

  Future<DateTime?> _pickDate({DateTime? initial}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    return picked;
  }

  Future<List<String>> _uploadFiles(
    List<PlatformFile> files,
    String label,
  ) async {
    List<String> urls = [];
    for (int i = 0; i < files.length; i++) {
      if (!mounted) break;
      SnackBarUtils.hide(context);
      SnackBarUtils.showLoading(
        context,
        message: 'Mengupload $label ${i + 1}/${files.length}...',
      );
      final result = await _temuanService.uploadFoto(files[i]);
      if (result['success']) {
        urls.add(result['url']);
      } else {
        throw Exception('Gagal upload $label ${i + 1}: ${result['message']}');
      }
    }
    return urls;
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _submitForm() async {
    if (_isAdmin) {
      SnackBarUtils.showError(
        context,
        title: 'Akses ditolak',
        message: 'Admin hanya dapat melihat data temuan',
      );
      return;
    }

    // Validasi step 1
    setState(() {
      _showPhotoError = _selectedPhotos.isEmpty;
      _showDateError = _selectedDate == null;
    });

    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedPhotos.isEmpty) {
      _goToStep(0);
      SnackBarUtils.showWarning(
        context,
        title: 'Peringatan!',
        message: 'Mohon lengkapi data temuan di Step 1',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Upload foto temuan
      List<String> uploadedUrls = await _uploadFiles(
        _selectedPhotos,
        'foto temuan',
      );

      // Upload foto reminder jika ada
      List<String>? reminderUrls;
      if (_fotoReminder.isNotEmpty) {
        reminderUrls = await _uploadFiles(_fotoReminder, 'foto reminder');
      }

      // Upload foto closing jika ada
      List<String>? closingUrls;
      if (_fotoClosing.isNotEmpty) {
        closingUrls = await _uploadFiles(_fotoClosing, 'foto closing');
      }

      // Simpan temuan
      if (!mounted) return;
      SnackBarUtils.hide(context);
      SnackBarUtils.showLoading(context, message: 'Menyimpan data temuan...');

      final temuan = TemuanModel(
        lokasi: _lokasiController.text,
        alamatTemuan: _emptyToNull(_alamatTemuanController.text),
        namaPemilik: _namaPemilikController.text,
        tanggalTemuan: _selectedDate!,
        deskripsiTemuan: _deskripsiController.text,
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        fotoUrls: uploadedUrls.isEmpty ? null : uploadedUrls,
        nomorAms:
            _nomorAmsController.text.isEmpty ? null : _nomorAmsController.text,
        statusTemuan: 'Open',
        tipeTemuan: widget.tipeTemuan,
        jarakAktivitas: _jarakAktivitas,
        intensitasAktivitas: _intensitasAktivitas,
        jenisObjek: _jenisObjek,
        jenisAset: _jenisAset,
        lokasiObjek: _lokasiObjek,
        skorMatriks: _skorMatriks > 0 ? _skorMatriks : null,
        levelRisiko: _levelRisiko,
        namaPenyulang: _namaPenyulang,
        section: _section,
        zona: _zona,
        tglReminder: _tglReminder,
        fotoReminder: reminderUrls,
        jenisClosing: _jenisClosing,
        tglClosing: _tglClosing,
        fotoClosing: closingUrls,
      );

      final result = await _temuanService.createTemuan(temuan);

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();

      if (result['success']) {
        // Jika ada sosialisasi, simpan
        if (_tglSosialisasi != null) {
          List<String>? sosUrls;
          if (_fotoSosialisasi.isNotEmpty) {
            sosUrls = await _uploadFiles(_fotoSosialisasi, 'foto sosialisasi');
          }
          final temuanId = (result['data'] as TemuanModel).id!;
          await _temuanService.addSosialisasi(
            SosialisasiModel(
              temuanId: temuanId,
              tglSosialisasi: _tglSosialisasi!,
              fotoUrls: sosUrls,
            ),
          );
        }

        // Cek apakah tgl_reminder sudah overdue → buat notifikasi langsung
        if (_tglReminder != null) {
          final saved = result['data'] as TemuanModel;
          NotificationService.instance.checkAndNotifyOverdue(
            temuanId: saved.id!,
            namaPemilik: saved.namaPemilik,
            lokasi: saved.lokasi,
            tglReminder: _tglReminder!,
          );
        }

        if (!mounted) return;
        SnackBarUtils.showSuccess(
          context,
          title: 'Berhasil!',
          message: 'Data temuan berhasil disimpan',
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.of(context).pop(true);
      } else {
        SnackBarUtils.showError(
          context,
          title: 'Gagal!',
          message: result['message'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      SnackBarUtils.showError(context, title: 'Error!', message: e.toString());
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  bool get _isFormDirty =>
      _lokasiController.text.isNotEmpty ||
      _alamatTemuanController.text.isNotEmpty ||
      _namaPemilikController.text.isNotEmpty ||
      _deskripsiController.text.isNotEmpty ||
      _nomorAmsController.text.isNotEmpty ||
      _selectedDate != null ||
      _selectedPhotos.isNotEmpty;

  Future<bool> _confirmDiscard() async {
    if (!_isFormDirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Keluar tanpa menyimpan?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Data yang sudah diisi akan hilang.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  // ==================== BUILD METHODS ====================

  Widget _buildStepIndicator() {
    const labels = ['Temuan', 'Reminder', 'Closing', 'Sosialisasi'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: () => _goToStep(i),
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isActive
                              ? Colors.blue
                              : isDone
                              ? Colors.green
                              : Colors.grey[700],
                    ),
                    child: Center(
                      child:
                          isDone
                              ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                              : Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? Colors.blue : Colors.white70,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserInfo() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userProfileFuture,
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

  Widget _buildTipeBadge() {
    final isKmu = widget.tipeTemuan == TipeTemuan.kmu;
    final color = isKmu ? Colors.red : Colors.green;
    final icon = isKmu ? Icons.bolt : Icons.nature;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                TipeTemuan.label(widget.tipeTemuan),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMapPreview() {
    if (_currentLatitude == null || _currentLongitude == null) {
      return const SizedBox.shrink();
    }
    final position = LatLng(_currentLatitude!, _currentLongitude!);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview Lokasi',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: position,
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.elsafe',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: position,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    String? label,
    IconData? icon,
    Color? iconColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      hintText: hint,
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
        borderSide: BorderSide(color: iconColor ?? Colors.blue),
      ),
      prefixIcon:
          icon != null ? Icon(icon, color: iconColor ?? Colors.blue) : null,
    );
  }

  Widget _buildPenyulangSection() {
    final penyulangList = Penyulang.untukUlp(_currentUlp);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // NAMA PENYULANG
        Row(
          children: [
            const Text(
              'Nama Penyulang',
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
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Text(
                'Opsional',
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _namaPenyulang,
              isExpanded: true,
              dropdownColor: Colors.grey[850],
              hint: const Text(
                'Pilih penyulang',
                style: TextStyle(color: Colors.white70),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    '-- Tidak dipilih --',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ...penyulangList.map(
                  (n) => DropdownMenuItem<String?>(value: n, child: Text(n)),
                ),
              ],
              onChanged:
                  _isSubmitting
                      ? null
                      : (val) => setState(() => _namaPenyulang = val),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ZONA
        Row(
          children: [
            const Text(
              'Zona',
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
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Text(
                'Opsional',
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _zona,
              isExpanded: true,
              dropdownColor: Colors.grey[850],
              hint: const Text(
                'Pilih zona (1-5)',
                style: TextStyle(color: Colors.white70),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    '-- Tidak dipilih --',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ...List.generate(
                  5,
                  (i) => DropdownMenuItem<int?>(
                    value: i + 1,
                    child: Text('Zona ${i + 1}'),
                  ),
                ),
              ],
              onChanged:
                  _isSubmitting ? null : (val) => setState(() => _zona = val),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // SECTION
        Row(
          children: [
            const Text(
              'Section',
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
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Text(
                'Opsional',
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _section,
              isExpanded: true,
              dropdownColor: Colors.grey[850],
              hint: const Text(
                'Pilih section',
                style: TextStyle(color: Colors.white70),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    '-- Tidak dipilih --',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ...List.generate(
                  10,
                  (i) => DropdownMenuItem<int?>(
                    value: i + 1,
                    child: Text('Section ${i + 1}'),
                  ),
                ),
              ],
              onChanged:
                  _isSubmitting
                      ? null
                      : (val) => setState(() => _section = val),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    bool showError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await _pickDate(initial: value);
            if (picked != null) onChanged(picked);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              border: Border.all(
                color:
                    showError && value == null
                        ? Colors.red.withValues(alpha: 0.5)
                        : Colors.grey[600]!,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  value != null
                      ? '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}'
                      : 'Pilih tanggal',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        if (showError && value == null)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'Tanggal harus dipilih',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // ==================== STEP PAGES ====================

  Widget _buildStep1Temuan() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildUserInfo(),
        _buildTipeBadge(),

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
          decoration: _inputDecoration(
            hint: 'Masukkan lokasi atau gunakan GPS',
            icon: Icons.location_on,
          ),
          validator:
              (value) =>
                  (value == null || value.isEmpty)
                      ? 'Lokasi harus diisi'
                      : null,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
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
        _buildMiniMapPreview(),
        const SizedBox(height: 20),

        // ALAMAT TEMUAN
        const Text(
          'Alamat Temuan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _alamatTemuanController,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(
            hint: 'Masukkan alamat detail temuan',
            label: 'Alamat Temuan',
            icon: Icons.home_work_outlined,
          ),
        ),
        const SizedBox(height: 20),

        // PENYULANG & SECTION
        _buildPenyulangSection(),

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
          decoration: _inputDecoration(
            hint: 'Masukkan nama pemilik',
            label: 'Nama Pemilik',
            icon: Icons.person,
          ),
          validator:
              (value) =>
                  (value == null || value.isEmpty)
                      ? 'Nama pemilik harus diisi'
                      : null,
        ),
        const SizedBox(height: 20),

        // TANGGAL
        _buildDatePicker(
          label: 'Tanggal Temuan',
          value: _selectedDate,
          onChanged:
              (d) => setState(() {
                _selectedDate = d;
                _showDateError = false;
              }),
          showError: _showDateError,
        ),
        const SizedBox(height: 20),

        // FOTO
        FotoPickerWidget(
          showValidationError: _showPhotoError,
          isEnabled: !_isSubmitting,
          onNewFilesChanged: (files) {
            _selectedPhotos = files;
            if (files.isNotEmpty && _showPhotoError) {
              setState(() => _showPhotoError = false);
            }
          },
        ),
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
          decoration: _inputDecoration(
            hint: 'Jelaskan detail temuan',
            label: 'Deskripsi Temuan',
            icon: Icons.description,
          ),
          validator:
              (value) =>
                  (value == null || value.isEmpty)
                      ? 'Deskripsi harus diisi'
                      : null,
        ),
        const SizedBox(height: 20),

        // NOMOR AMS
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Text(
                'Opsional',
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
          decoration: _inputDecoration(
            hint: 'Masukkan nomor AMS (jika ada)',
            icon: Icons.confirmation_number,
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(height: 24),

        // MATRIKS RISIKO
        MatriksRisikoWidget(
          initialJarak: _jarakAktivitas,
          initialIntensitas: _intensitasAktivitas,
          initialObjek: _jenisObjek,
          initialAset: _jenisAset,
          initialLokasi: _lokasiObjek,
          onChanged: (
            level,
            skor, {
            required jarak,
            required intensitas,
            required objek,
            required aset,
            required lokasi,
          }) {
            setState(() {
              _jarakAktivitas = jarak;
              _intensitasAktivitas = intensitas;
              _jenisObjek = objek;
              _jenisAset = aset;
              _lokasiObjek = lokasi;
              _skorMatriks = skor;
              _levelRisiko = level;
            });
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep2Reminder() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Step 2: Reminder',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Opsional — isi jika sudah melakukan reminder ke pemilik.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 24),

        _buildDatePicker(
          label: 'Tanggal Reminder',
          value: _tglReminder,
          onChanged: (d) => setState(() => _tglReminder = d),
        ),
        const SizedBox(height: 20),

        const Text(
          'Foto Surat Tanda Terima',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        FotoPickerWidget(
          isEnabled: !_isSubmitting,
          onNewFilesChanged: (files) => _fotoReminder = files,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep3Closing() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Step 3: Closing',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mengisi closing akan menutup temuan ini secara otomatis.',
                  style: TextStyle(color: Colors.orange, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Jenis Closing
        const Text(
          'Jenis Closing',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
              value: _jenisClosing,
              isExpanded: true,
              dropdownColor: Colors.grey[850],
              hint: const Text(
                'Pilih jenis closing',
                style: TextStyle(color: Colors.white70),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: const [
                DropdownMenuItem(value: 'pfk', child: Text('PFK')),
                DropdownMenuItem(value: 'preventif', child: Text('Preventif')),
              ],
              onChanged: (val) => setState(() => _jenisClosing = val),
            ),
          ),
        ),
        const SizedBox(height: 20),

        _buildDatePicker(
          label: 'Tanggal Closing',
          value: _tglClosing,
          onChanged: (d) => setState(() => _tglClosing = d),
        ),
        const SizedBox(height: 20),

        const Text(
          'Foto Tindaklanjut',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        FotoPickerWidget(
          isEnabled: !_isSubmitting,
          onNewFilesChanged: (files) => _fotoClosing = files,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep4Sosialisasi() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Step 4: Sosialisasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Opsional — catat kegiatan sosialisasi terkait temuan ini.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 24),

        _buildDatePicker(
          label: 'Tanggal Sosialisasi',
          value: _tglSosialisasi,
          onChanged: (d) => setState(() => _tglSosialisasi = d),
        ),
        const SizedBox(height: 20),

        const Text(
          'Foto Sosialisasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        FotoPickerWidget(
          isEnabled: !_isSubmitting,
          onNewFilesChanged: (files) => _fotoSosialisasi = files,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Form ${TipeTemuan.label(widget.tipeTemuan)}'),
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1Temuan(),
                    _buildStep2Reminder(),
                    _buildStep3Closing(),
                    _buildStep4Sosialisasi(),
                  ],
                ),
              ),
            ),
            // Bottom navigation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(top: BorderSide(color: Colors.grey[800]!)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _goToStep(_currentStep - 1),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Sebelumnya'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isSubmitting
                              ? null
                              : _currentStep < _totalSteps - 1
                              ? () => _goToStep(_currentStep + 1)
                              : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _currentStep < _totalSteps - 1
                                ? Colors.blue
                                : Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                _currentStep < _totalSteps - 1
                                    ? 'Selanjutnya'
                                    : 'Simpan Temuan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
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

// ========== MAP PICKER SCREEN ==========
class MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapPickerScreen({super.key, required this.initialPosition});

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
    setState(() => _selectedPosition = position);
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
                    color: Colors.black.withValues(alpha: 0.3),
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
                    'Lat: ${_selectedPosition.latitude.toStringAsFixed(6)}\nLong: ${_selectedPosition.longitude.toStringAsFixed(6)}',
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
