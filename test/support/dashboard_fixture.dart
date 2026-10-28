import 'dart:async';
import 'package:elsafe/config/temuan_model.dart';
import 'package:elsafe/config/temuan_service.dart';

/// Local example data only. This service never connects to Supabase.
List<TemuanModel> dashboardExampleFindings() {
  final now = DateTime.now();
  return [
    TemuanModel(
      id: 'example-1',
      namaPemilik: 'Contoh — Bangunan dekat jaringan',
      lokasi: 'Jl. Melati, wilayah ULP',
      tanggalTemuan: DateTime(now.year, now.month, 1),
      deskripsiTemuan: 'Data contoh untuk pemeriksaan tampilan.',
      statusTemuan: 'Open',
      tipeTemuan: 'KMU',
      levelRisiko: 'Extreme',
    ),
    TemuanModel(
      id: 'example-2',
      namaPemilik: 'Contoh — Pohon di jalur jaringan',
      lokasi: 'Jl. Kenanga, wilayah ULP',
      tanggalTemuan: DateTime(now.year, now.month, 1),
      deskripsiTemuan: 'Data contoh untuk pemeriksaan tampilan.',
      statusTemuan: 'On Progress',
      tipeTemuan: 'ROW',
      levelRisiko: 'High',
    ),
    TemuanModel(
      id: 'example-3',
      namaPemilik: 'Contoh — Aktivitas sekitar tiang',
      lokasi: 'Jl. Anggrek, wilayah ULP',
      tanggalTemuan: DateTime(now.year, now.month - 1, 1),
      deskripsiTemuan: 'Data contoh untuk pemeriksaan tampilan.',
      statusTemuan: 'Close',
      tipeTemuan: 'KMU',
      levelRisiko: 'Medium',
    ),
    TemuanModel(
      id: 'example-4',
      namaPemilik: 'Contoh — Temuan keempat',
      lokasi: 'Jl. Mawar, wilayah ULP',
      tanggalTemuan: DateTime(now.year, now.month, 1),
      deskripsiTemuan: 'Data contoh untuk pemeriksaan tampilan.',
    ),
  ];
}

class DashboardFixtureService implements TemuanService {
  List<TemuanModel> findings = dashboardExampleFindings();
  bool fail = false;
  bool throwError = false;
  bool isAdmin = false;
  Completer<Map<String, dynamic>>? pending;

  @override
  String? get currentUserEmail => 'preview@example.invalid';

  @override
  Future<Map<String, dynamic>?> getCurrentUserProfile() async => {
    'full_name': 'Petugas Contoh',
    'nip': null,
  };

  @override
  Future<Map<String, dynamic>> getAllTemuanSilent() async {
    if (pending != null) return pending!.future;
    if (throwError) throw StateError('Example load failure');
    return {
      'success': !fail,
      'message': fail ? 'Example load failure' : 'Data berhasil dimuat',
      'data': fail ? <TemuanModel>[] : findings,
      'isAdmin': isAdmin,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
