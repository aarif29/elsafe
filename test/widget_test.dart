import 'package:elsafe/config/app_theme.dart';
import 'package:elsafe/widgets/panduan_penggunaan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Panduan Penggunaan renders guide content', (tester) async {
    var didTapBack = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeService.light(),
        home: PanduanPenggunaanScreen(
          onBack: () {
            didTapBack = true;
          },
        ),
      ),
    );

    expect(find.text('Panduan Penggunaan'), findsOneWidget);
    expect(find.text('Pendahuluan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();

    expect(didTapBack, isTrue);
  });
}
