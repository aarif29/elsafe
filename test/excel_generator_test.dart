import 'package:elsafe/config/temuan_model.dart';
import 'package:elsafe/utils/excel_generator.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportTemuanExcelGenerator', () {
    test('generates decodable XLSX bytes with the expected sheets', () {
      final bytes = ExportTemuanExcelGenerator.generate(
        temuan: [
          TemuanModel(
            id: '1',
            lokasi: 'Gardu Induk A',
            alamatTemuan: 'Jl. Raya Tumpang No. 1',
            namaPemilik: 'PLN',
            tanggalTemuan: DateTime(2026, 5, 5),
            statusTemuan: 'Open',
            tipeTemuan: 'ROW',
            levelRisiko: 'High',
            ulp: 'ULP A',
            latitude: -7.974328,
            longitude: 112.629752,
            deskripsiTemuan: 'ROW terlalu dekat',
          ),
        ],
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        ulpLabel: 'ULP A',
        generatedAt: DateTime(2026, 5, 6, 10, 30),
      );

      expect(bytes.length, greaterThan(1000));

      final workbook = Excel.decodeBytes(bytes);
      expect(workbook.tables.keys, contains('Temuan'));
      expect(workbook.tables.keys, contains('Ringkasan'));
    });
  });
}
