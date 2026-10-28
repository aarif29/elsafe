import 'dart:async';
import 'package:elsafe/Screen/dashboard.dart';
import 'package:elsafe/config/app_theme.dart';
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
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? ThemeService.dark() : ThemeService.light(),
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
      home: DashboardScreen(temuanService: service, onLihatSemua: onOpen),
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

  testWidgets('Failed dashboard load does not claim there are no findings', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: ThemeService.light(), home: const DashboardScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dashboard belum dapat dimuat'), findsOneWidget);
    expect(find.text('Belum ada temuan'), findsNothing);
    expect(find.text('0'), findsNothing);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('Retry replaces initial failure with the existing summary', (
    tester,
  ) async {
    final service = DashboardFixtureService()..fail = true;
    await pumpDashboard(tester, service);
    expect(find.byType(DashboardStatsSection), findsNothing);
    service.fail = false;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard belum dapat dimuat'), findsNothing);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('Refresh failure identifies retained data and retry recovers', (
    tester,
  ) async {
    final service = DashboardFixtureService();
    await pumpDashboard(tester, service);
    service.fail = true;
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(find.text('Pembaruan dashboard gagal'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.textContaining('data terakhir'), findsOneWidget);
    service.fail = false;
    service.findings = [];
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Pembaruan dashboard gagal'), findsNothing);
    expect(find.text('Belum ada temuan'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('Thrown load error is recoverable and never becomes empty data', (
    tester,
  ) async {
    final service = DashboardFixtureService()..throwError = true;
    await pumpDashboard(tester, service);
    expect(find.text('Dashboard belum dapat dimuat'), findsOneWidget);
    expect(find.byType(DashboardStatsSection), findsNothing);
    expect(find.text('Belum ada temuan'), findsNothing);
  });

  testWidgets(
    'Late response after leaving dashboard does not update disposed state',
    (tester) async {
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
    },
  );

  for (final admin in [false, true]) {
    testWidgets(
      'Empty dashboard avoids unavailable create instruction (admin: $admin)',
      (tester) async {
        final service =
            DashboardFixtureService()
              ..isAdmin = admin
              ..findings = [];
        await pumpDashboard(tester, service);
        expect(find.text('Belum ada temuan'), findsOneWidget);
        expect(find.textContaining('Tap tombol +'), findsNothing);
        expect(find.text('Coba lagi'), findsNothing);
      },
    );
  }

  testWidgets('Counts, first-three order and list navigation are preserved', (
    tester,
  ) async {
    final service = DashboardFixtureService();
    var openedList = 0;
    await pumpDashboard(tester, service, onOpen: () => openedList++);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text(service.findings[3].namaPemilik), findsNothing);
    for (var i = 0; i < 2; i++) {
      expect(
        tester.getTopLeft(find.text(service.findings[i].namaPemilik)).dy,
        lessThan(
          tester.getTopLeft(find.text(service.findings[i + 1].namaPemilik)).dy,
        ),
      );
    }
    await tester.tap(find.text('Lihat Semua'));
    await tester.tap(find.text(service.findings.first.namaPemilik));
    expect(openedList, 2);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('On Progress'), findsOneWidget);
    expect(find.text('Closed'), findsOneWidget);
  });

  testWidgets('Missing status remains unknown in the dashboard row', (
    tester,
  ) async {
    final service = DashboardFixtureService();
    service.findings = [service.findings.last];
    await pumpDashboard(tester, service);
    expect(find.text('Status belum tersedia'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);
    expect(find.text('Open'), findsNothing);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'Dashboard and all K3 tips fit narrow enlarged text (dark: $dark)',
      (tester) async {
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
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Tips K3'));
        await tester.tap(find.text('Tips K3'));
        await tester.pumpAndSettle();
        const tips = [
          'Tidak ada yang lebih penting dari jiwa manusia.',
          'Bekerja itu jalan rezeki, berdoa itu sumber rezeki.',
          'Zero Harm, Zero Loss. Safety First.',
          'Zero accident, no tolerance!',
        ];
        for (final tip in tips) {
          expect(find.text(tip), findsOneWidget);
        }
        await tester.ensureVisible(find.text(tips.last));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
