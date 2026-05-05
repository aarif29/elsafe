import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/temuan_model.dart';
import '../config/temuan_service.dart';
import '../config/ulp_service.dart';

class ExportTemuanScreen extends StatefulWidget {
  const ExportTemuanScreen({super.key});

  @override
  State<ExportTemuanScreen> createState() => _ExportTemuanScreenState();
}

class _ExportTemuanScreenState extends State<ExportTemuanScreen> {
  final _temuanService = TemuanService();
  final _ulpService = UlpService();

  List<TemuanModel> _allTemuan = [];
  List<TemuanModel> _filteredTemuan = [];
  bool _isLoading = true;

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  Set<String> _selectedStatuses = {'Open', 'Closed', 'On Progress'};
  Set<String> _selectedRisiko = {'Tinggi', 'Sedang', 'Rendah'};
  Set<int> _selectedZonas = {1, 2, 3, 4, 5};
  Set<int> _selectedSections = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
  String? _selectedPenyulang;
  String? _currentUlp;
  bool _isAdmin = false;

  // Selection
  final Set<String> _selectedTemuanIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final profile = await _ulpService.getCurrentUserProfile();
    setState(() {
      _currentUlp = profile?['ulp'] as String?;
      _isAdmin = profile?['role'] == 'admin';
    });

    final result = await _temuanService.getAllTemuanSilent();
    if (result['success']) {
      setState(() {
        _allTemuan = result['data'];
        _filteredTemuan = _allTemuan;
        _isLoading = false;
        _selectedTemuanIds.addAll(_filteredTemuan.map((t) => t.id!));
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTemuan = _allTemuan.where((t) {
        // Date filter
        if (_startDate != null && t.tanggalTemuan.isBefore(_startDate!)) return false;
        if (_endDate != null && t.tanggalTemuan.isAfter(_endDate!)) return false;

        // Status filter
        if (_selectedStatuses.isNotEmpty && t.statusTemuan != null) {
          if (!_selectedStatuses.contains(t.statusTemuan)) return false;
        }

        // Risiko filter
        if (_selectedRisiko.isNotEmpty && t.levelRisiko != null) {
          if (!_selectedRisiko.contains(t.levelRisiko)) return false;
        }

        // Zona filter
        if (_selectedZonas.isNotEmpty && t.zona != null) {
          if (!_selectedZonas.contains(t.zona)) return false;
        }

        // Section filter
        if (_selectedSections.isNotEmpty && t.section != null) {
          if (!_selectedSections.contains(t.section)) return false;
        }

        // Penyulang filter
        if (_selectedPenyulang != null && t.namaPenyulang != null) {
          if (t.namaPenyulang != _selectedPenyulang) return false;
        }

        return true;
      }).toList();

      _selectedTemuanIds.clear();
      _selectedTemuanIds.addAll(_filteredTemuan.map((t) => t.id!));
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedTemuanIds.addAll(_filteredTemuan.map((t) => t.id!));
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
    final penyulangs = _allTemuan
        .where((t) => t.namaPenyulang != null)
        .map((t) => t.namaPenyulang!)
        .toSet()
        .toList();
    penyulangs.sort();
    return penyulangs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        title: const Text('Export Temuan'),
        backgroundColor: const Color(0xFF2D2D3D),
      ),
      body: _isLoading
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
          const Text('Filter Data', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
            values: {'Open', 'Closed', 'On Progress'},
            selected: _selectedStatuses,
            onChanged: (val) => setState(() => _selectedStatuses = val),
          ),
          const SizedBox(height: 8),

          // Level Risiko
          _buildMultiSelectChip(
            label: 'Level Risiko',
            values: {'Tinggi', 'Sedang', 'Rendah'},
            selected: _selectedRisiko,
            onChanged: (val) => setState(() => _selectedRisiko = val),
          ),
          const SizedBox(height: 8),

          // Zona
          _buildMultiSelectChip(
            label: 'Zona',
            values: {'1', '2', '3', '4', '5'},
            selected: _selectedZonas.map((i) => i.toString()).toSet(),
            onChanged: (val) => setState(() => _selectedZonas = val.map((s) => int.parse(s)).toSet()),
            isNumeric: true,
          ),
          const SizedBox(height: 8),

          // Section
          _buildMultiSelectChip(
            label: 'Section',
            values: Set.from(List.generate(10, (i) => (i + 1).toString())),
            selected: _selectedSections.map((i) => i.toString()).toSet(),
            onChanged: (val) => setState(() => _selectedSections = val.map((s) => int.parse(s)).toSet()),
            isNumeric: true,
          ),

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
                  hint: const Text('Pilih Penyulang (Opsional)', style: TextStyle(color: Colors.white70)),
                  isExpanded: true,
                  dropdownColor: Colors.grey[850],
                  style: const TextStyle(color: Colors.white),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Semua')),
                    ..._penyulangList.map((p) => DropdownMenuItem<String?>(value: p, child: Text(p))),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
              child: const Text('Terapkan Filter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({required String label, required DateTime? date, required VoidCallback onTap}) {
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
              date != null ? '${date.day}/${date.month}/${date.year}' : label,
              style: TextStyle(color: date != null ? Colors.white : Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
    required Set<String> values,
    required Set<String> selected,
    required Function(Set<String>) onChanged,
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: values.map((v) {
            final isSelected = selected.contains(v);
            return FilterChip(
              label: Text(isNumeric ? 'Zona $v' : v),
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
              labelStyle: TextStyle(color: isSelected ? Colors.blue : Colors.white70, fontSize: 12),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectionHeader() {
    final selectedCount = _selectedTemuanIds.length;
    final totalCount = _filteredTemuan.length;
    final allSelected = selectedCount == totalCount && totalCount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF252535),
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            tristate: selectedCount > 0 && selectedCount < totalCount,
            onChanged: _toggleSelectAll,
          ),
          Text(
            'Pilih Semua ($selectedCount/$totalCount)',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTemuanList() {
    if (_filteredTemuan.isEmpty) {
      return const Center(
        child: Text('Tidak ada data temuan', style: TextStyle(color: Colors.white70)),
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
              onChanged: (val) => _toggleTemuan(t.id!, val),
            ),
            title: Text(
              t.lokasi,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${_formatDate(t.tanggalTemuan)} • ${t.statusTemuan ?? "-"} • ${t.levelRisiko ?? "-"}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            trailing: t.fotoUrls != null && t.fotoUrls!.isNotEmpty
                ? const Icon(Icons.image, color: Colors.white70)
                : null,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: selectedCount > 0 ? () => _exportPdf() : null,
              icon: const Icon(Icons.share),
              label: Text('Export ($selectedCount)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _previewPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preview PDF - implementasikan di Phase 3')),
    );
  }

  void _exportPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export PDF - implementasikan di Phase 3')),
    );
  }
}