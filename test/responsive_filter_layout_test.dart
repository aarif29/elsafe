import 'package:elsafe/widgets/responsive_filter_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpFilters(
  WidgetTester tester,
  Size size, {
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ResponsiveFilterLayout(
                children: [
                  for (var i = 0; i < 5; i++)
                    DropdownButtonFormField<String>(
                      key: ValueKey('filter$i'),
                      value: 'Semua',
                      isExpanded: true,
                      decoration: InputDecoration(labelText: 'Filter $i'),
                      items: const [
                        DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                      ],
                      onChanged: (_) {},
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Five admin filters wrap into two readable columns on a phone', (
    tester,
  ) async {
    await pumpFilters(tester, const Size(375, 812));
    final first = tester.getRect(find.byKey(const ValueKey('filter0')));
    final second = tester.getRect(find.byKey(const ValueKey('filter1')));
    final third = tester.getRect(find.byKey(const ValueKey('filter2')));
    expect(first.width, greaterThanOrEqualTo(160));
    expect(first.top, second.top);
    expect(third.top, greaterThan(first.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Filters fit a single desktop row', (tester) async {
    await pumpFilters(tester, const Size(1200, 900));
    final first = tester.getRect(find.byKey(const ValueKey('filter0')));
    final last = tester.getRect(find.byKey(const ValueKey('filter4')));
    expect(first.top, last.top);
    expect(last.right, lessThanOrEqualTo(1200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Large text uses full-width filters on narrow phones', (
    tester,
  ) async {
    await pumpFilters(tester, const Size(320, 812), scale: 1.5);
    final first = tester.getRect(find.byKey(const ValueKey('filter0')));
    final second = tester.getRect(find.byKey(const ValueKey('filter1')));
    expect(first.left, second.left);
    expect(second.top, greaterThan(first.bottom));
    expect(tester.takeException(), isNull);
  });
}
