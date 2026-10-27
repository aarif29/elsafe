import 'package:elsafe/config/app_theme.dart';
import 'package:elsafe/config/temuan_model.dart';
import 'package:elsafe/profil/loginscreen.dart';
import 'package:elsafe/widgets/daftar_temuan/temuan_list_item.dart';
import 'package:elsafe/widgets/dashboard/dashboard_recent_activity.dart';
import 'package:elsafe/widgets/dashboard/dashboard_stats_section.dart';
import 'package:elsafe/widgets/dashboard/dashboard_welcome_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TemuanModel finding({String? status = 'Open'}) => TemuanModel(
  lokasi: 'Jalan Panjang di wilayah pelayanan Malang',
  namaPemilik: 'Nama pemilik yang cukup panjang untuk layar ponsel',
  tanggalTemuan: DateTime(2026, 10, 23),
  deskripsiTemuan: 'Kabel berada dekat bangunan dan perlu ditindaklanjuti.',
  statusTemuan: status,
  tipeTemuan: 'KMU',
  levelRisiko: 'Extreme',
);

Future<void> pumpCard(
  WidgetTester tester,
  String? status, {
  double scale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeService.light(),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: TemuanListItem(
              temuan: finding(status: status),
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('In-progress finding is not presented as closed', (tester) async {
    await pumpCard(tester, 'On Progress');
    expect(find.text('On Progress'), findsOneWidget);
    expect(find.text('Closed'), findsNothing);
  });

  for (final status in <String?>[null, 'Menunggu Verifikasi']) {
    testWidgets('Unknown status $status is not presented as closed', (
      tester,
    ) async {
      await pumpCard(tester, status);
      expect(find.text('Closed'), findsNothing);
      expect(find.text(status ?? 'Status belum tersedia'), findsOneWidget);
    });
  }

  testWidgets('Legacy Close finding still presents as Closed', (tester) async {
    await pumpCard(tester, 'Close');
    expect(find.text('Closed'), findsOneWidget);
  });

  testWidgets('Finding remains readable on narrow screens with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpCard(tester, 'On Progress', scale: 1.5);
    expect(tester.takeException(), isNull);
    final description = tester.getRect(find.text(finding().deskripsiTemuan));
    final status = tester.getRect(find.text('On Progress'));
    expect(description.top, greaterThanOrEqualTo(status.bottom));
  });

  testWidgets('Desktop Google login stays bounded and centered', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: const LoginPage()));
    final primary = tester.getRect(find.byType(ElevatedButton));
    expect(primary.width, lessThanOrEqualTo(440));
    expect(primary.center.dx, closeTo(720, 1));
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.text('Lupa Password?'), findsNothing);
    expect(find.text('Daftar Sekarang!'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Google login fits a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
        home: const LoginPage(),
      ),
    );
    await tester.ensureVisible(find.byType(ElevatedButton));
    expect(find.text('Masuk dengan Google').hitTestable(), findsOneWidget);
    expect(
      tester.getSize(find.byType(ElevatedButton)).height,
      greaterThanOrEqualTo(56),
    );
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'Dashboard summary fits narrow large-text layout (dark: $dark)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var openedList = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? ThemeService.dark() : ThemeService.light(),
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.5)),
                  child: child!,
                ),
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const DashboardWelcomeCard(
                      userName:
                          'Nama Pengguna dengan Nama Lengkap Sangat Panjang',
                    ),
                    const DashboardStatsSection(
                      totalTemuan: 12345,
                      temuanBulanIni: 678,
                    ),
                    DashboardRecentActivity(
                      recentTemuan: [finding()],
                      onLihatSemua: () => openedList = true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(find.text('12345'), findsOneWidget);
        expect(find.text('678'), findsOneWidget);
        await tester.ensureVisible(find.text('Lihat Semua'));
        await tester.tap(find.text('Lihat Semua'));
        expect(openedList, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
