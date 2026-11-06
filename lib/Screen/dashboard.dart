import 'package:flutter/material.dart';

import '../config/app_logger.dart';
import '../config/app_theme.dart';
import '../config/temuan_model.dart';
import '../config/temuan_service.dart';
import '../config/ulp_list.dart';
import '../widgets/dashboard/dashboard_area_section.dart';
import '../widgets/dashboard/dashboard_overview.dart';
import '../widgets/dashboard/dashboard_recent_activity.dart';
import '../widgets/dashboard/dashboard_stats_section.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onLihatSemua;
  final ValueChanged<TemuanModel>? onOpenTemuan;
  final TemuanService? temuanService;

  const DashboardScreen({
    super.key,
    this.onLihatSemua,
    this.onOpenTemuan,
    this.temuanService,
  });

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late final TemuanService _temuanService;
  List<TemuanModel> _allTemuan = [];
  String _userName = 'User';
  String? _userUlp;
  String? _selectedUlp;
  bool _isAdmin = false;
  bool _isLoading = false;
  bool _hasData = false;
  bool _loadFailed = false;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _temuanService = widget.temuanService ?? TemuanService();
    _loadDashboardData();
  }

  void loadData() => _loadDashboardData();

  Future<void> _loadDashboardData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final profile = await _temuanService.getCurrentUserProfile();
      if (!mounted) return;
      final result = await _temuanService.getAllTemuanSilent();
      if (!mounted) return;
      if (result['success'] == true) {
        final findings = result['data'] as List<TemuanModel>;
        setState(() {
          _userName =
              profile?['full_name']?.toString() ??
              profile?['nip']?.toString() ??
              _temuanService.currentUserEmail?.split('@')[0] ??
              'User';
          _userUlp = profile?['ulp']?.toString();
          _isAdmin = profile?['role'] == 'admin' || result['isAdmin'] == true;
          _allTemuan = findings;
          _hasData = true;
          _lastUpdated = DateTime.now();
        });
      } else {
        setState(() => _loadFailed = true);
      }
    } catch (e) {
      appLog.e('Error loading dashboard', error: e);
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> get _availableUlps {
    final names = <String, String>{};
    for (final finding in _allTemuan) {
      if (finding.ulp?.trim().isNotEmpty != true) continue;
      final name = namaUlpKanonis(finding.ulp!);
      names.putIfAbsent(name.toLowerCase(), () => name);
    }
    if (_selectedUlp != null) {
      final name = namaUlpKanonis(_selectedUlp!);
      names.putIfAbsent(name.toLowerCase(), () => name);
    }
    final values = names.values.toList()..sort();
    return values;
  }

  DashboardOverview get _overview => DashboardOverview.fromFindings(
    _allTemuan,
    selectedUlp:
        _isAdmin
            ? _selectedUlp
            : (_userUlp?.trim().isNotEmpty == true ? _userUlp : null),
    groupByUlp: _isAdmin && _selectedUlp == null,
  );

  String get _scopeLabel {
    if (_isAdmin && _selectedUlp == null) return 'Semua ULP';
    final ulp = _isAdmin ? _selectedUlp : _userUlp;
    return ulp?.trim().isNotEmpty == true
        ? 'ULP ${namaUlp(ulp!)}'
        : 'Temuan saya';
  }

  Widget _buildLoadError() {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _hasData
                  ? 'Pembaruan dashboard gagal'
                  : 'Dashboard belum dapat dimuat',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasData
                  ? 'Menampilkan data terakhir yang berhasil dimuat. Coba lagi untuk memperbarui.'
                  : 'Data temuan belum tersedia. Periksa koneksi Anda, lalu coba lagi.',
              style: TextStyle(color: context.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _isLoading ? null : _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan potensi bahaya',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$_scopeLabel · $_userName',
          style: TextStyle(color: context.textSecondary, fontSize: 14),
        ),
        if (_lastUpdated case final updated?) ...[
          const SizedBox(height: 3),
          Text(
            'Diperbarui ${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')}',
            style: TextStyle(color: context.textSecondary, fontSize: 12),
          ),
        ],
      ],
    );
    if (!_isAdmin) return heading;

    final dropdown = DropdownButtonFormField<String>(
      key: const Key('dashboard-ulp-filter'),
      value: _selectedUlp ?? '',
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Cakupan ULP',
        prefixIcon: Icon(Icons.filter_alt_outlined),
      ),
      items: [
        const DropdownMenuItem(value: '', child: Text('Semua ULP')),
        for (final ulp in _availableUlps)
          DropdownMenuItem(
            value: ulp,
            child: Text(ulp, key: Key('dashboard-ulp-option-$ulp')),
          ),
      ],
      onChanged:
          (value) => setState(() {
            _selectedUlp = value == null || value.isEmpty ? null : value;
          }),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 650) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [heading, const SizedBox(height: 18), dropdown],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            const SizedBox(width: 24),
            SizedBox(width: 250, child: dropdown),
          ],
        );
      },
    );
  }

  Widget _buildOverview() {
    final overview = _overview;
    final groupByUlp = _isAdmin && _selectedUlp == null;
    final area = DashboardAreaSection(
      overview: overview,
      groupByUlp: groupByUlp,
    );
    final openList = DashboardRecentActivity(
      recentTemuan: overview.priorityOpen.take(4).toList(),
      onLihatSemua: widget.onLihatSemua ?? () {},
      onOpenTemuan: widget.onOpenTemuan ?? (_) {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 22),
        DashboardStatsSection(overview: overview),
        const SizedBox(height: 30),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [area, const SizedBox(height: 28), openList],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: area),
                const SizedBox(width: 36),
                Expanded(flex: 3, child: openList),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Buka menu',
          onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
        ),
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.instance.themeMode,
            builder:
                (context, mode, _) => IconButton(
                  icon: Icon(
                    mode == ThemeMode.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  onPressed:
                      () => ThemeService.instance.setTheme(
                        mode == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark,
                      ),
                  tooltip:
                      mode == ThemeMode.dark ? 'Mode Terang' : 'Mode Gelap',
                ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDashboardData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width >= 800 ? 24 : 16,
            24,
            MediaQuery.sizeOf(context).width >= 800 ? 24 : 16,
            80,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isLoading) ...[
                    const LinearProgressIndicator(
                      semanticsLabel: 'Memuat dashboard',
                    ),
                    const SizedBox(height: 16),
                    if (!_hasData)
                      Text(
                        'Memuat dashboard…',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                  ],
                  if (_loadFailed) _buildLoadError(),
                  if (_hasData) _buildOverview(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
