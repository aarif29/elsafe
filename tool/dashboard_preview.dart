// Local-only UI preview. Not imported by lib/main.dart and never connects to Supabase.
import 'package:elsafe/Screen/dashboard.dart';
import 'package:elsafe/config/app_theme.dart';
import 'package:elsafe/widgets/adaptive_shell_scaffold.dart';
import 'package:flutter/material.dart';
import '../test/support/dashboard_fixture.dart';

void main() {
  final query = Uri.base.queryParameters;
  final fixture = DashboardFixtureService()..fail = query['state'] == 'error';
  if (query['state'] == 'empty') fixture.findings = [];
  ThemeService.instance.themeMode.value =
      query['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light;
  runApp(_Preview(service: fixture));
}

class _Preview extends StatelessWidget {
  final DashboardFixtureService service;
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
                    floatingActionButton: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
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
