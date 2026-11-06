import 'package:elsafe/Screen/dashboard.dart';
import 'package:elsafe/config/app_theme.dart';
import 'package:elsafe/config/temuan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/dashboard_fixture.dart';

TemuanModel finding({
  required String id,
  required String ulp,
  required String status,
  required String type,
  required String penyulang,
}) => TemuanModel(
  id: id,
  lokasi: 'Lokasi $id',
  namaPemilik: 'Pemilik $id',
  tanggalTemuan: DateTime(2026, 10, 1),
  deskripsiTemuan: 'Temuan $id',
  statusTemuan: status,
  tipeTemuan: type,
  ulp: ulp,
  namaPenyulang: penyulang,
);

Future<void> pumpDashboard(
  WidgetTester tester,
  DashboardFixtureService service,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeService.light(),
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
      home: DashboardScreen(temuanService: service),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('admin starts with all ULP then filters every Open view', (
    tester,
  ) async {
    final service =
        DashboardFixtureService()
          ..isAdmin = true
          ..findings = [
            finding(
              id: 'batu',
              ulp: 'Batu',
              status: 'Open',
              type: 'KMU',
              penyulang: 'Batu',
            ),
            finding(
              id: 'singosari',
              ulp: 'Singosari',
              status: 'Open',
              type: 'ROW',
              penyulang: 'Singosari',
            ),
            finding(
              id: 'done',
              ulp: 'Batu',
              status: 'Closed',
              type: 'KMU',
              penyulang: 'Batu',
            ),
          ];
    await pumpDashboard(tester, service);

    expect(find.byKey(const Key('dashboard-ulp-filter')), findsOneWidget);
    expect(find.bySemanticsLabel('Temuan Open: 2'), findsOneWidget);
    expect(find.text('Lokasi batu'), findsOneWidget);
    expect(find.text('Lokasi singosari'), findsOneWidget);
    expect(find.text('Lokasi done'), findsNothing);

    await tester.tap(find.byKey(const Key('dashboard-ulp-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dashboard-ulp-option-Batu')).last);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Temuan Open: 1'), findsOneWidget);
    expect(find.text('Lokasi batu'), findsOneWidget);
    expect(find.text('Lokasi singosari'), findsNothing);
    expect(find.text('Temuan Open per penyulang'), findsOneWidget);
  });

  testWidgets('petugas sees only the ULP from their profile', (tester) async {
    final service =
        DashboardFixtureService()
          ..findings = [
            finding(
              id: 'batu',
              ulp: 'ULP Batu',
              status: 'Open',
              type: 'KMU',
              penyulang: 'Batu',
            ),
            finding(
              id: 'other',
              ulp: 'Singosari',
              status: 'Open',
              type: 'ROW',
              penyulang: 'Singosari',
            ),
          ];
    await pumpDashboard(tester, service);

    expect(find.byKey(const Key('dashboard-ulp-filter')), findsNothing);
    expect(find.bySemanticsLabel('Temuan Open: 1'), findsOneWidget);
    expect(find.text('Lokasi batu'), findsOneWidget);
    expect(find.text('Lokasi other'), findsNothing);
  });

  testWidgets('admin has one option for equivalent ULP spellings', (
    tester,
  ) async {
    final service =
        DashboardFixtureService()
          ..isAdmin = true
          ..findings = [
            finding(
              id: 'a',
              ulp: 'Batu',
              status: 'Open',
              type: 'KMU',
              penyulang: 'A',
            ),
            finding(
              id: 'b',
              ulp: 'batu',
              status: 'Open',
              type: 'ROW',
              penyulang: 'B',
            ),
            finding(
              id: 'c',
              ulp: 'ULP Batu',
              status: 'Open',
              type: 'KMU',
              penyulang: 'C',
            ),
          ];
    await pumpDashboard(tester, service);

    expect(find.bySemanticsLabel('Temuan Open: 3'), findsOneWidget);
    await tester.tap(find.byKey(const Key('dashboard-ulp-filter')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard-ulp-option-Batu')), findsOneWidget);
    expect(find.byKey(const Key('dashboard-ulp-option-batu')), findsNothing);
  });

  testWidgets('akun tanpa ULP tetap melihat temuan miliknya', (tester) async {
    final service =
        DashboardFixtureService()
          ..userUlp = ''
          ..findings = [
            finding(
              id: 'own',
              ulp: 'Batu',
              status: 'Open',
              type: 'KMU',
              penyulang: 'Batu',
            ),
          ];
    await pumpDashboard(tester, service);

    expect(find.bySemanticsLabel('Temuan Open: 1'), findsOneWidget);
    expect(find.text('Lokasi own'), findsOneWidget);
    expect(find.textContaining('Temuan saya'), findsOneWidget);
  });

  testWidgets('non-Open findings show an honest empty state', (tester) async {
    final service =
        DashboardFixtureService()
          ..findings = [
            finding(
              id: 'progress',
              ulp: 'Batu',
              status: 'On Progress',
              type: 'KMU',
              penyulang: 'Batu',
            ),
          ];
    await pumpDashboard(tester, service);

    expect(find.bySemanticsLabel('Temuan Open: 0'), findsOneWidget);
    expect(find.text('Tidak ada temuan Open'), findsOneWidget);
    expect(find.text('Lokasi progress'), findsNothing);
  });

  testWidgets('summary fits narrow screen with enlarged text', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = DashboardFixtureService()..isAdmin = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeService.dark(),
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.5),
                disableAnimations: true,
              ),
              child: child!,
            ),
        home: DashboardScreen(temuanService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Temuan Open per ULP'));
    expect(tester.takeException(), isNull);
  });
}
