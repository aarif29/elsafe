import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/snackbar.dart';
import '../config/temuan_model.dart';
import '../config/temuan_types.dart';
import '../config/temuan_service.dart';
import '../config/sosialisasi_model.dart';
import '../widgets/foto_picker_widget.dart';
import '../widgets/matriks_risiko_widget.dart';
import '../config/notification_service.dart';
import '../config/ulp_service.dart';

class EditTemuanScreen extends StatefulWidget {
  final TemuanModel temuan;

  const EditTemuanScreen({super.key, required this.temuan});

  @override
  State<EditTemuanScreen> createState() => _EditTemuanScreenState();
}

class _EditTemuanScreenState extends State<EditTemuanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lokasiController;
  late TextEditingController _alamatTemuanController;
  late TextEditingController _namaPemilikController;
  late TextEditingController _noHpController;
  late TextEditingController _deskripsiController;
  late TextEditingController _nomorAmsController;
  final _temuanService = TemuanService();
  final _pageController = PageController();

  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Step 1 - Temuan
  DateTime? _selectedDate;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  bool _showDateError = false;
  bool _isAdmin = false;
  double? _currentLatitude;
  double? _currentLongitude;
  String? _tipeTemuan;

  // Foto management
  List<String> _existingFotoUrls = [];
  final List<PlatformFile> _newFotoFiles = [];
  List<String> _deletedFotoUrls = [];

  // Matriks risiko
  String? _jarakAktivitas;
  String? _intensitasAktivitas;
  String? _jenisObjek;
  String? _jenisAset;
  String? _lokasiObjek;
  int _skorMatriks = 0;
  String? _levelRisiko;

  // Jaringan listrik
  String? _currentUlp;
  String? _namaPenyulang;
  int? _section;
  int? _zona;

  // Step 2 - Reminder
  DateTime? _tglReminder;
  List<String> _existingFotoReminder = [];
  List<PlatformFile> _newFotoReminder = [];
  List<String> _deletedFotoReminder = [];

  // Step 3 - Closing
  String? _jenisClosing;
  DateTime? _tglClosing;
  List<String> _existingFotoClosing = [];
  List<PlatformFile> _newFotoClosing = [];
  List<String> _deletedFotoClosing = [];

  // Step 4 - Sosialisasi
  List<SosialisasiModel> _riwayatSosialisasi = [];
  bool _isLoadingSosialisasi = false;
  DateTime? _tglSosialisasiBaru;
  List<PlatformFile> _fotoSosialisasiBaru = [];

  @override
  void initState() {
    super.initState();
    final t = widget.temuan;
    _lokasiController = TextEditingController(text: t.lokasi);
    _alamatTemuanController = TextEditingController(text: t.alamatTemuan ?? '');
    _namaPemilikController = TextEditingController(text: t.namaPemilik);
    _noHpController = TextEditingController(text: t.noHp ?? '');
    _deskripsiController = TextEditingController(text: t.deskripsiTemuan);
    _nomorAmsController = TextEditingController(text: t.nomorAms ?? '');
    _tipeTemuan = t.tipeTemuan;
    _selectedDate = t.tanggalTemuan;
    _currentLatitude = t.latitude;
    _currentLongitude = t.longitude;

    if (t.fotoUrls != null) _existingFotoUrls = List.from(t.fotoUrls!);

    // Matriks
    _jarakAktivitas = t.jarakAktivitas;
    _intensitasAktivitas = t.intensitasAktivitas;
    _jenisObjek = t.jenisObjek;
    _jenisAset = t.jenisAset;
    _lokasiObjek = t.lokasiObjek;
    _skorMatriks = t.skorMatriks ?? 0;
    _levelRisiko = t.levelRisiko;

    // Reminder
    _tglReminder = t.tglReminder;
    if (t.fotoReminder != null) {
      _existingFotoReminder = List.from(t.fotoReminder!);
    }

    // Closing
    _jenisClosing = t.jenisClosing;
    _tglClosing = t.tglClosing;
    if (t.fotoClosing != null) {
      _existingFotoClosing = List.from(t.fotoClosing!);
    }

    // Jaringan listrik
    _namaPenyulang = t.namaPenyulang;
    _section = t.section;
    _zona = t.zona;
    UlpService().getCurrentUserProfile().then((profile) {
      if (profile != null && mounted) {
        setState(() {
          _currentUlp = profile['ulp'] as String?;
          _isAdmin = profile['role'] == 'admin';
        });
      }
    });

    _loadSosialisasi();
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _alamatTemuanController.dispose();
    _namaPemilikController.dispose();
    _noHpController.dispose();
    _deskripsiController.dispose();
    _nomorAmsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSosialisasi() async {
    if (widget.temuan.id == null) return;
    setState(() => _isLoadingSosialisasi = true);
    final result = await _temuanService.getSosialisasiByTemuan(
      widget.temuan.id!,
    );
    if (mounted) {
      setState(() {
        _riwayatSosialisasi = result['data'] as List<SosialisasiModel>? ?? [];
        _isLoadingSosialisasi = false;
      });
    }
  }

  void _goToStep(int step) {
    if (step < 0 || step >= _totalSteps) return;
    if (_currentStep == 0 && step > 0) {
      setState(() => _showDateError = _selectedDate == null);
      if (!_formKey.currentState!.validate() || _selectedDate == null) {
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
      if (kIsWeb) {
        SnackBarUtils.showWarning(
          context,
          title: 'Peringatan!',
          message: 'Gunakan "Pilih Lokasi dari Peta".',
        );
        setState(() => _isLoadingLocation = false);
        return;
      }
      var permission = await Permission.location.request();
      if (permission.isDenied) throw Exception('Izin lokasi ditolak.');

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
        builder:
            (context) => _MapPickerScreen(initialPosition: initialPosition),
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
    return showDatePicker(
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

    setState(() => _showDateError = _selectedDate == null);
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
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
      SnackBarUtils.showLoading(context, message: 'Memperbarui data temuan...');

      // Upload new foto temuan
      List<String> newUploadedUrls = [];
      if (_newFotoFiles.isNotEmpty) {
        newUploadedUrls = await _uploadFiles(_newFotoFiles, 'foto temuan');
      }
      final allFotoUrls = [..._existingFotoUrls, ...newUploadedUrls];

      // Upload new foto reminder
      List<String> newReminderUrls = [];
      if (_newFotoReminder.isNotEmpty) {
        newReminderUrls = await _uploadFiles(_newFotoReminder, 'foto reminder');
      }
      final allReminderUrls = [..._existingFotoReminder, ...newReminderUrls];

      // Upload new foto closing
      List<String> newClosingUrls = [];
      if (_newFotoClosing.isNotEmpty) {
        newClosingUrls = await _uploadFiles(_newFotoClosing, 'foto closing');
      }
      final allClosingUrls = [..._existingFotoClosing, ...newClosingUrls];

      // Build updated temuan
      final updatedTemuan = TemuanModel(
        id: widget.temuan.id,
        lokasi: _lokasiController.text,
        alamatTemuan: _emptyToNull(_alamatTemuanController.text),
        namaPemilik: _namaPemilikController.text,
        noHp: _noHpController.text,
        tanggalTemuan: _selectedDate!,
        deskripsiTemuan: _deskripsiController.text,
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        fotoUrls: allFotoUrls.isEmpty ? null : allFotoUrls,
        nomorAms:
            _nomorAmsController.text.isEmpty ? null : _nomorAmsController.text,
        statusTemuan: widget.temuan.statusTemuan ?? 'Open',
        tipeTemuan: _tipeTemuan,
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
        fotoReminder: allReminderUrls.isEmpty ? null : allReminderUrls,
        jenisClosing: _jenisClosing,
        tglClosing: _tglClosing,
        fotoClosing: allClosingUrls.isEmpty ? null : allClosingUrls,
      );

      final result = await _temuanService.updateTemuan(
        widget.temuan.id!,
        updatedTemuan,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();

      if (result['success']) {
        // Delete removed photos after update succeeds.
        for (var url in [
          ..._deletedFotoUrls,
          ..._deletedFotoReminder,
          ..._deletedFotoClosing,
        ]) {
          try {
            await _temuanService.deleteFoto(url);
          } catch (_) {}
        }

        // Save new sosialisasi after update succeeds.
        if (_tglSosialisasiBaru != null) {
          List<String>? sosUrls;
          if (_fotoSosialisasiBaru.isNotEmpty) {
            sosUrls = await _uploadFiles(
              _fotoSosialisasiBaru,
              'foto sosialisasi',
            );
          }
          await _temuanService.addSosialisasi(
            SosialisasiModel(
              temuanId: widget.temuan.id!,
              tglSosialisasi: _tglSosialisasiBaru!,
              fotoUrls: sosUrls,
            ),
          );
        }

        // Selalu clear dulu notif lama; lalu buat baru jika sudah overdue
        await NotificationService.instance.clearReminderNotifIfNotOverdue(
          temuanId: widget.temuan.id!,
          tglReminder: _tglReminder,
        );
        if (_tglReminder != null) {
          NotificationService.instance.checkAndNotifyOverdue(
            temuanId: widget.temuan.id!,
            namaPemilik: _namaPemilikController.text,
            lokasi: _lokasiController.text,
            tglReminder: _tglReminder!,
          );
        }

        if (!mounted) return;
        SnackBarUtils.showSuccess(
          context,
          title: 'Berhasil!',
          message: 'Data temuan berhasil diperbarui',
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
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  bool get _isFormDirty =>
      _lokasiController.text != widget.temuan.lokasi ||
      _alamatTemuanController.text != (widget.temuan.alamatTemuan ?? '') ||
      _namaPemilikController.text != widget.temuan.namaPemilik ||
      _noHpController.text != (widget.temuan.noHp ?? '') ||
      _deskripsiController.text != widget.temuan.deskripsiTemuan ||
      _selectedDate != widget.temuan.tanggalTemuan ||
      _newFotoFiles.isNotEmpty ||
      _deletedFotoUrls.isNotEmpty;

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
              'Perubahan yang belum disimpan akan hilang.',
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

  // ==================== BUILD HELPERS ====================

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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[700]!),
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
        const Text(
          'Nama Penyulang',
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
        const Text(
          'Zona',
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
        const Text(
          'Section',
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
          onTap:
              _isSubmitting
                  ? null
                  : () async {
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

  // ==================== STEP PAGES ====================

  Widget _buildStep1Temuan() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User info
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
        ),

        // Tipe Temuan picker
        _buildTipePicker(),

        // Foto
        FotoPickerWidget(
          existingUrls: _existingFotoUrls,
          isEnabled: !_isSubmitting,
          onNewFilesChanged: (files) {
            _newFotoFiles
              ..clear()
              ..addAll(files);
          },
          onExistingUrlsChanged:
              (urls) => setState(() => _existingFotoUrls = urls),
          onDeletedUrlsChanged:
              (deleted) => setState(() => _deletedFotoUrls = deleted),
        ),
        const SizedBox(height: 16),

        // Lokasi
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
          decoration: _inputDecoration(
            hint: 'Masukkan lokasi atau gunakan GPS',
            icon: Icons.location_on,
          ),
          validator:
              (v) => (v == null || v.isEmpty) ? 'Lokasi harus diisi' : null,
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
            onPressed: _isSubmitting ? null : _pickLocationManually,
            icon: const Icon(Icons.map, color: Colors.blue, size: 20),
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

        // Alamat Temuan
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
          enabled: !_isSubmitting,
          decoration: _inputDecoration(
            hint: 'Masukkan alamat detail temuan',
            label: 'Alamat Temuan',
            icon: Icons.home_work_outlined,
          ),
        ),
        const SizedBox(height: 20),

        // PENYULANG & SECTION
        _buildPenyulangSection(),

        // Nama Pemilik
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
          decoration: _inputDecoration(
            hint: 'Masukkan nama pemilik',
            label: 'Nama Pemilik',
            icon: Icons.person,
          ),
          validator:
              (v) =>
                  (v == null || v.isEmpty) ? 'Nama pemilik harus diisi' : null,
        ),
        const SizedBox(height: 20),

        // No. HP
        const Text(
          'No. HP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noHpController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          enabled: !_isSubmitting,
          decoration: _inputDecoration(
            hint: 'Masukkan nomor HP pemilik',
            label: 'No. HP',
            icon: Icons.phone,
          ),
          validator:
              (v) =>
                  (v == null || v.trim().isEmpty) ? 'No. HP harus diisi' : null,
        ),
        const SizedBox(height: 20),

        // Tanggal
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

        // Deskripsi
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
          decoration: _inputDecoration(
            hint: 'Jelaskan detail temuan',
            label: 'Deskripsi Temuan',
            icon: Icons.description,
          ),
          validator:
              (v) => (v == null || v.isEmpty) ? 'Deskripsi harus diisi' : null,
        ),
        const SizedBox(height: 20),

        // Nomor AMS
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
          enabled: !_isSubmitting,
          decoration: _inputDecoration(
            hint: 'Masukkan nomor AMS (jika ada)',
            icon: Icons.confirmation_number,
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(height: 24),

        // Matriks Risiko
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
          existingUrls: _existingFotoReminder,
          isEnabled: !_isSubmitting,
          onNewFilesChanged: (files) => _newFotoReminder = files,
          onExistingUrlsChanged:
              (urls) => setState(() => _existingFotoReminder = urls),
          onDeletedUrlsChanged:
              (deleted) => setState(() => _deletedFotoReminder = deleted),
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
              onChanged:
                  _isSubmitting
                      ? null
                      : (val) => setState(() => _jenisClosing = val),
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
          existingUrls: _existingFotoClosing,
          isEnabled: !_isSubmitting,
          onNewFilesChanged: (files) => _newFotoClosing = files,
          onExistingUrlsChanged:
              (urls) => setState(() => _existingFotoClosing = urls),
          onDeletedUrlsChanged:
              (deleted) => setState(() => _deletedFotoClosing = deleted),
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
          'Tetap lakukan sosialisasi kembali secara periodik walaupun status closing. '
          'Bahaya tidak hilang, hanya resikonya berkurang.\n'
          'Semoga kita selalu dalam lindungan-Nya.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 24),

        // Riwayat
        const Text(
          'Riwayat Sosialisasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoadingSosialisasi)
          const Center(child: CircularProgressIndicator())
        else if (_riwayatSosialisasi.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Belum ada riwayat sosialisasi.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          )
        else
          ..._riwayatSosialisasi.map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${s.tglSosialisasi.day.toString().padLeft(2, '0')}/${s.tglSosialisasi.month.toString().padLeft(2, '0')}/${s.tglSosialisasi.year}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (s.fotoUrls != null && s.fotoUrls!.isNotEmpty)
                    Text(
                      '${s.fotoUrls!.length} foto',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              backgroundColor: Colors.grey[900],
                              title: const Text(
                                'Hapus sosialisasi?',
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true && s.id != null) {
                        await _temuanService.deleteSosialisasi(s.id!);
                        _loadSosialisasi();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 24),
        const Divider(color: Colors.grey),
        const SizedBox(height: 16),

        if (widget.temuan.jenisClosing == null) ...[
          // Belum closing — tampilkan notice, sembunyikan form input
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Sosialisasi hanya tersedia setelah temuan di-closing.\n'
                    'Lengkapi Step 3 (Closing) terlebih dahulu.',
                    style: TextStyle(color: Colors.amber, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ] else ...[
          // Sudah closing — tampilkan form tambah sosialisasi baru
          const Text(
            'Tambah Sosialisasi Baru',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          _buildDatePicker(
            label: 'Tanggal Sosialisasi',
            value: _tglSosialisasiBaru,
            onChanged: (d) => setState(() => _tglSosialisasiBaru = d),
          ),
          const SizedBox(height: 16),

          const Text(
            'Foto Sosialisasi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          FotoPickerWidget(
            isEnabled: !_isSubmitting,
            onNewFilesChanged: (files) => _fotoSosialisasiBaru = files,
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildTipePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipe Temuan',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _TipeOption(
                label: 'KMU',
                icon: Icons.bolt,
                color: Colors.red,
                selected: _tipeTemuan == TipeTemuan.kmu,
                onTap: () => setState(() => _tipeTemuan = TipeTemuan.kmu),
              ),
              const SizedBox(width: 12),
              _TipeOption(
                label: 'ROW',
                icon: Icons.nature,
                color: Colors.green,
                selected: _tipeTemuan == TipeTemuan.row,
                onTap: () => setState(() => _tipeTemuan = TipeTemuan.row),
              ),
            ],
          ),
        ],
      ),
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
          title: Text('Edit ${TipeTemuan.label(widget.temuan.tipeTemuan)}'),
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
                                    : 'Perbarui Temuan',
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
class _MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;
  const _MapPickerScreen({required this.initialPosition});

  @override
  State<_MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<_MapPickerScreen> {
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

  void _confirmLocation() => Navigator.pop(context, _selectedPosition);

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
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: _confirmLocation,
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
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lat: ${_selectedPosition.latitude.toStringAsFixed(6)}, Long: ${_selectedPosition.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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

class _TipeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TipeOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.2) : Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : Colors.grey[600]!,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? color : Colors.grey[400], size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : Colors.grey[400],
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
