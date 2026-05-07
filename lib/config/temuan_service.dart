import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_logger.dart';
import 'temuan_model.dart';
import 'sosialisasi_model.dart';
import 'ulp_service.dart';

class TemuanService {
  final _supabase = Supabase.instance.client;
  final _ulpService = UlpService();

  String? get currentUserId {
    final user = _supabase.auth.currentUser;
    return user?.id;
  }

  String? get currentUserEmail {
    final user = _supabase.auth.currentUser;
    return user?.email;
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      if (currentUserId == null) return null;

      final response = await _supabase
          .from('profiles')
          .select('full_name, nip')
          .eq('id', currentUserId!)
          .single();

      return response;
    } catch (e) {
      appLog.e('❌ Error get user profile', error: e);
      return null;
    }
  }

  String get currentUserDisplayName {
    return 'Loading...';
  }

  // ========== UPLOAD FOTO (SUPPORT WEB & MOBILE) ==========
  Future<Map<String, dynamic>> uploadFoto(dynamic file) async {
    try {
      String fileName;
      String filePath;

      if (file is PlatformFile) {
        // ✅ Handle PlatformFile dari file_picker
        fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        filePath = 'temuan_photos/$fileName';

        appLog.d('📤 Uploading foto: ${file.name}');
        appLog.d('📝 File path: $filePath');

        if (kIsWeb) {
          // ===== WEB: Gunakan bytes =====
          if (file.bytes == null) {
            throw Exception('File bytes is null for web');
          }

          appLog.d('📦 File size (WEB): ${file.bytes!.length} bytes');

          final String uploadedPath = await _supabase.storage
              .from('foto-temuan')
              .uploadBinary(
                filePath,
                file.bytes!,
                fileOptions: FileOptions(
                  contentType: _getContentType(file.name),
                  cacheControl: '3600',
                  upsert: false,
                ),
              );

          appLog.d('✅ Upload berhasil (WEB): $uploadedPath');
        } else {
          // ===== MOBILE: Gunakan path =====
          if (file.path == null) {
            throw Exception('File path is null for mobile');
          }

          appLog.d('📦 File path (MOBILE): ${file.path}');

          final fileToUpload = File(file.path!);

          final String uploadedPath = await _supabase.storage
              .from('foto-temuan')
              .upload(
                filePath,
                fileToUpload,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: false,
                ),
              );

          appLog.d('✅ Upload berhasil (MOBILE): $uploadedPath');
        }
      } else if (file is File && !kIsWeb) {
        // ===== Fallback untuk File langsung (mobile only) =====
        fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        filePath = 'temuan_photos/$fileName';

        appLog.d('📤 Uploading foto (File): ${file.path}');

        final String uploadedPath = await _supabase.storage
            .from('foto-temuan')
            .upload(
              filePath,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        appLog.d('✅ Upload berhasil: $uploadedPath');
      } else {
        throw Exception('Unsupported file type. Expected PlatformFile or File.');
      }

      // Get public URL
      final String publicUrl = _supabase.storage
          .from('foto-temuan')
          .getPublicUrl(filePath);

      appLog.d('🔗 Public URL: $publicUrl');

      return {
        'success': true,
        'url': publicUrl,
        'path': filePath,
        'message': 'Foto berhasil diupload',
      };
    } catch (e) {
      appLog.e('❌ Error upload foto', error: e);
      return {
        'success': false,
        'message': 'Gagal upload foto: ${e.toString()}',
      };
    }
  }

  // Helper method untuk menentukan content type
  String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // ========== DELETE FOTO ==========
  Future<Map<String, dynamic>> deleteFoto(String url) async {
    try {
      appLog.d('🗑️ Deleting foto: $url');

      // Extract file path from URL
      // Contoh URL: https://xxx.supabase.co/storage/v1/object/public/foto-temuan/temuan_photos/123456_photo.jpg
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Cari index 'foto-temuan' dan ambil path setelahnya
      final bucketIndex = pathSegments.indexOf('foto-temuan');
      if (bucketIndex == -1) {
        throw Exception('Invalid URL format');
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      appLog.d('📝 File path to delete: $filePath');

      // Delete dari Supabase Storage
      await _supabase.storage.from('foto-temuan').remove([filePath]);

      appLog.d('✅ Foto berhasil dihapus');

      return {
        'success': true,
        'message': 'Foto berhasil dihapus',
      };
    } catch (e) {
      appLog.e('❌ Error delete foto', error: e);
      return {
        'success': false,
        'message': 'Gagal menghapus foto: ${e.toString()}',
      };
    }
  }

  /// Delete multiple photos
  Future<void> deleteFotos(List<String> photoUrls) async {
    for (final url in photoUrls) {
      await deleteFoto(url);
    }
  }

  // ==================== TEMUAN CRUD ====================

  Future<Map<String, dynamic>> createTemuan(TemuanModel temuan) async {
    try {
      appLog.d('🔄 Creating temuan untuk user: $currentUserId');

      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final temuanData = temuan.toJson();
      temuanData['user_id'] = currentUserId;
      temuanData['created_by'] = currentUserEmail;

      // Set ULP dari profil user
      final profile = await _ulpService.getCurrentUserProfile();
      if (profile != null && profile['ulp'] != null) {
        temuanData['ulp'] = profile['ulp'];
      }

      // Auto-close: saat closing diisi, otomatis set status Closed
      if (temuanData['jenis_closing'] != null) {
        temuanData['status_temuan'] = 'Closed';
      }

      appLog.d('📝 Data temuan: $temuanData');

      final response =
          await _supabase.from('temuan').insert(temuanData).select().single();

      appLog.d('✅ Temuan berhasil dibuat: ${response['id']}');

      return {
        'success': true,
        'message': 'Temuan berhasil disimpan',
        'data': TemuanModel.fromJson(response),
      };
    } catch (e) {
      appLog.e('❌ Error create temuan', error: e);
      return {
        'success': false,
        'message': 'Gagal menyimpan temuan: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getTemuanPaginated({
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      if (currentUserId == null) {
        return {
          'success': false,
          'message': 'User tidak terautentikasi',
          'data': <TemuanModel>[],
          'hasMore': false,
        };
      }

      final from = page * pageSize;
      final to = from + pageSize - 1;

      final profile = await _ulpService.getCurrentUserProfile();
      final isAdmin = profile?['role'] == 'admin';
      final ulp = profile?['ulp'] as String?;

      late List response;
      if (isAdmin) {
        response = await _supabase
            .from('temuan')
            .select('*')
            .order('created_at', ascending: false)
            .range(from, to);
      } else if (ulp != null && ulp.isNotEmpty) {
        response = await _supabase
            .from('temuan')
            .select('*')
            .eq('ulp', ulp)
            .order('created_at', ascending: false)
            .range(from, to);
      } else {
        // Fallback: tampilkan hanya milik sendiri jika ULP belum disetel
        response = await _supabase
            .from('temuan')
            .select('*')
            .eq('user_id', currentUserId!)
            .order('created_at', ascending: false)
            .range(from, to);
      }

      final List<TemuanModel> temuanList =
          response.map((json) => TemuanModel.fromJson(json as Map<String, dynamic>)).toList();

      return {
        'success': true,
        'message': 'Data berhasil dimuat',
        'data': temuanList,
        'hasMore': temuanList.length == pageSize,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memuat data: ${e.toString()}',
        'data': <TemuanModel>[],
        'hasMore': false,
      };
    }
  }

  Future<Map<String, dynamic>> getAllTemuanSilent() async {
    try {
      appLog.d('🔄 Loading temuan untuk user: $currentUserId');

      if (currentUserId == null) {
        return {
          'success': false,
          'message': 'User tidak terautentikasi',
          'data': <TemuanModel>[],
        };
      }

      final profile = await _ulpService.getCurrentUserProfile();
      final isAdmin = profile?['role'] == 'admin';
      final ulp = profile?['ulp'] as String?;

      late List response;
      if (isAdmin) {
        response = await _supabase
            .from('temuan')
            .select('*')
            .order('created_at', ascending: false);
        appLog.d('✅ Admin: load semua temuan (${response.length})');
      } else if (ulp != null && ulp.isNotEmpty) {
        response = await _supabase
            .from('temuan')
            .select('*')
            .eq('ulp', ulp)
            .order('created_at', ascending: false);
        appLog.d('✅ User: load temuan ULP=$ulp (${response.length})');
      } else {
        response = await _supabase
            .from('temuan')
            .select('*')
            .eq('user_id', currentUserId!)
            .order('created_at', ascending: false);
        appLog.d('✅ Fallback: load temuan user_id (${response.length})');
      }

      final List<TemuanModel> temuanList =
          response.map((json) => TemuanModel.fromJson(json as Map<String, dynamic>)).toList();

      return {
        'success': true,
        'message': 'Data berhasil dimuat',
        'data': temuanList,
        'isAdmin': isAdmin,
      };
    } catch (e) {
      appLog.e('❌ Error get temuan', error: e);
      return {
        'success': false,
        'message': 'Gagal memuat data: ${e.toString()}',
        'data': <TemuanModel>[],
        'isAdmin': false,
      };
    }
  }

  Future<Map<String, dynamic>> deleteTemuanSilent(String id) async {
    try {
      appLog.d('🔄 Deleting temuan $id untuk user: $currentUserId');

      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final profile = await _ulpService.getCurrentUserProfile();
      final isAdmin = profile?['role'] == 'admin';
      final currentUlp = profile?['ulp'] as String?;

      // Get temuan data first to delete photos
      final temuanResponse = await _supabase
          .from('temuan')
          .select('user_id, ulp, foto_urls')
          .eq('id', id)
          .single();

      final recordUserId = temuanResponse['user_id'] as String?;
      final recordUlp = temuanResponse['ulp'] as String?;

      final isOwner = recordUserId == currentUserId;
      final isUlpMatch =
          recordUlp != null && currentUlp != null && recordUlp == currentUlp;
      final hasPermission =
          isAdmin || isOwner || (recordUserId == null && isUlpMatch);

      if (!hasPermission) {
        return {
          'success': false,
          'message': 'Anda tidak memiliki akses untuk menghapus data ini',
        };
      }

      // Delete photos if exist
      if (temuanResponse['foto_urls'] != null) {
        final fotoUrls = List<String>.from(temuanResponse['foto_urls']);
        appLog.d('🗑️ Menghapus ${fotoUrls.length} foto...');
        await deleteFotos(fotoUrls);
      }

      // Delete temuan record
      if (isAdmin || (recordUserId == null && isUlpMatch)) {
        await _supabase.from('temuan').delete().eq('id', id);
      } else {
        await _supabase
            .from('temuan')
            .delete()
            .eq('id', id)
            .eq('user_id', currentUserId!);
      }

      appLog.d('✅ Temuan $id berhasil dihapus');

      return {'success': true, 'message': 'Data berhasil dihapus'};
    } catch (e) {
      appLog.e('❌ Error delete temuan', error: e);
      return {
        'success': false,
        'message': 'Gagal menghapus data: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateTemuan(
    String id,
    TemuanModel temuan,
  ) async {
    try {
      appLog.d('🔄 Updating temuan $id untuk user: $currentUserId');

      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final profile = await _ulpService.getCurrentUserProfile();
      final isAdmin = profile?['role'] == 'admin';
      final currentUlp = profile?['ulp'] as String?;

      final checkResponse = await _supabase
          .from('temuan')
          .select('user_id, ulp')
          .eq('id', id)
          .single();

      final recordUserId = checkResponse['user_id'] as String?;
      final recordUlp = checkResponse['ulp'] as String?;

      final isOwner = recordUserId == currentUserId;
      final isUlpMatch =
          recordUlp != null && currentUlp != null && recordUlp == currentUlp;
      // Data lama tanpa owner (user_id null): izinkan jika ULP match
      final hasPermission =
          isAdmin || isOwner || (recordUserId == null && isUlpMatch);

      if (!hasPermission) {
        return {
          'success': false,
          'message': 'Anda tidak memiliki akses untuk mengubah data ini',
        };
      }

      final temuanData = temuan.toJson();
      temuanData['updated_at'] = DateTime.now().toIso8601String();

      // Auto-close: saat closing diisi, otomatis set status Closed
      if (temuanData['jenis_closing'] != null) {
        temuanData['status_temuan'] = 'Closed';
      }

      late Map<String, dynamic> response;
      if (isAdmin || (recordUserId == null && isUlpMatch)) {
        response = await _supabase
            .from('temuan')
            .update(temuanData)
            .eq('id', id)
            .select()
            .single();
      } else {
        response = await _supabase
            .from('temuan')
            .update(temuanData)
            .eq('id', id)
            .eq('user_id', currentUserId!)
            .select()
            .single();
      }

      appLog.d('✅ Temuan $id berhasil diupdate');

      return {
        'success': true,
        'message': 'Data berhasil diperbarui',
        'data': TemuanModel.fromJson(response),
      };
    } catch (e) {
      appLog.e('❌ Error update temuan', error: e);
      return {
        'success': false,
        'message': 'Gagal memperbarui data: ${e.toString()}',
      };
    }
  }

  /// Fetch temuan by ID tanpa filter user — untuk navigasi dari notifikasi (admin bisa lihat semua)
  Future<TemuanModel?> getTemuanByIdAny(String id) async {
    try {
      final response = await _supabase
          .from('temuan')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      return TemuanModel.fromJson(response);
    } catch (e) {
      appLog.e('❌ Error get temuan by id (any)', error: e);
      return null;
    }
  }

  Future<Map<String, dynamic>> getTemuanById(String id) async {
    try {
      appLog.d('🔄 Getting temuan $id untuk user: $currentUserId');

      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final response = await _supabase
          .from('temuan')
          .select('*')
          .eq('id', id)
          .eq('user_id', currentUserId!)
          .single();

      return {
        'success': true,
        'message': 'Data berhasil dimuat',
        'data': TemuanModel.fromJson(response),
      };
    } catch (e) {
      appLog.e('❌ Error get temuan by id', error: e);
      return {
        'success': false,
        'message': 'Data tidak ditemukan atau bukan milik Anda',
      };
    }
  }

  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final response =
          await _supabase.from('temuan').select('id').eq('user_id', currentUserId!);

      final totalTemuan = (response as List).length;

      return {
        'success': true,
        'data': {'total_temuan': totalTemuan, 'user_email': currentUserEmail},
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat statistik'};
    }
  }

  // ==================== SOSIALISASI CRUD ====================

  Future<Map<String, dynamic>> addSosialisasi(SosialisasiModel sosialisasi) async {
    try {
      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final data = sosialisasi.toJson();
      data['created_by'] = currentUserEmail;

      final response = await _supabase
          .from('temuan_sosialisasi')
          .insert(data)
          .select()
          .single();

      appLog.d('✅ Sosialisasi berhasil ditambah: ${response['id']}');

      return {
        'success': true,
        'message': 'Sosialisasi berhasil disimpan',
        'data': SosialisasiModel.fromJson(response),
      };
    } catch (e) {
      appLog.e('❌ Error add sosialisasi', error: e);
      return {
        'success': false,
        'message': 'Gagal menyimpan sosialisasi: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getSosialisasiByTemuan(String temuanId) async {
    try {
      if (currentUserId == null) {
        return {
          'success': false,
          'message': 'User tidak terautentikasi',
          'data': <SosialisasiModel>[],
        };
      }

      final response = await _supabase
          .from('temuan_sosialisasi')
          .select('*')
          .eq('temuan_id', temuanId)
          .order('tgl_sosialisasi', ascending: false);

      final List<SosialisasiModel> list = (response as List)
          .map((json) => SosialisasiModel.fromJson(json))
          .toList();

      return {
        'success': true,
        'data': list,
      };
    } catch (e) {
      appLog.e('❌ Error get sosialisasi', error: e);
      return {
        'success': false,
        'message': 'Gagal memuat sosialisasi: ${e.toString()}',
        'data': <SosialisasiModel>[],
      };
    }
  }

  Future<Map<String, dynamic>> deleteSosialisasi(String id) async {
    try {
      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      await _supabase.from('temuan_sosialisasi').delete().eq('id', id);

      appLog.d('✅ Sosialisasi $id berhasil dihapus');

      return {'success': true, 'message': 'Sosialisasi berhasil dihapus'};
    } catch (e) {
      appLog.e('❌ Error delete sosialisasi', error: e);
      return {
        'success': false,
        'message': 'Gagal menghapus sosialisasi: ${e.toString()}',
      };
    }
  }
}
