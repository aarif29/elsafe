import 'dart:async';

import 'package:elsafe/Screen/dashboard.dart';
import 'package:elsafe/Screen/daftar_temuan.dart';
import 'package:elsafe/config/app_theme.dart';
import 'package:elsafe/config/temuan_model.dart';
import 'package:elsafe/widgets/daftar_temuan/temuan_detail_dialog.dart';
import 'package:elsafe/widgets/dashboard/dashboard_stats_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'support/dashboard_fixture.dart';

Future<void> pumpDashboard(
  WidgetTester tester,
  DashboardFixtureService service, {
  bool dark = false,
  double scale = 1,
  VoidCallback? onOpen,
  ValueChanged<TemuanModel>? onOpenTemuan,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? ThemeService.dark() : ThemeService.light(),
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              disableAnimations: true,
            ),
            child: child!,
          ),
      home: DashboardScreen(
        temuanService: service,
        onLihatSemua: onOpen,
        onOpenTemuan: onOpenTemuan,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'local-ui-test-key',
      debug: false,
      authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
    );
  });
  tearDownAll(() => Supabase.instance.dispose());

  testWidgets('failed load does not show a false zero', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: ThemeService.light(), home: const DashboardScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dashboard belum dapat dimuat'), findsOneWidget);
    expect(find.byType(DashboardStatsSection), findsNothing);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('retry replaces initial failure with Open summary', (
    tester,
  ) async {
    final service = DashboardFixtureService()..fail = true;
    await pumpDashboard(tester, service);
    expect(find.byType(DashboardStatsSection), findsNothing);

    service.fail = false;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard belum dapat dimuat'), findsNothing);
    expect(find.bySemanticsLabel('Temuan Open: 1'), findsOneWidget);
  });

  testWidgets('failed refresh retains last valid summary and retry recovers', (
    tester,
  ) async {
    final service = DashboardFixtureService();
    await pumpDashboard(tester, service);
    service.fail = true;
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(find.text('Pembaruan dashboard gagal'), findsOneWidget);
    expect(find.bySemanticsLabel('Temuan Open: 1'), findsOneWidget);
    expect(find.textContaining('data terakhir'), findsOneWidget);

    service.fail = false;
    service.findings = [];
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Pembaruan dashboard gagal'), findsNothing);
    expect(find.bySemanticsLabel('Temuan Open: 0'), findsOneWidget);
    expect(find.text('Tidak ada temuan Open'), findsOneWidget);
  });

  testWidgets('thrown load error is recoverable', (tester) async {
    final service = DashboardFixtureService()..throwError = true;
    await pumpDashboard(tester, service);
    expect(find.text('Dashboard belum dapat dimuat'), findsOneWidget);
    expect(find.byType(DashboardStatsSection), findsNothing);
  });

  testWidgets('late response after leaving dashboard does not update state', (
    tester,
  ) async {
    final result = Completer<Map<String, dynamic>>();
    final service = DashboardFixtureService()..pending = result;
    await tester.pumpWidget(
      MaterialApp(home: DashboardScreen(temuanService: service)),
    );
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    result.complete({'success': false});
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  for (final admin in [false, true]) {
    testWidgets(
      'empty state has no unavailable create prompt (admin: $admin)',
      (tester) async {
        final service =
            DashboardFixtureService()
              ..isAdmin = admin
              ..findings = [];
        await pumpDashboard(tester, service);
        expect(find.text('Tidak ada temuan Open'), findsOneWidget);
        expect(find.textContaining('Tap tombol +'), findsNothing);
        expect(find.text('Coba lagi'), findsNothing);
      },
    );
  }

  testWidgets('Open row and Buka daftar keep their navigation', (tester) async {
    final service = DashboardFixtureService();
    var openedList = 0;
    TemuanModel? openedTemuan;
    await pumpDashboard(
      tester,
      service,
      onOpen: () => openedList++,
      onOpenTemuan: (temuan) => openedTemuan = temuan,
    );
    expect(find.text(service.findings.first.lokasi), findsOneWidget);
    expect(find.text(service.findings[1].lokasi), findsNothing);
    await tester.tap(find.text('Buka daftar'));
    expect(openedList, 1);
    await tester.tap(find.text(service.findings.first.lokasi));
    expect(openedTemuan, same(service.findings.first));
  });

  testWidgets('dashboard opens finding detail without leaving dashboard', (
    tester,
  ) async {
    final service = DashboardFixtureService();
    final daftarKey = GlobalKey<DaftarTemuanScreenState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeService.light(),
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
        home: IndexedStack(
          index: 0,
          children: [
            DashboardScreen(
              temuanService: service,
              onOpenTemuan:
                  (temuan) => daftarKey.currentState!.showDetailDialog(temuan),
            ),
            DaftarTemuanScreen(key: daftarKey),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(service.findings.first.lokasi));
    await tester.pumpAndSettle();
    final dialog = tester.widget<TemuanDetailDialog>(
      find.byType(TemuanDetailDialog),
    );
    expect(dialog.temuan, same(service.findings.first));
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Daftar Temuan'), findsNothing);
  });

  testWidgets('missing status does not appear as Open', (tester) async {
    final service =
        DashboardFixtureService()..findings = [dashboardExampleFindings().last];
    await pumpDashboard(tester, service);
    expect(find.bySemanticsLabel('Temuan Open: 0'), findsOneWidget);
    expect(find.text('Tidak ada temuan Open'), findsOneWidget);
    expect(find.text(service.findings.first.lokasi), findsNothing);
  });

  for (final dark in [false, true]) {
    testWidgets('dashboard fits narrow enlarged text (dark: $dark)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpDashboard(
        tester,
        DashboardFixtureService(),
        dark: dark,
        scale: 1.5,
      );
      await tester.ensureVisible(find.text('Temuan Open per penyulang'));
      expect(tester.takeException(), isNull);
    });
  }
}
