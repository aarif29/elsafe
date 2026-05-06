import 'package:elsafe/config/temuan_model.dart';
import 'package:elsafe/utils/export_temuan_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('filterExportTemuan', () {
    // --- Date filters ---

    test('includes findings from the selected end date until end of day', () {
      final results = filterExportTemuan([
        _temuan(id: 'included', tanggalTemuan: DateTime(2026, 5, 5, 15, 30)),
        _temuan(id: 'excluded', tanggalTemuan: DateTime(2026, 5, 6)),
      ], endDate: DateTime(2026, 5, 5));

      expect(results.map((t) => t.id), ['included']);
    });

    test('includes findings on and after startDate (inclusive)', () {
      final results = filterExportTemuan([
        _temuan(id: 'excluded', tanggalTemuan: DateTime(2026, 5, 4, 23, 59)),
        _temuan(id: 'included', tanggalTemuan: DateTime(2026, 5, 5, 0, 0)),
        _temuan(id: 'included-2', tanggalTemuan: DateTime(2026, 5, 6)),
      ], startDate: DateTime(2026, 5, 5));

      expect(results.map((t) => t.id), containsAll(['included', 'included-2']));
      expect(results.map((t) => t.id), isNot(contains('excluded')));
    });

    test('returns empty list when startDate is after endDate', () {
      final results = filterExportTemuan(
        [_temuan(id: 'a', tanggalTemuan: DateTime(2026, 5, 5))],
        startDate: DateTime(2026, 5, 10),
        endDate: DateTime(2026, 5, 1),
      );
      expect(results, isEmpty);
    });

    // --- Status filter ---

    test('filters by Open status only', () {
      final results = filterExportTemuan(
        [
          _temuan(id: 'open', statusTemuan: 'Open'),
          _temuan(id: 'closed', statusTemuan: 'Closed'),
          _temuan(id: 'progress', statusTemuan: 'On Progress'),
        ],
        selectedStatuses: {'Open'},
      );

      expect(results.map((t) => t.id), ['open']);
    });

    test('filters Open findings inside selected date range', () {
      final results = filterExportTemuan(
        [
          _temuan(
            id: 'open-in-range',
            statusTemuan: 'Open',
            tanggalTemuan: DateTime(2026, 5, 5, 10),
          ),
          _temuan(
            id: 'open-out-range',
            statusTemuan: 'Open',
            tanggalTemuan: DateTime(2026, 5, 7),
          ),
          _temuan(
            id: 'closed-in-range',
            statusTemuan: 'Closed',
            tanggalTemuan: DateTime(2026, 5, 5),
          ),
        ],
        startDate: DateTime(2026, 5, 5),
        endDate: DateTime(2026, 5, 5),
        selectedStatuses: {'Open'},
      );

      expect(results.map((t) => t.id), ['open-in-range']);
    });

    test('filters by multiple statuses', () {
      final results = filterExportTemuan(
        [
          _temuan(id: 'open', statusTemuan: 'Open'),
          _temuan(id: 'closed', statusTemuan: 'Closed'),
          _temuan(id: 'progress', statusTemuan: 'On Progress'),
        ],
        selectedStatuses: {'Open', 'Closed'},
      );

      expect(results.map((t) => t.id), containsAll(['open', 'closed']));
      expect(results.map((t) => t.id), isNot(contains('progress')));
    });

    // --- Level Risiko filter ---

    test('filters by single risiko level', () {
      final results = filterExportTemuan(
        [
          _temuan(id: 'tinggi', levelRisiko: 'Tinggi'),
          _temuan(id: 'sedang', levelRisiko: 'Sedang'),
          _temuan(id: 'rendah', levelRisiko: 'Rendah'),
        ],
        selectedRisiko: {'Sedang'},
      );

      expect(results.map((t) => t.id), ['sedang']);
    });

    test('filters by database risk labels', () {
      final results = filterExportTemuan(
        [
          _temuan(id: 'medium', levelRisiko: 'Medium'),
          _temuan(id: 'high', levelRisiko: 'High'),
          _temuan(id: 'extreme', levelRisiko: 'Extreme'),
        ],
        selectedRisiko: {'High'},
      );

      expect(results.map((t) => t.id), ['high']);
    });

    // --- Zona filter ---

    test('filters by selected zonas', () {
      final results = filterExportTemuan(
        [
          _temuan(id: 'zona1', zona: 1),
          _temuan(id: 'zona2', zona: 2),
          _temuan(id: 'zona3', zona: 3),
        ],
        selectedZonas: {1, 3},
      );

      expect(results.map((t) => t.id), containsAll(['zona1', 'zona3']));
      expect(results.map((t) => t.id), isNot(contains('zona2')));
    });

    // --- Section filter ---

    test('filters by selected sections', () {
      final results = filterExportTemuan(
        [
          _temuan(id: 'sec1', section: 1),
          _temuan(id: 'sec5', section: 5),
          _temuan(id: 'sec10', section: 10),
        ],
        selectedSections: {5, 10},
      );

      expect(results.map((t) => t.id), containsAll(['sec5', 'sec10']));
      expect(results.map((t) => t.id), isNot(contains('sec1')));
    });

    // --- ULP filter ---

    test('filters by selected ULPs', () {
      final results = filterExportTemuan(
        [
          _temuan(id: 'ulp-a', ulp: 'ULP A'),
          _temuan(id: 'ulp-b', ulp: 'ULP B'),
        ],
        selectedUlps: {'ULP B'},
      );

      expect(results.map((t) => t.id), ['ulp-b']);
    });

    // --- Penyulang filter ---

    test('filters by penyulang (exact match)', () {
      final results = filterExportTemuan([
        _temuan(id: 'a', namaPenyulang: 'Penyulang A'),
        _temuan(id: 'b', namaPenyulang: 'Penyulang B'),
        _temuan(id: 'c', namaPenyulang: null),
      ], selectedPenyulang: 'Penyulang A');

      expect(results.map((t) => t.id), ['a']);
    });

    // --- Null rejection ---

    test('rejects null values when the related filter is active', () {
      final results = filterExportTemuan(
        [
          _temuan(id: 'match'),
          _temuan(id: 'null-status', statusTemuan: null),
          _temuan(id: 'null-risiko', levelRisiko: null),
          _temuan(id: 'null-zona', zona: null),
          _temuan(id: 'null-section', section: null),
          _temuan(id: 'null-ulp', ulp: null),
          _temuan(id: 'null-penyulang', namaPenyulang: null),
        ],
        selectedStatuses: {'Open'},
        selectedRisiko: {'Tinggi'},
        selectedZonas: {1},
        selectedSections: {1},
        selectedUlps: {'ULP A'},
        selectedPenyulang: 'Penyulang A',
      );

      expect(results.map((t) => t.id), ['match']);
    });

    test('rejects null zona independently when zona filter is active', () {
      final results = filterExportTemuan(
        [
          _temuan(id: 'has-zona', zona: 1),
          _temuan(id: 'null-zona', zona: null),
        ],
        selectedZonas: {1},
      );

      expect(results.map((t) => t.id), ['has-zona']);
    });

    test(
      'rejects null section independently when section filter is active',
      () {
        final results = filterExportTemuan(
          [
            _temuan(id: 'has-section', section: 5),
            _temuan(id: 'null-section', section: null),
          ],
          selectedSections: {5},
        );

        expect(results.map((t) => t.id), ['has-section']);
      },
    );

    // --- Empty filter = all pass ---

    test('returns all findings when all filters are empty sets', () {
      final all = [
        _temuan(id: 'a', statusTemuan: 'Open'),
        _temuan(id: 'b', statusTemuan: 'Closed'),
        _temuan(id: 'c', levelRisiko: 'Rendah'),
      ];
      final results = filterExportTemuan(
        all,
        selectedStatuses: const {},
        selectedRisiko: const {},
        selectedZonas: const {},
        selectedSections: const {},
        selectedUlps: const {},
      );

      expect(results.length, 3);
    });
  });
}

TemuanModel _temuan({
  required String id,
  DateTime? tanggalTemuan,
  String? statusTemuan = 'Open',
  String? levelRisiko = 'Tinggi',
  int? zona = 1,
  int? section = 1,
  String? ulp = 'ULP A',
  String? namaPenyulang = 'Penyulang A',
}) {
  return TemuanModel(
    id: id,
    lokasi: 'Lokasi $id',
    namaPemilik: 'Pemilik $id',
    tanggalTemuan: tanggalTemuan ?? DateTime(2026, 5, 5),
    deskripsiTemuan: 'Deskripsi $id',
    statusTemuan: statusTemuan,
    levelRisiko: levelRisiko,
    zona: zona,
    section: section,
    ulp: ulp,
    namaPenyulang: namaPenyulang,
  );
}
