import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../config/app_theme.dart';
import '../config/temuan_model.dart';
import '../config/temuan_service.dart';
import '../config/temuan_types.dart';
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
  bool _hasAppliedFilters = false;
  String? _errorMessage;

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = _allValue;
  String _selectedRisiko = _allValue;
  String _selectedUlp = _allValue;
  String _selectedPenyulang = _allValue;
  String _selectedZona = _allValue;
  String _selectedSection = _allValue;
  String _selectedTipe = _allValue;
  bool _isAdmin = false;

  final Set<String> _selectedTemuanIds = {};

  static const _allValue = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasAppliedFilters = false;
      _errorMessage = null;
      _filteredTemuan = [];
      _selectedTemuanIds.clear();
    });

    final result = await _temuanService.getAllTemuanSilent();
    if (!mounted) return;

    if (result['success'] == true) {
      final loadedTemuan = List<TemuanModel>.from(result['data']);
      final isAdmin = result['isAdmin'] as bool? ?? false;

      setState(() {
        _isAdmin = isAdmin;
        _allTemuan = loadedTemuan;
        _filteredTemuan = [];
        _isLoading = false;
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
        selectedStatuses: _statusFilterValues,
        selectedRisiko: _stringFilterValue(_selectedRisiko),
        selectedZonas: _intFilterValue(_selectedZona),
        selectedSections: _intFilterValue(_selectedSection),
        selectedUlps: _isAdmin ? _stringFilterValue(_selectedUlp) : const {},
        selectedPenyulang:
            _selectedPenyulang == _allValue ? null : _selectedPenyulang,
        selectedTipe: _stringFilterValue(_selectedTipe),
      );
      _hasAppliedFilters = true;
      _selectAllFiltered();
    });
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedStatus = _allValue;
      _selectedRisiko = _allValue;
      _selectedUlp = _allValue;
      _selectedPenyulang = _allValue;
      _selectedZona = _allValue;
      _selectedSection = _allValue;
      _selectedTipe = _allValue;
      _filteredTemuan = [];
      _hasAppliedFilters = false;
      _selectedTemuanIds.clear();
    });
  }

  Set<String> get _statusFilterValues {
    if (_selectedStatus == _allValue) return const {};
    if (_selectedStatus == 'Closed' || _selectedStatus == 'Close') {
      return const {'Closed', 'Close'};
    }
    return {_selectedStatus};
  }

  Set<String> _stringFilterValue(String value) {
    return value == _allValue ? const {} : {value};
  }

  Set<int> _intFilterValue(String value) {
    if (value == _allValue) return const {};
    final parsed = int.tryParse(value);
    return parsed == null ? const {} : {parsed};
  }

  void _selectAllFiltered() {
    _selectedTemuanIds
      ..clear()
      ..addAll(_filteredTemuan.where((t) => t.id != null).map((t) => t.id!));
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectAllFiltered();
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

  List<String> get _statusOptions => [_allValue, 'Open', 'Closed'];

  List<String> get _risikoOptions => [_allValue, 'Medium', 'High', 'Extreme'];

  List<String> get _ulpOptions => [
    _allValue,
    ..._uniqueStrings(_allTemuan.map((t) => t.ulp)),
  ];

  List<String> get _penyulangOptions {
    if (_isAdmin) return [_allValue, ...Penyulang.semua];
    final ulps = _uniqueStrings(_allTemuan.map((t) => t.ulp));
    final List =
        ulps.isEmpty
            ? Penyulang.semua
            : ulps.expand((u) => Penyulang.untukUlp(u)).toSet().toList()
              ..sort();
    return [_allValue, ...penyulangList];
  }

  List<String> get _tipeOptions => [_allValue, TipeTemuan.kmu, TipeTemuan.row];

  List<String> get _zonaOptions => [
    _allValue,
    ..._uniqueInts(_allTemuan.map((t) => t.zona)),
  ];

  List<String> get _sectionOptions => [
    _allValue,
    ..._uniqueInts(_allTemuan.map((t) => t.section)),
  ];

  List<TemuanModel> get _selectedTemuan {
    return _filteredTemuan
        .where((t) => t.id != null && _selectedTemuanIds.contains(t.id))
        .toList();
  }

  List<String> _uniqueStrings(Iterable<String?> values) {
    final result =
        values
            .where((value) => value != null && value.trim().isNotEmpty)
            .map((value) => value!.trim())
            .toSet()
            .toList()
          ..sort();
    return result;
  }

  List<String> _uniqueInts(Iterable<int?> values) {
    final result = values.whereType<int>().toSet().toList()..sort();
    return result.map((value) => value.toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(title: const Text('Export Data')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildFilterSection(),
                  Divider(height: 1, color: context.borderColor),
                  if (_errorMessage != null)
                    Expanded(child: _buildTemuanList())
                  else if (_hasAppliedFilters) ...[
                    _buildSelectionHeader(),
                    Expanded(child: _buildTemuanList()),
                    _buildActionButtons(),
                  ] else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: context.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filter Data',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final fields = [
                _buildDateField(
                  label: 'Dari Tanggal',
                  date: _startDate,
                  onTap: () => _pickDate(true),
                ),
                _buildDateField(
                  label: 'Sampai Tanggal',
                  date: _endDate,
                  onTap: () => _pickDate(false),
                ),
                _buildDropdownField(
                  icon: Icons.assessment,
                  label: 'Status',
                  value: _selectedStatus,
                  items: _statusOptions,
                  onChanged:
                      (value) =>
                          setState(() => _selectedStatus = value ?? _allValue),
                ),
                _buildDropdownField(
                  icon: Icons.warning_amber,
                  label: 'Level Risiko',
                  value: _selectedRisiko,
                  items: _risikoOptions,
                  onChanged:
                      (value) =>
                          setState(() => _selectedRisiko = value ?? _allValue),
                ),
                _buildDropdownField(
                  icon: Icons.category,
                  label: 'Jenis Temuan',
                  value: _selectedTipe,
                  items: _tipeOptions,
                  onChanged:
                      (value) =>
                          setState(() => _selectedTipe = value ?? _allValue),
                ),
              ];

              return constraints.maxWidth >= 720
                  ? Row(children: _expandFields(fields))
                  : Column(
                    children: [
                      Row(children: _expandFields(fields.take(2).toList())),
                      const SizedBox(height: 10),
                      Row(children: _expandFields(fields.skip(2).toList())),
                    ],
                  );
            },
          ),
          const SizedBox(height: 10),
          _buildAdvancedFilters(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.filter_alt),
              label: const Text('Terapkan Filter'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _expandFields(List<Widget> fields) {
    return [
      for (var i = 0; i < fields.length; i++) ...[
        Expanded(child: fields[i]),
        if (i < fields.length - 1) const SizedBox(width: 8),
      ],
    ];
  }

  Widget _buildAdvancedFilters() {
    final fields = <Widget>[
      if (_isAdmin && _ulpOptions.length > 1)
        _buildDropdownField(
          icon: Icons.location_city,
          label: 'ULP',
          value: _selectedUlp,
          items: _ulpOptions,
          onChanged:
              (value) => setState(() => _selectedUlp = value ?? _allValue),
        ),
      _buildDropdownField(
        icon: Icons.electric_bolt,
        label: 'Penyulang',
        value: _selectedPenyulang,
        items: _penyulangOptions,
        onChanged:
            (value) => setState(() => _selectedPenyulang = value ?? _allValue),
      ),
      if (_zonaOptions.length > 1)
        _buildDropdownField(
          icon: Icons.radar,
          label: 'Zona',
          value: _selectedZona,
          items: _zonaOptions,
          itemBuilder: (value) => value == _allValue ? value : 'Zona $value',
          onChanged:
              (value) => setState(() => _selectedZona = value ?? _allValue),
        ),
      if (_sectionOptions.length > 1)
        _buildDropdownField(
          icon: Icons.account_tree,
          label: 'Section',
          value: _selectedSection,
          items: _sectionOptions,
          itemBuilder: (value) => value == _allValue ? value : 'Section $value',
          onChanged:
              (value) => setState(() => _selectedSection = value ?? _allValue),
        ),
    ];

    if (fields.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 720) {
          return Row(children: _expandFields(fields));
        }
        return Wrap(
          runSpacing: 10,
          spacing: 8,
          children:
              fields
                  .map(
                    (field) => SizedBox(
                      width: (constraints.maxWidth - 8) / 2,
                      child: field,
                    ),
                  )
                  .toList(),
        );
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(Icons.calendar_today, label),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: _fieldDecoration(),
            alignment: Alignment.centerLeft,
            child: Text(
              date == null ? 'Semua' : _formatDate(date),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.textPrimary, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String)? itemBuilder,
  }) {
    final normalizedValue = items.contains(value) ? value : _allValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(icon, label),
        const SizedBox(height: 4),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: _fieldDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: normalizedValue,
              isExpanded: true,
              dropdownColor: context.surfaceColor,
              icon: Icon(Icons.arrow_drop_down, color: context.textHint),
              style: TextStyle(color: context.textPrimary, fontSize: 12),
              items:
                  items.map((item) {
                    final label =
                        itemBuilder == null ? item : itemBuilder(item);
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.textHint),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: context.inputFillColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: context.borderColor),
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
    if (date == null) return;

    setState(() {
      if (isStart) {
        _startDate = date;
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = date;
        }
      } else {
        _endDate = date;
      }
    });
  }

  Widget _buildSelectionHeader() {
    final selectedCount = _selectedTemuanIds.length;
    final totalCount = _filteredTemuan.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: context.subtleSurface,
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
          Expanded(
            child: Text(
              '$totalCount hasil filter - $selectedCount dipilih',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
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
      return Center(
        child: Text(
          'Tidak ada data sesuai filter',
          style: TextStyle(color: context.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredTemuan.length,
      itemBuilder: (context, index) {
        final t = _filteredTemuan[index];
        final isSelected = t.id != null && _selectedTemuanIds.contains(t.id);
        final title =
            _valueOrDash(t.alamatTemuan) == '-'
                ? t.lokasi
                : _valueOrDash(t.alamatTemuan);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderColor),
          ),
          child: ListTile(
            leading: Checkbox(
              value: isSelected,
              onChanged:
                  t.id == null ? null : (val) => _toggleTemuan(t.id!, val),
            ),
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${_formatDate(t.tanggalTemuan)} - ${_valueOrDash(t.tipeTemuan)} - ${_valueOrDash(t.statusTemuan)} - ${_valueOrDash(t.levelRisiko)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: context.textSecondary, fontSize: 12),
            ),
            trailing:
                t.fotoUrls != null && t.fotoUrls!.isNotEmpty
                    ? Icon(Icons.image, color: context.textHint)
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    final selectedCount = _selectedTemuanIds.length;
    final canExport = selectedCount > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: context.surfaceColor,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canExport ? _previewPdf : null,
              icon: const Icon(Icons.preview),
              label: const Text('Preview PDF', overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: canExport ? _exportPdf : null,
              icon: const Icon(Icons.share),
              label: Text(
                'Export ($selectedCount)',
                overflow: TextOverflow.ellipsis,
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
      if (_selectedUlp == _allValue) return 'Semua ULP';
      return _selectedUlp;
    }

    final ulps = _uniqueStrings(selectedTemuan.map((t) => t.ulp));
    if (ulps.isEmpty) return '-';
    return ulps.join(', ');
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month/${d.year}';
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

  String _valueOrDash(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value;
  }
}
