import 'package:flutter/material.dart';
import '../config/app_logger.dart';
import '../config/app_theme.dart';
import '../config/temuan_service.dart';
import '../config/temuan_model.dart';
import '../widgets/dashboard/dashboard_welcome_card.dart';
import '../widgets/dashboard/dashboard_stats_section.dart';
import '../widgets/dashboard/dashboard_recent_activity.dart';
import '../widgets/dashboard/dashboard_info_section.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onLihatSemua;
  final TemuanService? temuanService;

  const DashboardScreen({super.key, this.onLihatSemua, this.temuanService});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late final TemuanService _temuanService;
  int _totalTemuan = 0;
  int _temuanBulanIni = 0;
  String _userName = 'User';
  bool _isLoading = false;
  bool _hasData = false;
  bool _loadFailed = false;
  DateTime? _lastUpdated;
  List<TemuanModel> _recentTemuan = [];

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
      if (profile != null) {
        setState(() {
          _userName =
              profile['full_name'] ??
              profile['nip'] ??
              _temuanService.currentUserEmail?.split('@')[0] ??
              'User';
        });
      }

      final allTemuan = await _temuanService.getAllTemuanSilent();
      if (!mounted) return;
      if (allTemuan['success'] == true) {
        final temuanList = allTemuan['data'] as List<TemuanModel>;
        final now = DateTime.now();
        setState(() {
          _totalTemuan = temuanList.length;
          _temuanBulanIni =
              temuanList
                  .where(
                    (t) =>
                        t.tanggalTemuan.month == now.month &&
                        t.tanggalTemuan.year == now.year,
                  )
                  .length;
          _recentTemuan = temuanList.take(3).toList();
          _hasData = true;
          _lastUpdated = now;
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
              style: TextButton.styleFrom(
                foregroundColor:
                    context.isDark
                        ? Colors.blue.shade300
                        : Colors.blue.shade800,
              ),
              onPressed: _isLoading ? null : _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final welcome = DashboardWelcomeCard(userName: _userName);
        final greeting = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            welcome,
            if (_lastUpdated case final updated?) ...[
              const SizedBox(height: 4),
              Text(
                'Diperbarui ${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: context.textSecondary, fontSize: 14),
              ),
            ],
          ],
        );
        final stats = DashboardStatsSection(
          totalTemuan: _totalTemuan,
          temuanBulanIni: _temuanBulanIni,
        );
        if (constraints.maxWidth >=
            800 * MediaQuery.textScalerOf(context).scale(1)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: greeting),
              const SizedBox(width: 32),
              SizedBox(width: 360, child: stats),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [greeting, const SizedBox(height: 16), stats],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Buka menu',
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Dashboard'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.instance.themeMode,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                onPressed: () {
                  ThemeService.instance.setTheme(
                    mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                  );
                },
                tooltip: mode == ThemeMode.dark ? 'Mode Terang' : 'Mode Gelap',
              );
            },
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
                  if (_hasData) ...[
                    _buildSummary(),
                    const SizedBox(height: 24),
                    DashboardRecentActivity(
                      recentTemuan: _recentTemuan,
                      onLihatSemua: widget.onLihatSemua ?? () {},
                    ),
                    const SizedBox(height: 24),
                    const DashboardInfoSection(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
