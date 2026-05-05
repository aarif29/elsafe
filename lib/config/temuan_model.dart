class TemuanModel {
  final String? id;
  final String lokasi;
  final String namaPemilik;
  final DateTime tanggalTemuan;
  final String deskripsiTemuan;
  final double? latitude;
  final double? longitude;
  final List<String>? fotoUrls;
  final String? nomorAms;
  final String? statusTemuan;
  final String? tipeTemuan;
  final String? createdBy;
  final DateTime? createdAt;

  // Matriks risiko
  final String? jarakAktivitas;
  final String? intensitasAktivitas;
  final String? jenisObjek;
  final String? jenisAset;
  final String? lokasiObjek;
  final int? skorMatriks;
  final String? levelRisiko;

  // Reminder
  final DateTime? tglReminder;
  final List<String>? fotoReminder;

  // Closing
  final String? jenisClosing;
  final DateTime? tglClosing;
  final List<String>? fotoClosing;

  // ULP
  final String? ulp;

  // Jaringan listrik
  final String? namaPenyulang;
  final int? section;
  final int? zona;

  TemuanModel({
    this.id,
    required this.lokasi,
    required this.namaPemilik,
    required this.tanggalTemuan,
    required this.deskripsiTemuan,
    this.latitude,
    this.longitude,
    this.fotoUrls,
    this.nomorAms,
    this.statusTemuan,
    this.tipeTemuan,
    this.createdBy,
    this.createdAt,
    this.jarakAktivitas,
    this.intensitasAktivitas,
    this.jenisObjek,
    this.jenisAset,
    this.lokasiObjek,
    this.skorMatriks,
    this.levelRisiko,
    this.tglReminder,
    this.fotoReminder,
    this.jenisClosing,
    this.tglClosing,
    this.fotoClosing,
    this.ulp,
    this.namaPenyulang,
    this.section,
    this.zona,
  });

  Map<String, dynamic> toJson() {
    return {
      'lokasi': lokasi,
      'nama_pemilik': namaPemilik,
      'tanggal_temuan': tanggalTemuan.toIso8601String(),
      'deskripsi_temuan': deskripsiTemuan,
      'latitude': latitude,
      'longitude': longitude,
      'foto_urls': fotoUrls,
      'nomor_ams': nomorAms,
      'status_temuan': statusTemuan,
      'tipe_temuan': tipeTemuan,
      'jarak_aktivitas': jarakAktivitas,
      'intensitas_aktivitas': intensitasAktivitas,
      'jenis_objek': jenisObjek,
      'jenis_aset': jenisAset,
      'lokasi_objek': lokasiObjek,
      'skor_matriks': skorMatriks,
      'level_risiko': levelRisiko,
      'tgl_reminder': tglReminder?.toIso8601String(),
      'foto_reminder': fotoReminder,
      'jenis_closing': jenisClosing,
      'tgl_closing': tglClosing?.toIso8601String(),
      'foto_closing': fotoClosing,
      'ulp': ulp,
      'nama_penyulang': namaPenyulang,
      'section': section,
      'zona': zona,
    };
  }

  factory TemuanModel.fromJson(Map<String, dynamic> json) {
    return TemuanModel(
      id: json['id']?.toString(),
      lokasi: json['lokasi'] ?? '',
      namaPemilik: json['nama_pemilik'] ?? '',
      tanggalTemuan: DateTime.parse(json['tanggal_temuan']),
      deskripsiTemuan: json['deskripsi_temuan'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      fotoUrls: json['foto_urls'] != null
          ? List<String>.from(json['foto_urls'])
          : null,
      nomorAms: json['nomor_ams']?.toString(),
      statusTemuan: json['status_temuan']?.toString() ?? 'Open',
      tipeTemuan: json['tipe_temuan']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      jarakAktivitas: json['jarak_aktivitas']?.toString(),
      intensitasAktivitas: json['intensitas_aktivitas']?.toString(),
      jenisObjek: json['jenis_objek']?.toString(),
      jenisAset: json['jenis_aset']?.toString(),
      lokasiObjek: json['lokasi_objek']?.toString(),
      skorMatriks: json['skor_matriks'] as int?,
      levelRisiko: json['level_risiko']?.toString(),
      tglReminder: json['tgl_reminder'] != null
          ? DateTime.parse(json['tgl_reminder'])
          : null,
      fotoReminder: json['foto_reminder'] != null
          ? List<String>.from(json['foto_reminder'])
          : null,
      jenisClosing: json['jenis_closing']?.toString(),
      tglClosing: json['tgl_closing'] != null
          ? DateTime.parse(json['tgl_closing'])
          : null,
      fotoClosing: json['foto_closing'] != null
          ? List<String>.from(json['foto_closing'])
          : null,
      ulp: json['ulp']?.toString(),
      namaPenyulang: json['nama_penyulang']?.toString(),
      section: json['section'] as int?,
      zona: json['zona'] as int?,
    );
  }
}
