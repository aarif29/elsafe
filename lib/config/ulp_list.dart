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
