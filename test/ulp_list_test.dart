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

  test('namaUlpKanonis uses the known ULP spelling', () {
    expect(namaUlpKanonis('ulp batu'), 'Batu');
    expect(namaUlpKanonis('BATU'), 'Batu');
  });

  test('varianUlp includes current and legacy database values', () {
    expect(
      varianUlp('ulp batu'),
      containsAll(['Batu', 'ULP Batu', 'batu', 'ulp batu']),
    );
    expect(varianUlp('Batu').toSet().length, varianUlp('Batu').length);
  });
}
