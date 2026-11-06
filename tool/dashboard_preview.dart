// Local-only UI preview. Not imported by lib/main.dart and never connects to Supabase.
import 'package:elsafe/Screen/dashboard.dart';
import 'package:elsafe/config/app_theme.dart';
import 'package:elsafe/config/temuan_model.dart';
import 'package:elsafe/config/temuan_service.dart';
import 'package:elsafe/widgets/adaptive_shell_scaffold.dart';
import 'package:flutter/material.dart';

void main() {
  final query = Uri.base.queryParameters;
  final fixture =
      _PreviewService()
        ..fail = query['state'] == 'error'
        ..isAdmin = query['role'] == 'admin';
  if (query['state'] == 'empty') fixture.findings = [];
  ThemeService.instance.themeMode.value =
      query['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light;
  runApp(_Preview(service: fixture));
}

class _Preview extends StatelessWidget {
  final _PreviewService service;
  const _Preview({required this.service});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeMode,
      builder:
          (context, mode, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ELSAFE — Pratinjau dashboard, data contoh',
            theme: ThemeService.light(),
            darkTheme: ThemeService.dark(),
            themeMode: mode,
            home: Column(
              children: [
                Material(
                  color:
                      mode == ThemeMode.dark
                          ? const Color(0xFF212121)
                          : Colors.white,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: Text(
                        'Pratinjau lokal • Data contoh, bukan data operasional',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AdaptiveShellScaffold(
                    selectedIndex: 0,
                    onDestinationSelected: (_) {},
                    drawer: const Drawer(
                      child: SafeArea(child: Text('Menu pratinjau')),
                    ),
                    body: DashboardScreen(
                      temuanService: service,
                      onLihatSemua: () {},
                    ),
                    floatingActionButton:
                        service.isAdmin
                            ? null
                            : Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1E88E5),
                                    Color(0xFF1565C0),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: FloatingActionButton(
                                tooltip: 'Tambah Temuan (pratinjau)',
                                onPressed: () {},
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                child: const Icon(Icons.add, size: 28),
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _PreviewService implements TemuanService {
  bool fail = false;
  bool isAdmin = false;
  List<TemuanModel> findings = [
    _finding(
      'Pohon dekat jaringan',
      'Batu',
      'Batu',
      'ROW',
      'Extreme',
      'Open',
      3,
    ),
    _finding(
      'Aktivitas di sekitar tiang',
      'Batu',
      'Junrejo',
      'KMU',
      'High',
      'Open',
      6,
    ),
    _finding(
      'Bangunan dekat jaringan',
      'Batu',
      'Batu',
      'KMU',
      'Medium',
      'Open',
      11,
    ),
    _finding(
      'Baliho di jalur jaringan',
      'Singosari',
      'Singosari',
      'ROW',
      'High',
      'Open',
      7,
    ),
    _finding(
      'Pohon sudah ditangani',
      'Batu',
      'Pujon',
      'ROW',
      'High',
      'Closed',
      9,
    ),
  ];

  static TemuanModel _finding(
    String lokasi,
    String ulp,
    String penyulang,
    String tipe,
    String risiko,
    String status,
    int day,
  ) => TemuanModel(
    lokasi: lokasi,
    namaPemilik: 'Contoh',
    tanggalTemuan: DateTime(2026, 10, day),
    deskripsiTemuan: 'Data contoh untuk pemeriksaan tampilan.',
    statusTemuan: status,
    tipeTemuan: tipe,
    levelRisiko: risiko,
    ulp: ulp,
    namaPenyulang: penyulang,
  );

  @override
  String? get currentUserEmail => 'preview@example.invalid';

  @override
  Future<Map<String, dynamic>?> getCurrentUserProfile() async => {
    'full_name': 'Petugas Contoh',
    'role': isAdmin ? 'admin' : 'user',
    'ulp': isAdmin ? null : 'Batu',
  };

  @override
  Future<Map<String, dynamic>> getAllTemuanSilent() async => {
    'success': !fail,
    'data':
        fail
            ? <TemuanModel>[]
            : isAdmin
            ? findings
            : findings.where((finding) => finding.ulp == 'Batu').toList(),
    'isAdmin': isAdmin,
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
