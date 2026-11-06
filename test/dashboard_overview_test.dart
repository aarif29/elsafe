import 'package:elsafe/config/temuan_model.dart';
import 'package:elsafe/widgets/dashboard/dashboard_overview.dart';
import 'package:flutter_test/flutter_test.dart';

TemuanModel finding({
  required String id,
  required String? status,
  required String? type,
  required String? ulp,
  String? penyulang,
  String? risk,
  int day = 1,
}) => TemuanModel(
  id: id,
  lokasi: 'Lokasi $id',
  namaPemilik: 'Pemilik $id',
  tanggalTemuan: DateTime(2026, 10, day),
  deskripsiTemuan: 'Temuan $id',
  statusTemuan: status,
  tipeTemuan: type,
  ulp: ulp,
  namaPenyulang: penyulang,
  levelRisiko: risk,
);

void main() {
  test('status kosong dari database tidak dihitung sebagai Open', () {
    final record = TemuanModel.fromJson({
      'tanggal_temuan': '2026-10-01',
      'lokasi': 'Titik tanpa status',
      'nama_pemilik': 'Contoh',
      'deskripsi_temuan': 'Status belum diisi',
      'status_temuan': null,
    });

    final overview = DashboardOverview.fromFindings([record], groupByUlp: true);
    expect(overview.openCount, 0);
  });

  final findings = [
    finding(
      id: 'extreme',
      status: ' Open ',
      type: 'KMU',
      ulp: 'Batu',
      penyulang: 'Batu',
      risk: 'Extreme',
      day: 8,
    ),
    finding(
      id: 'high',
      status: 'Open',
      type: 'ROW',
      ulp: 'ULP Batu',
      penyulang: 'Batu',
      risk: 'High',
      day: 3,
    ),
    finding(
      id: 'unknown-type',
      status: 'open',
      type: null,
      ulp: 'Batu',
      risk: null,
      day: 2,
    ),
    finding(id: 'progress', status: 'On Progress', type: 'KMU', ulp: 'Batu'),
    finding(id: 'closed', status: 'Close', type: 'ROW', ulp: 'Batu'),
    finding(id: 'unknown-status', status: null, type: 'KMU', ulp: 'Batu'),
    finding(
      id: 'other-ulp',
      status: 'Open',
      type: 'ROW',
      ulp: 'Singosari',
      penyulang: 'Singosari',
    ),
  ];

  test('petugas hanya menghitung Open pada ULP yang setara', () {
    final overview = DashboardOverview.fromFindings(
      findings,
      selectedUlp: 'Batu',
      groupByUlp: false,
    );

    expect(overview.totalCount, 6);
    expect(overview.openCount, 3);
    expect(overview.openKmu, 1);
    expect(overview.openRow, 1);
    expect(overview.openOtherType, 1);
    expect(overview.openByArea, {'Batu': 2, 'Penyulang belum diisi': 1});
    expect(overview.priorityOpen.map((t) => t.id).toList(), [
      'extreme',
      'high',
      'unknown-type',
    ]);
  });

  test('admin semua ULP mengelompokkan Open per ULP', () {
    final overview = DashboardOverview.fromFindings(findings, groupByUlp: true);

    expect(overview.openCount, 4);
    expect(overview.openByArea, {'Batu': 3, 'Singosari': 1});
    expect(overview.priorityOpen.map((t) => t.id), contains('other-ulp'));
  });

  test('admin menyatukan variasi huruf dan awalan ULP', () {
    final overview = DashboardOverview.fromFindings([
      finding(id: 'a', status: 'Open', type: 'KMU', ulp: 'Batu'),
      finding(id: 'b', status: 'Open', type: 'ROW', ulp: 'batu'),
      finding(id: 'c', status: 'Open', type: 'KMU', ulp: 'ULP Batu'),
    ], groupByUlp: true);

    expect(overview.openByArea, {'Batu': 3});
  });

  test('risiko sama mengutamakan tanggal temuan paling lama', () {
    final overview = DashboardOverview.fromFindings([
      finding(
        id: 'newer',
        status: 'Open',
        type: 'KMU',
        ulp: 'Batu',
        risk: 'High',
        day: 20,
      ),
      finding(
        id: 'older',
        status: 'Open',
        type: 'ROW',
        ulp: 'Batu',
        risk: 'High',
        day: 2,
      ),
    ], groupByUlp: true);

    expect(overview.priorityOpen.map((t) => t.id).toList(), ['older', 'newer']);
  });
}
