class TipeTemuan {
  static const String kmu = 'KMU';
  static const String row = 'ROW';

  static String label(String? tipe) {
    switch (tipe) {
      case kmu:
        return 'Potensi Bahaya KMU';
      case row:
        return 'Potensi Bahaya ROW';
      default:
        return 'Temuan';
    }
  }
}

class MatriksRisiko {
  // Pilihan dropdown
  static const List<Map<String, dynamic>> jarakAktivitas = [
    {'label': '< 1 meter', 'value': '< 1 meter', 'skor': 3},
    {'label': '< 2 meter', 'value': '< 2 meter', 'skor': 2},
    {'label': '< 3 meter', 'value': '< 3 meter', 'skor': 1},
  ];

  static const List<Map<String, dynamic>> intensitasAktivitas = [
    {'label': 'Sering', 'value': 'Sering', 'skor': 3},
    {'label': 'Jarang', 'value': 'Jarang', 'skor': 1},
  ];

  static const List<Map<String, dynamic>> jenisObjek = [
    {'label': 'Bangunan baru', 'value': 'Bangunan baru', 'skor': 3},
    {'label': 'Bangunan lama', 'value': 'Bangunan lama', 'skor': 3},
    {'label': 'Baliho / umbul-umbul', 'value': 'Baliho / umbul-umbul', 'skor': 3},
    {'label': 'Pohon', 'value': 'Pohon', 'skor': 1},
    {'label': 'Rawan layang-layang', 'value': 'Rawan layang-layang', 'skor': 2},
  ];

  static const List<Map<String, dynamic>> jenisAset = [
    {'label': 'SUTM', 'value': 'SUTM', 'skor': 3},
    {'label': 'Trafo', 'value': 'Trafo', 'skor': 2},
    {'label': 'MVTIC', 'value': 'MVTIC', 'skor': 1},
  ];

  static const List<Map<String, dynamic>> lokasiObjek = [
    {'label': 'Samping jaringan', 'value': 'Samping jaringan', 'skor': 3},
    {'label': 'Atas jaringan', 'value': 'Atas jaringan', 'skor': 2},
    {'label': 'Bawah jaringan', 'value': 'Bawah jaringan', 'skor': 2},
  ];

  static int skorDariNilai(List<Map<String, dynamic>> options, String? value) {
    if (value == null) return 0;
    final match = options.firstWhere(
      (o) => o['value'] == value,
      orElse: () => {'skor': 0},
    );
    return match['skor'] as int;
  }

  static int hitungSkor({
    required String? jarak,
    required String? intensitas,
    required String? objek,
    required String? aset,
    required String? lokasi,
  }) {
    return skorDariNilai(jarakAktivitas, jarak) +
        skorDariNilai(intensitasAktivitas, intensitas) +
        skorDariNilai(jenisObjek, objek) +
        skorDariNilai(jenisAset, aset) +
        skorDariNilai(lokasiObjek, lokasi);
  }

  static String? levelDariSkor(int skor) {
    if (skor == 0) return null;
    if (skor <= 8) return 'Medium';
    if (skor <= 11) return 'High';
    return 'Extreme';
  }
}
