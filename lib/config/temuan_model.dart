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
  final String? createdBy;
  final DateTime? createdAt;

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
    this.createdBy,
    this.createdAt,
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
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
