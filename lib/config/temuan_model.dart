class TemuanModel {
  final String? id;
  final String lokasi;
  final String namaPemilik;
  final DateTime tanggalTemuan;
  final String deskripsiTemuan;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TemuanModel({
    this.id,
    required this.lokasi,
    required this.namaPemilik,
    required this.tanggalTemuan,
    required this.deskripsiTemuan,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'lokasi': lokasi,
      'nama_pemilik': namaPemilik,
      'tanggal_temuan': tanggalTemuan.toIso8601String().split('T')[0],
      'deskripsi_temuan': deskripsiTemuan,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory TemuanModel.fromJson(Map<String, dynamic> json) {
    return TemuanModel(
      id: json['id']?.toString(),
      lokasi: json['lokasi'] ?? '',
      namaPemilik: json['nama_pemilik'] ?? '',
      tanggalTemuan: json['tanggal_temuan'] != null 
          ? DateTime.parse(json['tanggal_temuan'])
          : DateTime.now(),
      deskripsiTemuan: json['deskripsi_temuan'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
}
