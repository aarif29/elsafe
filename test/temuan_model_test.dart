import 'package:elsafe/config/temuan_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TemuanModel alamatTemuan', () {
    test('serializes alamat_temuan to JSON', () {
      final temuan = _temuan(alamatTemuan: 'Jl. Raya Tumpang No. 1');

      expect(temuan.toJson()['alamat_temuan'], 'Jl. Raya Tumpang No. 1');
    });

    test('parses alamat_temuan from JSON', () {
      final temuan = TemuanModel.fromJson({
        'id': '1',
        'lokasi': 'Lat: -7.1, Long: 112.1',
        'alamat_temuan': 'Jl. Raya Tumpang No. 1',
        'nama_pemilik': 'Pemilik',
        'tanggal_temuan': '2026-05-06',
        'deskripsi_temuan': 'Deskripsi',
      });

      expect(temuan.alamatTemuan, 'Jl. Raya Tumpang No. 1');
    });

    test('keeps old records without alamat_temuan readable', () {
      final temuan = TemuanModel.fromJson({
        'id': '1',
        'lokasi': 'Lat: -7.1, Long: 112.1',
        'nama_pemilik': 'Pemilik',
        'tanggal_temuan': '2026-05-06',
        'deskripsi_temuan': 'Deskripsi',
      });

      expect(temuan.alamatTemuan, isNull);
    });
  });
}

TemuanModel _temuan({String? alamatTemuan}) {
  return TemuanModel(
    id: '1',
    lokasi: 'Lat: -7.1, Long: 112.1',
    alamatTemuan: alamatTemuan,
    namaPemilik: 'Pemilik',
    tanggalTemuan: DateTime(2026, 5, 6),
    deskripsiTemuan: 'Deskripsi',
  );
}
