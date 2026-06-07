import 'package:elsafe/config/temuan_model.dart';
import 'package:elsafe/utils/excel_generator.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportTemuanExcelGenerator', () {
    test('generates decodable XLSX bytes with the expected sheets', () {
      final bytes = ExportTemuanExcelGenerator.generate(
        temuan: [_sampleTemuan()],
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

    test('styles title, table headers, and risk status cells', () {
      final bytes = ExportTemuanExcelGenerator.generate(
        temuan: [
          _sampleTemuan(status: 'Open', risiko: 'High'),
          _sampleTemuan(id: '2', status: 'Closed', risiko: 'Extreme'),
        ],
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        ulpLabel: 'ULP A',
        generatedAt: DateTime(2026, 5, 6, 10, 30),
      );

      final workbook = Excel.decodeBytes(bytes);
      final sheet = workbook['Temuan'];

      final titleStyle = sheet.cell(CellIndex.indexByString('A1')).cellStyle;
      expect(titleStyle?.isBold, isTrue);
      expect(titleStyle?.fontSize, greaterThanOrEqualTo(14));
      expect(titleStyle?.backgroundColor.colorHex, _argb('0B5CAB'));
      expect(titleStyle?.fontColor.colorHex, _argb('FFFFFF'));

      final headerStyle = sheet.cell(CellIndex.indexByString('A6')).cellStyle;
      expect(headerStyle?.isBold, isTrue);
      expect(headerStyle?.backgroundColor.colorHex, _argb('0B5CAB'));
      expect(headerStyle?.fontColor.colorHex, _argb('FFFFFF'));

      expect(
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: 6))
            .cellStyle
            ?.backgroundColor
            .colorHex,
        _argb('F97316'),
      );
      expect(
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 6))
            .cellStyle
            ?.backgroundColor
            .colorHex,
        _argb('FEF3C7'),
      );
      expect(
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: 7))
            .cellStyle
            ?.backgroundColor
            .colorHex,
        _argb('DC2626'),
      );
      expect(
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 7))
            .cellStyle
            ?.backgroundColor
            .colorHex,
        _argb('DCFCE7'),
      );
    });

    test('writes professional summary KPI cards', () {
      final bytes = ExportTemuanExcelGenerator.generate(
        temuan: [
          _sampleTemuan(status: 'Open', risiko: 'High'),
          _sampleTemuan(id: '2', status: 'Closed', risiko: 'Extreme'),
        ],
        generatedAt: DateTime(2026, 5, 6, 10, 30),
      );

      final workbook = Excel.decodeBytes(bytes);
      final sheet = workbook['Ringkasan'];

      expect(
        sheet.cell(CellIndex.indexByString('A6')).value.toString(),
        'TOTAL',
      );
      expect(
        sheet.cell(CellIndex.indexByString('C6')).value.toString(),
        'OPEN',
      );
      expect(
        sheet.cell(CellIndex.indexByString('E6')).value.toString(),
        'CLOSED',
      );
      expect(
        sheet.cell(CellIndex.indexByString('G6')).value.toString(),
        'EXTREME/HIGH',
      );

      expect(sheet.cell(CellIndex.indexByString('A7')).value.toString(), '2');
      expect(sheet.cell(CellIndex.indexByString('C7')).value.toString(), '1');
      expect(sheet.cell(CellIndex.indexByString('E7')).value.toString(), '1');
      expect(sheet.cell(CellIndex.indexByString('G7')).value.toString(), '2');

      final kpiStyle = sheet.cell(CellIndex.indexByString('A6')).cellStyle;
      expect(kpiStyle?.isBold, isTrue);
      expect(kpiStyle?.backgroundColor.colorHex, _argb('0B5CAB'));
      expect(kpiStyle?.fontColor.colorHex, _argb('FFFFFF'));
    });
  });
}

TemuanModel _sampleTemuan({
  String id = '1',
  String status = 'Open',
  String risiko = 'High',
}) {
  return TemuanModel(
    id: id,
    lokasi: 'Gardu Induk A',
    alamatTemuan: 'Jl. Raya Tumpang No. 1',
    namaPemilik: 'PLN',
    tanggalTemuan: DateTime(2026, 5, 5),
    statusTemuan: status,
    tipeTemuan: 'ROW',
    levelRisiko: risiko,
    ulp: 'ULP A',
    latitude: -7.974328,
    longitude: 112.629752,
    deskripsiTemuan: 'ROW terlalu dekat',
  );
}

String _argb(String rgb) => 'FF$rgb';
