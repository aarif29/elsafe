import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../config/temuan_model.dart';
import '../config/temuan_service.dart';
import '../utils/export_temuan_filter.dart';
import '../utils/pdf_generator.dart';

class ExportTemuanScreen extends StatefulWidget {
  const ExportTemuanScreen({super.key});

  @override
  State<ExportTemuanScreen> createState() => _ExportTemuanScreenState();
}

class _ExportTemuanScreenState extends State<ExportTemuanScreen> {
  final _temuanService = TemuanService();

  List<TemuanModel> _allTemuan = [];
  List<TemuanModel> _filteredTemuan = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  Set<String> _selectedStatuses = {'Open', 'Closed', 'On Progress'};
  Set<String> _selectedRisiko = {'Tinggi', 'Sedang', 'Rendah'};
  Set<int> _selectedZonas = {1, 2, 3, 4, 5};
  Set<int> _selectedSections = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
  Set<String> _selectedUlps = {};
  String? _selectedPenyulang;
  bool _isAdmin = false;

  // Selection
  final Set<String> _selectedTemuanIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _temuanService.getAllTemuanSilent();
    if (!mounted) return;

    if (result['success'] == true) {
      final loadedTemuan = List<TemuanModel>.from(result['data']);
      final isAdmin = result['isAdmin'] as bool? ?? false;
      final ulps = _uniqueUlps(loadedTemuan).toSet();

      setState(() {
        _isAdmin = isAdmin;
        _allTemuan = loadedTemuan;
        _filteredTemuan = _allTemuan;
        _selectedUlps = isAdmin ? ulps : {};
        _isLoading = false;
        _selectedTemuanIds.addAll(
          _filteredTemuan.where((t) => t.id != null).map((t) => t.id!),
        );
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] as String? ?? 'Gagal memuat data';
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTemuan = filterExportTemuan(
        _allTemuan,
        startDate: _startDate,
        endDate: _endDate,
        selectedStatuses: _selectedStatuses,
        selectedRisiko: _selectedRisiko,
        selectedZonas: _selectedZonas,
        selectedSections: _selectedSections,
        selectedUlps: _isAdmin ? _selectedUlps : const {},
        selectedPenyulang: _selectedPenyulang,
      );

      _selectedTemuanIds.clear();
      _selectedTemuanIds.addAll(
        _filteredTemuan.where((t) => t.id != null).map((t) => t.id!),
      );
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedTemuanIds.addAll(
          _filteredTemuan.where((t) => t.id != null).map((t) => t.id!),
        );
      } else {
        _selectedTemuanIds.clear();
      }
    });
  }

  void _toggleTemuan(String id, bool? value) {
    setState(() {
      if (value == true) {
        _selectedTemuanIds.add(id);
      } else {
        _selectedTemuanIds.remove(id);
      }
    });
  }

  List<String> get _penyulangList {
    final penyulangs =
        _allTemuan
            .where((t) => t.namaPenyulang != null)
            .map((t) => t.namaPenyulang!)
            .toSet()
            .toList();
    penyulangs.sort();
    return penyulangs;
  }

  List<String> get _ulpList => _uniqueUlps(_allTemuan);

  List<TemuanModel> get _selectedTemuan {
    return _filteredTemuan
        .where((t) => t.id != null && _selectedTemuanIds.contains(t.id))
        .toList();
  }

  List<String> _uniqueUlps(List<TemuanModel> source) {
    final ulps =
        source
            .where((t) => t.ulp != null && t.ulp!.isNotEmpty)
            .map((t) => t.ulp!)
            .toSet()
            .toList();
    ulps.sort();
    return ulps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        title: const Text('Export Temuan'),
        backgroundColor: const Color(0xFF2D2D3D),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildFilterSection(),
                  const Divider(color: Colors.grey),
                  _buildSelectionHeader(),
                  Expanded(child: _buildTemuanList()),
                  _buildActionButtons(),
                ],
              ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF2D2D3D),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Tanggal
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'Dari Tanggal',
                  date: _startDate,
                  onTap: () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDateButton(
                  label: 'Sampai Tanggal',
                  date: _endDate,
                  onTap: () => _pickDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status
          _buildMultiSelectChip(
            label: 'Status',
            values: const ['Open', 'Closed', 'On Progress'],
            selected: _selectedStatuses,
            onChanged: (val) => setState(() => _selectedStatuses = val),
          ),
          const SizedBox(height: 8),

          // Level Risiko
          _buildMultiSelectChip(
            label: 'Level Risiko',
            values: const ['Tinggi', 'Sedang', 'Rendah'],
            selected: _selectedRisiko,
            onChanged: (val) => setState(() => _selectedRisiko = val),
          ),
          const SizedBox(height: 8),

          // Zona
          _buildMultiSelectChip(
            label: 'Zona',
            values: const ['1', '2', '3', '4', '5'],
            selected: _selectedZonas.map((i) => i.toString()).toSet(),
            onChanged:
                (val) => setState(
                  () => _selectedZonas = val.map((s) => int.parse(s)).toSet(),
                ),
            itemPrefix: 'Zona',
          ),
          const SizedBox(height: 8),

          // Section
          _buildMultiSelectChip(
            label: 'Section',
            values: List.generate(10, (i) => (i + 1).toString()),
            selected: _selectedSections.map((i) => i.toString()).toSet(),
            onChanged:
                (val) => setState(
                  () =>
                      _selectedSections = val.map((s) => int.parse(s)).toSet(),
                ),
            itemPrefix: 'Section',
          ),

          if (_isAdmin && _ulpList.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildMultiSelectChip(
              label: 'ULP',
              values: _ulpList,
              selected: _selectedUlps,
              onChanged: (val) => setState(() => _selectedUlps = val),
            ),
          ],

          // Penyulang
          if (_penyulangList.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedPenyulang,
                  hint: const Text(
                    'Pilih Penyulang (Opsional)',
                    style: TextStyle(color: Colors.white70),
                  ),
                  isExpanded: true,
                  dropdownColor: Colors.grey[850],
                  style: const TextStyle(color: Colors.white),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Semua'),
                    ),
                    ..._penyulangList.map(
                      (p) =>
                          DropdownMenuItem<String?>(value: p, child: Text(p)),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedPenyulang = val),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              child: const Text('Terapkan Filter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              date != null ? _formatDate(date) : label,
              style: TextStyle(
                color: date != null ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          isStart
              ? (_startDate ?? DateTime.now())
              : (_endDate ?? DateTime.now()),
      firstDate: isStart ? DateTime(2020) : (_startDate ?? DateTime(2020)),
      lastDate: isStart ? (_endDate ?? DateTime.now()) : DateTime.now(),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Widget _buildMultiSelectChip({
    required String label,
    required List<String> values,
    required Set<String> selected,
    required Function(Set<String>) onChanged,
    String? itemPrefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children:
              values.map((v) {
                final isSelected = selected.contains(v);
                return FilterChip(
                  label: Text(itemPrefix == null ? v : '$itemPrefix $v'),
                  selected: isSelected,
                  onSelected: (sel) {
                    final newSet = Set<String>.from(selected);
                    if (sel) {
                      newSet.add(v);
                    } else {
                      newSet.remove(v);
                    }
                    onChanged(newSet);
                  },
                  selectedColor: Colors.blue.withValues(alpha: 0.3),
                  checkmarkColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.blue : Colors.white70,
                    fontSize: 12,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectionHeader() {
    final selectedCount = _selectedTemuanIds.length;
    final totalCount = _filteredTemuan.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF252535),
      child: Row(
        children: [
          Checkbox(
            value:
                totalCount > 0 && selectedCount == totalCount
                    ? true
                    : (selectedCount == 0 ? false : null),
            tristate: true,
            onChanged: (val) => _toggleSelectAll(val ?? true),
          ),
          Text(
            'Pilih Semua ($selectedCount/$totalCount)',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemuanList() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredTemuan.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada data temuan',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredTemuan.length,
      itemBuilder: (context, index) {
        final t = _filteredTemuan[index];
        final isSelected = _selectedTemuanIds.contains(t.id);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D3D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged:
                  t.id != null ? (val) => _toggleTemuan(t.id!, val) : null,
            ),
            title: Text(
              t.lokasi,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${_formatDate(t.tanggalTemuan)} • ${t.statusTemuan ?? "-"} • ${t.levelRisiko ?? "-"}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            trailing:
                t.fotoUrls != null && t.fotoUrls!.isNotEmpty
                    ? const Icon(Icons.image, color: Colors.white70)
                    : null,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
  }

  Widget _buildActionButtons() {
    final selectedCount = _selectedTemuanIds.length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF2D2D3D),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: selectedCount > 0 ? () => _previewPdf() : null,
              icon: const Icon(Icons.preview),
              label: const Text('Preview PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: selectedCount > 0 ? () => _exportPdf() : null,
              icon: const Icon(Icons.share),
              label: Text('Export ($selectedCount)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _previewPdf() async {
    final selectedTemuan = _selectedTemuan;
    if (selectedTemuan.isEmpty) return;

    await Printing.layoutPdf(
      name: _exportFileName(),
      onLayout:
          (_) => ExportTemuanPdfGenerator.generate(
            temuan: selectedTemuan,
            startDate: _startDate,
            endDate: _endDate,
            ulpLabel: _pdfUlpLabel(selectedTemuan),
          ),
    );
  }

  Future<void> _exportPdf() async {
    final selectedTemuan = _selectedTemuan;
    if (selectedTemuan.isEmpty) return;

    final bytes = await ExportTemuanPdfGenerator.generate(
      temuan: selectedTemuan,
      startDate: _startDate,
      endDate: _endDate,
      ulpLabel: _pdfUlpLabel(selectedTemuan),
    );

    await Printing.sharePdf(bytes: bytes, filename: _exportFileName());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF berhasil dibuat (${selectedTemuan.length})')),
    );
  }

  String _pdfUlpLabel(List<TemuanModel> selectedTemuan) {
    if (_isAdmin) {
      if (_selectedUlps.isEmpty) return 'Semua ULP';
      return _selectedUlps.join(', ');
    }

    final ulps = _uniqueUlps(selectedTemuan);
    if (ulps.isEmpty) return '-';
    return ulps.join(', ');
  }

  String _exportFileName() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return 'temuan-elsafe-$year$month$day-$hour$minute.pdf';
  }
}
