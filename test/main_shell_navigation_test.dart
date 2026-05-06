import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Panduan drawer callback opens Panduan inside shell', () {
    final source = File('lib/Screen/main_shell.dart').readAsStringSync();

    expect(source, contains('onOpenPanduan: openPanduan,'));
    expect(source, contains('void openPanduan()'));
    expect(source, contains('PanduanPenggunaanScreen'));
    expect(source, contains('if (_showPanduan) return 4;'));
    expect(source, contains('bottomNavigationBar: _buildBottomNav()'));
  });

  test('Notification drawer callback opens Notifikasi inside shell', () {
    final shellSource = File('lib/Screen/main_shell.dart').readAsStringSync();
    final drawerSource =
        File('lib/widgets/dashboard/dashboard_drawer.dart').readAsStringSync();
    final notificationSource =
        File('lib/Screen/notifications_screen.dart').readAsStringSync();

    expect(shellSource, contains('onOpenNotifications: openNotifications,'));
    expect(shellSource, contains('void openNotifications()'));
    expect(shellSource, contains('NotificationsScreen('));
    expect(notificationSource, contains('final VoidCallback? onBack;'));
    expect(notificationSource, contains('leading:'));
    expect(notificationSource, contains('widget.onBack == null'));
    expect(drawerSource, isNot(contains('const NotificationsScreen()')));
  });

  test('Export PDF can be opened from drawer and dashboard quick action', () {
    final shellSource = File('lib/Screen/main_shell.dart').readAsStringSync();
    final dashboardSource =
        File('lib/Screen/dashboard.dart').readAsStringSync();
    final drawerSource =
        File('lib/widgets/dashboard/dashboard_drawer.dart').readAsStringSync();

    expect(shellSource, contains('void openExport()'));
    expect(shellSource, contains('const ExportTemuanScreen()'));
    expect(shellSource, contains('onOpenExport: openExport,'));
    expect(dashboardSource, contains('final VoidCallback? onOpenExport;'));
    expect(dashboardSource, contains('this.onOpenExport'));
    expect(dashboardSource, contains('widget.onOpenExport'));
    expect(dashboardSource, contains('Icons.picture_as_pdf'));
    expect(dashboardSource, contains('Export PDF'));
    expect(drawerSource, contains('Export Temuan ke PDF'));
  });
}
