const List<String> daftarUlp = [
  'Batu',
  'Dinoyo',
  'Lawang',
  'Singosari',
  'Malang Kota',
  'Blimbing',
  'Kebonagung',
  'Bululawang',
  'Kepanjen',
  'Gondanglegi',
  'Sumberpucung',
  'Dampit',
  'Tumpang',
];

/// Menyamakan data lama seperti "ULP Tumpang" dengan format baru "Tumpang".
String namaUlp(String ulp) {
  return ulp
      .trim()
      .replaceFirst(RegExp(r'^ULP\s+', caseSensitive: false), '')
      .trim();
}

bool ulpSama(String pertama, String kedua) {
  return namaUlp(pertama).toLowerCase() == namaUlp(kedua).toLowerCase();
}

/// Nama konsisten untuk ULP yang terdaftar, termasuk data lama dan beda huruf.
String namaUlpKanonis(String ulp) {
  final nama = namaUlp(ulp);
  for (final terdaftar in daftarUlp) {
    if (terdaftar.toLowerCase() == nama.toLowerCase()) return terdaftar;
  }
  return nama;
}

/// Nilai ULP yang masih mungkin tersimpan pada temuan lama.
List<String> varianUlp(String ulp) {
  final nama = namaUlpKanonis(ulp);
  final huruf = {nama, nama.toLowerCase(), nama.toUpperCase()};
  return {
    ...huruf,
    for (final nilai in huruf) 'ULP $nilai',
    for (final nilai in huruf) 'ulp $nilai',
  }.toList();
}
