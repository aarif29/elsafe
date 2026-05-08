import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_logger.dart';
import '../config/snackbar.dart';
import '../config/temuan_service.dart';
import '../config/temuan_model.dart';
import '../config/temuan_types.dart';
import '../config/ulp_service.dart';
import '../widgets/daftar_temuan/temuan_list_item.dart';
import '../widgets/daftar_temuan/temuan_detail_dialog.dart';
import 'edit_temuan.dart';

class DaftarTemuanScreen extends StatefulWidget {
  final VoidCallback? onOpenExport;

  const DaftarTemuanScreen({super.key, this.onOpenExport});

  @override
  State<DaftarTemuanScreen> createState() => DaftarTemuanScreenState();
}

class DaftarTemuanScreenState extends State<DaftarTemuanScreen> {
  final _temuanService = TemuanService();
  final _ulpService = UlpService();
  final ScrollController _scrollController = ScrollController();

  bool _isAdmin = false;

  static const int _pageSize = 10;

  List<TemuanModel> _temuanList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  String? _errorMessage;
  bool _hasLoadedOnce = false;

  // Search & filter
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'Semua'; // 'Semua', 'Open', 'Close'
  String _filterTipe = 'Semua'; // 'Semua', 'KMU', 'ROW'
  String _filterKategori = 'Semua'; // 'Semua', 'Medium', 'High', 'Extreme'
  String _filterUlp = 'Semua';
  String _filterPenyulang = 'Semua';

  List<TemuanModel> get _filteredList {
    return _temuanList.where((t) {
      final matchStatus =
          _filterStatus == 'Semua' ||
          t.statusTemuan == _filterStatus ||
          (_filterStatus == 'Close' && t.statusTemuan == 'Closed');
      final matchTipe = _filterTipe == 'Semua' || t.tipeTemuan == _filterTipe;
      final matchKategori =
          _filterKategori == 'Semua' || t.levelRisiko == _filterKategori;
      final matchUlp = _filterUlp == 'Semua' || t.ulp == _filterUlp;
      final matchPenyulang =
          _filterPenyulang == 'Semua' || t.namaPenyulang == _filterPenyulang;
      if (_searchQuery.isEmpty) {
        return matchStatus &&
            matchTipe &&
            matchKategori &&
            matchUlp &&
            matchPenyulang;
      }
      final q = _searchQuery.toLowerCase();
      return matchStatus &&
          matchTipe &&
          matchKategori &&
          matchUlp &&
          matchPenyulang &&
          (t.namaPemilik.toLowerCase().contains(q) ||
              t.lokasi.toLowerCase().contains(q) ||
              t.deskripsiTemuan.toLowerCase().contains(q));
    }).toList();
  }

  List<String> get _ulpOptions {
    final ulps =
        _temuanList
            .map((t) => t.ulp ?? '')
            .where((u) => u.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['Semua', ...ulps];
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreData();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      appLog.d('🔄 didChangeDependencies - loading data...');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _isAdmin = await _ulpService.isAdmin();
        _loadData();
      });
    }
  }

  void loadData() => _loadData();

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _temuanList = [];
      _currentPage = 0;
      _hasMoreData = true;
    });

    final result = await _temuanService.getTemuanPaginated(
      page: 0,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    setState(() {
      if (result['success']) {
        _temuanList = result['data'] ?? [];
        _hasMoreData = result['hasMore'] ?? false;
        _currentPage = 1;
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] ?? 'Error tidak diketahui';
      }
      _isLoading = false;
    });
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;
    setState(() => _isLoadingMore = true);

    final result = await _temuanService.getTemuanPaginated(
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (!mounted) return;

    setState(() {
      if (result['success']) {
        _temuanList.addAll(result['data'] ?? []);
        _hasMoreData = result['hasMore'] ?? false;
        _currentPage++;
      }
      _isLoadingMore = false;
    });
  }

  Future<void> _deleteTemuan(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
      if (!mounted) return;
      SnackBarUtils.showLoading(context, message: 'Menghapus data...');

      try {
        final result = await _temuanService.deleteTemuanSilent(id);

        if (!mounted) return;
        SnackBarUtils.hide(context);
        if (result['success']) {
          SnackBarUtils.showSuccess(
            context,
            title: 'Berhasil!',
            message: 'Data berhasil dihapus',
          );
          _loadData();
        } else {
          SnackBarUtils.showError(
            context,
            title: 'Gagal!',
            message: 'Gagal menghapus: ${result['message']}',
          );
        }
      } catch (e) {
        if (!mounted) return;
        SnackBarUtils.hide(context);
        SnackBarUtils.showError(
          context,
          title: 'Error!',
          message: e.toString(),
        );
      }
    }
  }

  Future<void> _openGoogleMaps(
    double latitude,
    double longitude,
    String lokasi,
  ) async {
    try {
      final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$lokasi',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          SnackBarUtils.showInfo(
            context,
            title: 'Maps',
            message: 'Membuka lokasi di Google Maps...',
          );
        }
      } else {
        throw Exception('Tidak dapat membuka Google Maps');
      }
    } catch (e) {
      appLog.e('❌ Error membuka Google Maps', error: e);
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Error!',
          message: 'Gagal membuka Google Maps: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _copyCoordinates(double latitude, double longitude) async {
    try {
      final coordinates = '$latitude, $longitude';
      await Clipboard.setData(ClipboardData(text: coordinates));
      if (!mounted) return;
      SnackBarUtils.showSuccess(
        context,
        title: 'Disalin!',
        message: 'Koordinat: $coordinates',
      );
    } catch (e) {
      if (!mounted) return;
      SnackBarUtils.showError(
        context,
        title: 'Error!',
        message: 'Gagal menyalin koordinat',
      );
    }
  }

  void _showDetailDialog(TemuanModel temuan) {
    showDialog(
      context: context,
      builder:
          (context) => TemuanDetailDialog(
            temuan: temuan,
            onOpenMaps: _openGoogleMaps,
            onCopyCoordinates: _copyCoordinates,
            onEdit:
                _isAdmin
                    ? null
                    : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditTemuanScreen(temuan: temuan),
                        ),
                      );
                      if (result == true) _loadData();
                    },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Temuan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export Data',
            onPressed: widget.onOpenExport,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [_buildSearchAndFilter(), Expanded(child: _buildBody())],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: context.surfaceColor,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'Cari nama, lokasi, deskripsi...',
              hintStyle: TextStyle(color: context.textHint),
              prefixIcon: Icon(Icons.search, color: context.textHint, size: 20),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: context.textHint,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                      : null,
              filled: true,
              fillColor: context.inputFillColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 10),

          // Filter row with dropdowns
          Row(
            children: [
              // ULP filter - hanya untuk admin
              if (_isAdmin) ...[
                Expanded(
                  child: _buildFilterDropdown(
                    icon: Icons.location_on,
                    label: 'ULP',
                    value: _filterUlp,
                    items: _ulpOptions,
                    onChanged: (v) => setState(() => _filterUlp = v!),
                    itemBuilder: (item) => item == 'Semua' ? 'Semua ULP' : item,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              // Status filter
              Expanded(
                child: _buildFilterDropdown(
                  icon: Icons.assessment,
                  label: 'Status',
                  value: _filterStatus,
                  items: const ['Semua', 'Open', 'Closed'],
                  onChanged: (v) => setState(() => _filterStatus = v!),
                ),
              ),
              const SizedBox(width: 4),
              // Tipe filter
              Expanded(
                child: _buildFilterDropdown(
                  icon: Icons.category,
                  label: 'Tipe',
                  value: _filterTipe,
                  items: const ['Semua', 'KMU', 'ROW'],
                  onChanged: (v) => setState(() => _filterTipe = v!),
                ),
              ),
              const SizedBox(width: 4),
              // Kategori filter
              Expanded(
                child: _buildFilterDropdown(
                  icon: Icons.warning_amber,
                  label: 'Kategori',
                  value: _filterKategori,
                  items: const ['Semua', 'Medium', 'High', 'Extreme'],
                  onChanged: (v) => setState(() => _filterKategori = v!),
                ),
              ),
              const SizedBox(width: 4),
              // Penyulang filter
              Expanded(
                child: _buildFilterDropdown(
                  icon: Icons.electric_bolt,
                  label: 'Penyulang',
                  value: _filterPenyulang,
                  items: ['Semua', ...Penyulang.semua],
                  onChanged: (v) => setState(() => _filterPenyulang = v!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    String Function(String)? itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: context.textHint),
            const SizedBox(width: 4),
            Text(
              '$label:',
              style: TextStyle(
                color: context.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: context.inputFillColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderColor),
          ),
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: context.surfaceColor,
            style: TextStyle(color: context.textPrimary, fontSize: 12),
            icon: Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: context.textHint,
            ),
            items:
                items.map((item) {
                  final displayText =
                      itemBuilder != null ? itemBuilder(item) : item;
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      displayText,
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
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => const _SkeletonListItem(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: context.textSecondary),
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

    final filtered = _filteredList;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Tidak Ada Hasil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba kata kunci atau filter lain',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length + 1,
      itemBuilder: (context, index) {
        if (index == filtered.length) {
          if (_isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          if (!_hasMoreData && filtered.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Semua data sudah ditampilkan (${_temuanList.length} temuan)',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final temuan = filtered[index];
        return TemuanListItem(
          temuan: temuan,
          onTap: () => _showDetailDialog(temuan),
          canModify: !_isAdmin,
          onEdit:
              _isAdmin
                  ? null
                  : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTemuanScreen(temuan: temuan),
                      ),
                    );
                    if (result == true) _loadData();
                  },
          onDelete: _isAdmin ? null : () => _deleteTemuan(temuan.id!),
        );
      },
    );
  }
}

class _SkeletonListItem extends StatefulWidget {
  const _SkeletonListItem();

  @override
  State<_SkeletonListItem> createState() => _SkeletonListItemState();
}

class _SkeletonListItemState extends State<_SkeletonListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final color = Colors.grey.withValues(alpha: _animation.value);
        return Card(
          color: Colors.grey[800],
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 140,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
