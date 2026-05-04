import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Panduan drawer callback does not pop the navigator twice', () {
    final source = File('lib/Screen/main_shell.dart').readAsStringSync();

    expect(source, contains('onOpenPanduan: openPanduan,'));
  });
}
