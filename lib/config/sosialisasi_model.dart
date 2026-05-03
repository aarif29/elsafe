class SosialisasiModel {
  final String? id;
  final String temuanId;
  final DateTime tglSosialisasi;
  final List<String>? fotoUrls;
  final DateTime? createdAt;
  final String? createdBy;

  SosialisasiModel({
    this.id,
    required this.temuanId,
    required this.tglSosialisasi,
    this.fotoUrls,
    this.createdAt,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'temuan_id': temuanId,
      'tgl_sosialisasi': tglSosialisasi.toIso8601String(),
      'foto_urls': fotoUrls,
      'created_by': createdBy,
    };
  }

  factory SosialisasiModel.fromJson(Map<String, dynamic> json) {
    return SosialisasiModel(
      id: json['id']?.toString(),
      temuanId: json['temuan_id']?.toString() ?? '',
      tglSosialisasi: DateTime.parse(json['tgl_sosialisasi']),
      fotoUrls: json['foto_urls'] != null
          ? List<String>.from(json['foto_urls'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      createdBy: json['created_by']?.toString(),
    );
  }
}
