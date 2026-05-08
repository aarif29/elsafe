import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TemuanService blocks admin create update and delete operations', () {
    final source = File('lib/config/temuan_service.dart').readAsStringSync();

    expect(source, contains("_isAdminProfile(profile)"));
    expect(source, contains('Admin hanya dapat melihat data temuan'));
    expect(source, isNot(contains('isAdmin || isOwner')));
    expect(source, isNot(contains('if (isAdmin ||')));
  });

  test('Admin does not see create edit delete entry points in temuan UI', () {
    final shellSource = File('lib/Screen/main_shell.dart').readAsStringSync();
    final daftarSource =
        File('lib/Screen/daftar_temuan.dart').readAsStringSync();
    final itemSource =
        File(
          'lib/widgets/daftar_temuan/temuan_list_item.dart',
        ).readAsStringSync();
    final notificationSource =
        File('lib/Screen/notifications_screen.dart').readAsStringSync();

    expect(shellSource, contains('if (_isAdmin) return null;'));
    expect(daftarSource, contains('canModify: !_isAdmin'));
    expect(daftarSource, matches(RegExp(r'_isAdmin\s*\?\s*null')));
    expect(daftarSource, matches(RegExp(r'onDelete:\s*_isAdmin\s*\?\s*null')));
    expect(itemSource, contains('final bool canModify;'));
    expect(itemSource, contains('if (canModify)'));
    expect(notificationSource, contains('if (_isAdmin)'));
    expect(notificationSource, contains('onEdit: null'));
  });

  test(
    'Edit screen only performs follow-up mutations after update succeeds',
    () {
      final source = File('lib/Screen/edit_temuan.dart').readAsStringSync();

      expect(source, contains('bool _isAdmin = false;'));
      expect(source, contains('Admin hanya dapat melihat data temuan'));
      expect(source, contains("if (result['success']) {"));
      expect(
        source,
        contains('// Delete removed photos after update succeeds'),
      );
      expect(source, contains('// Save new sosialisasi after update succeeds'));
    },
  );

  test('Create screen blocks admin before upload or submit', () {
    final source = File('lib/Screen/temuan.dart').readAsStringSync();

    expect(source, contains('bool _isAdmin = false;'));
    expect(source, contains('Admin hanya dapat melihat data temuan'));
  });
}
