import 'dart:typed_data';

import 'package:elsafe/config/temuan_model.dart';
import 'package:elsafe/utils/excel_generator.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportTemuanExcelGenerator', () {
    test('generates decodable XLSX bytes with the expected sheets', () async {
      final bytes = await ExportTemuanExcelGenerator.generate(
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

    test('styles title, table headers, and risk status cells', () async {
      final bytes = await ExportTemuanExcelGenerator.generate(
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

    test('writes professional summary KPI cards', () async {
      final bytes = await ExportTemuanExcelGenerator.generate(
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

    test('embeds first photo thumbnail from each photo column', () async {
      final loadedUrls = <String>[];

      final bytes = await ExportTemuanExcelGenerator.generate(
        temuan: [
          _sampleTemuan(
            fotoUrls: [
              'https://example.com/temuan-1.png',
              'https://example.com/temuan-2.png',
            ],
            fotoReminder: ['https://example.com/reminder-1.png'],
            fotoClosing: [
              'https://example.com/closing-1.png',
              'https://example.com/closing-2.png',
            ],
          ),
        ],
        generatedAt: DateTime(2026, 5, 6, 10, 30),
        networkImageLoader: (url) async {
          loadedUrls.add(url);
          return Uint8List.fromList(_pngBytes);
        },
      );

      expect(loadedUrls, [
        'https://example.com/temuan-1.png',
        'https://example.com/reminder-1.png',
        'https://example.com/closing-1.png',
      ]);
      expect(_containsXlsxEntry(bytes, 'xl/media/'), isTrue);

      final workbook = Excel.decodeBytes(bytes);
      final sheet = workbook['Temuan'];
      expect(
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: 6))
            .value
            .toString(),
        '(+1 lagi)',
      );
      expect(
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: 6))
            .value
            .toString(),
        '',
      );
      expect(
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: 6))
            .value
            .toString(),
        '(+1 lagi)',
      );
    });

    test('falls back to textual photo URL when image download fails', () async {
      final bytes = await ExportTemuanExcelGenerator.generate(
        temuan: [
          _sampleTemuan(
            fotoUrls: ['https://example.com/temuan-1.png'],
            fotoReminder: [],
            fotoClosing: null,
          ),
        ],
        generatedAt: DateTime(2026, 5, 6, 10, 30),
        networkImageLoader: (_) async => null,
      );

      expect(_containsXlsxEntry(bytes, 'xl/media/'), isFalse);

      final workbook = Excel.decodeBytes(bytes);
      final sheet = workbook['Temuan'];
      expect(
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: 6))
            .value
            .toString(),
        'https://example.com/temuan-1.png',
      );
      expect(
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 16, rowIndex: 6))
            .value
            .toString(),
        '-',
      );
      expect(
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 17, rowIndex: 6))
            .value
            .toString(),
        '-',
      );
    });
  });
}

TemuanModel _sampleTemuan({
  String id = '1',
  String status = 'Open',
  String risiko = 'High',
  List<String>? fotoUrls,
  List<String>? fotoReminder,
  List<String>? fotoClosing,
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
    fotoUrls: fotoUrls,
    fotoReminder: fotoReminder,
    fotoClosing: fotoClosing,
  );
}

String _argb(String rgb) => 'FF$rgb';

bool _containsXlsxEntry(List<int> bytes, String entryName) {
  return String.fromCharCodes(bytes).contains(entryName);
}

const _pngBytes = [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];
