import 'package:elsafe/config/ulp_list.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('namaUlp removes the legacy ULP prefix for display', () {
    expect(namaUlp('ULP Tumpang'), 'Tumpang');
    expect(namaUlp('tumpang'), 'tumpang');
  });

  test('ulpSama treats legacy and current ULP values as equal', () {
    expect(ulpSama('ULP Tumpang', 'Tumpang'), isTrue);
    expect(ulpSama('Tumpang', 'Batu'), isFalse);
  });
}
