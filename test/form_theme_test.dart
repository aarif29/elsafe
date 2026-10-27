import 'package:elsafe/Screen/edit_temuan.dart';
import 'package:elsafe/Screen/daftar_temuan.dart';
import 'package:elsafe/Screen/temuan.dart';
import 'package:elsafe/config/app_theme.dart';
import 'package:elsafe/config/temuan_model.dart';
import 'package:elsafe/widgets/tipe_temuan_picker.dart';
import 'package:elsafe/widgets/daftar_temuan/temuan_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  testWidgets(
    'Finding screen keeps its results area when the search keyboard is open',
    (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeService.light(),
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.5)),
                child: child!,
              ),
          home: const DaftarTemuanScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      final resultViewport = tester.getRect(find.byType(Expanded).first);
      expect(resultViewport.height, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Finding screen remains usable in a short landscape viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(667, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeService.light(),
        home: const DaftarTemuanScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Terjadi Kesalahan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('In-progress detail never describes the finding as finished', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeService.light(),
        home: Scaffold(
          body: TemuanDetailDialog(
            temuan: TemuanModel(
              lokasi: 'Lokasi',
              namaPemilik: 'Pemilik',
              tanggalTemuan: DateTime(2026, 10, 23),
              deskripsiTemuan: 'Deskripsi',
              statusTemuan: 'On Progress',
            ),
            onOpenMaps: (_, __, ___) {},
            onCopyCoordinates: (_, __) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sudah Selesai'), findsNothing);
    expect(find.text('Sedang Ditindaklanjuti'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final editing in [false, true]) {
    testWidgets(
      '${editing ? 'Edit' : 'Create'} form follows the selected theme',
      (tester) async {
        final home =
            editing
                ? EditTemuanScreen(
                  temuan: TemuanModel(
                    lokasi: 'Lokasi uji',
                    namaPemilik: 'Pemilik',
                    tanggalTemuan: DateTime(2026, 10, 23),
                    deskripsiTemuan: 'Deskripsi',
                    tipeTemuan: 'KMU',
                  ),
                )
                : const TemuanScreen(tipeTemuan: 'KMU');
        for (final theme in [ThemeService.light(), ThemeService.dark()]) {
          await tester.pumpWidget(MaterialApp(theme: theme, home: home));
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(Scaffold).first);
          expect(
            tester
                .widget<Scaffold>(find.byType(Scaffold).first)
                .backgroundColor,
            context.bgColor,
          );
          final input = tester.widget<TextField>(find.byType(TextField).first);
          expect(input.style?.color, context.textPrimary);
          expect(input.decoration?.fillColor, context.inputFillColor);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets('Type picker sheet uses the current light surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeService.light(),
        home: const Scaffold(body: TipeTemuanPicker()),
      ),
    );
    final context = tester.element(find.byType(TipeTemuanPicker));
    final title = tester.widget<Text>(find.text('Pilih Jenis Temuan'));
    expect(title.style?.color, context.textPrimary);
    expect(tester.takeException(), isNull);
  });
}
