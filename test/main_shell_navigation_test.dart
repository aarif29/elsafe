import 'package:elsafe/config/app_theme.dart';
import 'package:elsafe/widgets/adaptive_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Desktop sidebar selects the existing destinations', (
    tester,
  ) async {
    resize(tester, const Size(1440, 900));
    var index = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeService.light(),
        home: StatefulBuilder(
          builder:
              (context, setState) => AdaptiveShellScaffold(
                selectedIndex: index,
                onDestinationSelected: (value) => setState(() => index = value),
                body: Text('Isi halaman $index'),
              ),
        ),
      ),
    );
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    await tester.tap(find.text('Peta'));
    await tester.pumpAndSettle();
    expect(find.text('Isi halaman 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Phone bottom navigation keeps the add action above it', (
    tester,
  ) async {
    resize(tester, const Size(375, 812));
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeService.dark(),
        home: AdaptiveShellScaffold(
          selectedIndex: 0,
          onDestinationSelected: (index) => selected = index,
          body: const Text('Isi halaman'),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    await tester.tap(find.text('Profil'));
    expect(selected, 4);
    expect(
      tester.getRect(find.byType(FloatingActionButton)).bottom,
      lessThan(tester.getRect(find.byType(BottomNavigationBar)).top),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Resizing retains screen state and notification count', (
    tester,
  ) async {
    resize(tester, const Size(375, 812));
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveShellScaffold(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          unreadCount: 125,
          body: const _CounterScreen(),
        ),
      ),
    );
    await tester.tap(find.text('Hitungan 0'));
    await tester.pump();
    expect(find.text('Hitungan 1'), findsOneWidget);
    expect(find.text('99+'), findsOneWidget);
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Hitungan 1'), findsOneWidget);
    expect(find.text('99+'), findsOneWidget);
    tester.view.physicalSize = const Size(375, 812);
    await tester.pumpAndSettle();
    expect(find.text('Hitungan 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Drawer remains accessible from the desktop page', (
    tester,
  ) async {
    resize(tester, const Size(1440, 900));
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveShellScaffold(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          drawer: const Drawer(child: Text('Panduan Penggunaan')),
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  child: const Text('Buka menu'),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Buka menu'));
    await tester.pumpAndSettle();
    expect(find.text('Panduan Penggunaan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void resize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _CounterScreen extends StatefulWidget {
  const _CounterScreen();
  @override
  State<_CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<_CounterScreen> {
  int count = 0;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => count++),
    child: Text('Hitungan $count'),
  );
}
