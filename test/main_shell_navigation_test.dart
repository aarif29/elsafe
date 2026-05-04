import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Panduan drawer callback opens Panduan as a route', () {
    final source = File('lib/Screen/main_shell.dart').readAsStringSync();

    expect(source, contains('onOpenPanduan: openPanduan,'));
    expect(source, contains('Navigator.of(context).push'));
    expect(source, contains('MaterialPageRoute'));
    expect(source, contains('PanduanPenggunaanScreen'));
    expect(source, isNot(contains('_showPanduan')));
  });
}
