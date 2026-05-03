import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../config/snackbar.dart';
import 'foto_grid_widget.dart';

class FotoPickerWidget extends StatefulWidget {
  final List<String> existingUrls;
  final bool isEnabled;
  final bool showValidationError;
  final void Function(List<PlatformFile>) onNewFilesChanged;
  final void Function(List<String>)? onExistingUrlsChanged;
  final void Function(List<String>)? onDeletedUrlsChanged;

  const FotoPickerWidget({
    super.key,
    this.existingUrls = const [],
    this.isEnabled = true,
    this.showValidationError = false,
    required this.onNewFilesChanged,
    this.onExistingUrlsChanged,
    this.onDeletedUrlsChanged,
  });

  @override
  State<FotoPickerWidget> createState() => _FotoPickerWidgetState();
}

class _FotoPickerWidgetState extends State<FotoPickerWidget> {
  static const int _maxPhotos = 3;

  final List<PlatformFile> _newFiles = [];
  late List<String> _existingUrls;
  final List<String> _deletedUrls = [];

  @override
  void initState() {
    super.initState();
    _existingUrls = List.from(widget.existingUrls);
  }

  int get _totalCount => _existingUrls.length + _newFiles.length;
  bool get _isFull => _totalCount >= _maxPhotos;

  Future<void> _pickFromGallery() async {
    if (_isFull) {
      SnackBarUtils.showWarning(context, title: 'Peringatan!', message: 'Maksimal $_maxPhotos foto');
      return;
    }
    try {
      final remaining = _maxPhotos - _totalCount;
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: true,
        withData: kIsWeb,
        withReadStream: !kIsWeb,
      );
      if (result != null && result.files.isNotEmpty) {
        final newFiles = result.files.take(remaining).toList();
        setState(() => _newFiles.addAll(newFiles));
        widget.onNewFilesChanged(_newFiles);
        if (mounted) {
          SnackBarUtils.showSuccess(context, title: 'Berhasil!',
              message: '${newFiles.length} foto dipilih ($_totalCount/$_maxPhotos)');
        }
      }
    } catch (e) {
      if (mounted) SnackBarUtils.showError(context, title: 'Error!', message: 'Gagal memilih foto: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    if (kIsWeb) {
      await _pickFromGallery();
      return;
    }
    if (_isFull) {
      SnackBarUtils.showWarning(context, title: 'Peringatan!', message: 'Maksimal $_maxPhotos foto');
      return;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withReadStream: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _newFiles.add(result.files.single));
        widget.onNewFilesChanged(_newFiles);
        if (mounted) {
          SnackBarUtils.showSuccess(context, title: 'Berhasil!',
              message: 'Foto dipilih ($_totalCount/$_maxPhotos)');
        }
      }
    } catch (e) {
      if (mounted) SnackBarUtils.showError(context, title: 'Error!', message: 'Gagal mengambil foto: $e');
    }
  }

  void _removeNewFile(int index) {
    setState(() => _newFiles.removeAt(index));
    widget.onNewFilesChanged(_newFiles);
    if (mounted) {
      SnackBarUtils.showSuccess(context, title: 'Berhasil!',
          message: 'Foto dihapus ($_totalCount/$_maxPhotos)');
    }
  }

  void _removeExistingUrl(String url) {
    setState(() {
      _existingUrls.remove(url);
      _deletedUrls.add(url);
    });
    widget.onExistingUrlsChanged?.call(_existingUrls);
    widget.onDeletedUrlsChanged?.call(_deletedUrls);
  }

  void _showSourceDialog() {
    if (kIsWeb) {
      _pickFromGallery();
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
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              const Text('Pilih Sumber Foto',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('Kamera', style: TextStyle(color: Colors.white)),
                onTap: () { Navigator.pop(context); _pickFromCamera(); },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.photo_library, color: Colors.green),
                ),
                title: const Text('Galeri', style: TextStyle(color: Colors.white)),
                onTap: () { Navigator.pop(context); _pickFromGallery(); },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Foto Temuan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Text('Min. 1 foto',
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _totalCount > 0 ? Colors.blue.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _totalCount > 0 ? Colors.blue.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '$_totalCount/$_maxPhotos foto',
                style: TextStyle(
                  color: _totalCount > 0 ? Colors.blue : Colors.grey[400],
                  fontSize: 13, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Foto lama (hanya muncul di mode edit)
        if (_existingUrls.isNotEmpty) ...[
          _sectionLabel('Foto yang Sudah Ada', '(${_existingUrls.length})', Colors.blue),
          const SizedBox(height: 8),
          FotoGridWidget(
            fotoUrls: _existingUrls,
            isEditable: widget.isEnabled,
            onDelete: _removeExistingUrl,
          ),
          const SizedBox(height: 16),
        ],

        // Foto baru yang dipilih
        if (_newFiles.isNotEmpty) ...[
          if (widget.existingUrls.isNotEmpty)
            _sectionLabel('Foto Baru (Belum Disimpan)', '(${_newFiles.length})', Colors.orange),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
            ),
            itemCount: _newFiles.length,
            itemBuilder: (context, index) => _buildNewFileItem(index),
          ),
          const SizedBox(height: 12),
        ],

        // Tombol tambah foto
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.isEnabled && !_isFull ? _showSourceDialog : null,
            icon: Icon(Icons.add_photo_alternate, color: !_isFull ? Colors.blue : Colors.grey),
            label: Text(
              _totalCount == 0
                  ? 'Tambah Foto (Wajib)'
                  : !_isFull ? 'Tambah Foto Lagi' : 'Maksimal $_maxPhotos Foto',
              style: TextStyle(color: !_isFull ? Colors.white : Colors.grey),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: widget.showValidationError && _totalCount == 0
                    ? Colors.red
                    : !_isFull ? Colors.blue : Colors.grey,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        if (widget.showValidationError && _totalCount == 0)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 12),
            child: Text('Minimal 1 foto harus diupload',
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildNewFileItem(int index) {
    final file = _newFiles[index];
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
                ? (file.bytes != null
                    ? Image.memory(file.bytes!, fit: BoxFit.cover,
                        width: double.infinity, height: double.infinity,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.red, size: 40)))
                    : const Center(child: Icon(Icons.image, color: Colors.blue, size: 40)))
                : (file.path != null
                    ? Image.file(File(file.path!), fit: BoxFit.cover,
                        width: double.infinity, height: double.infinity,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.red, size: 40)))
                    : const Center(child: Icon(Icons.image, color: Colors.blue, size: 40))),
          ),
        ),
        Positioned(
          top: 4, right: 4,
          child: GestureDetector(
            onTap: () => _removeNewFile(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 4, left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String title, String count, Color color) {
    return Row(
      children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(
            color: color == Colors.orange ? Colors.orange : Colors.white,
            fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text(count, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
      ],
    );
  }
}
