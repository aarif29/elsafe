import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'temuan_model.dart';

class TemuanService {
  final _supabase = Supabase.instance.client;

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
      print('❌ Error get user profile: $e');
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

        print('📤 Uploading foto: ${file.name}');
        print('📝 File path: $filePath');

        if (kIsWeb) {
          // ===== WEB: Gunakan bytes =====
          if (file.bytes == null) {
            throw Exception('File bytes is null for web');
          }

          print('📦 File size (WEB): ${file.bytes!.length} bytes');

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

          print('✅ Upload berhasil (WEB): $uploadedPath');
        } else {
          // ===== MOBILE: Gunakan path =====
          if (file.path == null) {
            throw Exception('File path is null for mobile');
          }

          print('📦 File path (MOBILE): ${file.path}');

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

          print('✅ Upload berhasil (MOBILE): $uploadedPath');
        }
      } else if (file is File && !kIsWeb) {
        // ===== Fallback untuk File langsung (mobile only) =====
        fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        filePath = 'temuan_photos/$fileName';

        print('📤 Uploading foto (File): ${file.path}');

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

        print('✅ Upload berhasil: $uploadedPath');
      } else {
        throw Exception('Unsupported file type. Expected PlatformFile or File.');
      }

      // Get public URL
      final String publicUrl = _supabase.storage
          .from('foto-temuan')
          .getPublicUrl(filePath);

      print('🔗 Public URL: $publicUrl');

      return {
        'success': true,
        'url': publicUrl,
        'path': filePath,
        'message': 'Foto berhasil diupload',
      };
    } catch (e) {
      print('❌ Error upload foto: $e');
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
      print('🗑️ Deleting foto: $url');

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

      print('📝 File path to delete: $filePath');

      // Delete dari Supabase Storage
      await _supabase.storage.from('foto-temuan').remove([filePath]);

      print('✅ Foto berhasil dihapus');

      return {
        'success': true,
        'message': 'Foto berhasil dihapus',
      };
    } catch (e) {
      print('❌ Error delete foto: $e');
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
      print('🔄 Creating temuan untuk user: $currentUserId');

      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final temuanData = temuan.toJson();
      temuanData['user_id'] = currentUserId;
      temuanData['created_by'] = currentUserEmail;

      print('📝 Data temuan: $temuanData');

      final response =
          await _supabase.from('temuan').insert(temuanData).select().single();

      print('✅ Temuan berhasil dibuat: ${response['id']}');

      return {
        'success': true,
        'message': 'Temuan berhasil disimpan',
        'data': TemuanModel.fromJson(response),
      };
    } catch (e) {
      print('❌ Error create temuan: $e');
      return {
        'success': false,
        'message': 'Gagal menyimpan temuan: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getAllTemuanSilent() async {
    try {
      print('🔄 Loading temuan untuk user: $currentUserId');

      if (currentUserId == null) {
        return {
          'success': false,
          'message': 'User tidak terautentikasi',
          'data': <TemuanModel>[],
        };
      }

      final response = await _supabase
          .from('temuan')
          .select('*')
          .eq('user_id', currentUserId!)
          .order('created_at', ascending: false);

      final List<TemuanModel> temuanList =
          (response as List).map((json) => TemuanModel.fromJson(json)).toList();

      print(
        '✅ Berhasil load ${temuanList.length} temuan untuk user: $currentUserEmail',
      );

      return {
        'success': true,
        'message': 'Data berhasil dimuat',
        'data': temuanList,
      };
    } catch (e) {
      print('❌ Error get temuan: $e');
      return {
        'success': false,
        'message': 'Gagal memuat data: ${e.toString()}',
        'data': <TemuanModel>[],
      };
    }
  }

  Future<Map<String, dynamic>> deleteTemuanSilent(String id) async {
    try {
      print('🔄 Deleting temuan $id untuk user: $currentUserId');

      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      // Get temuan data first to delete photos
      final temuanResponse = await _supabase
          .from('temuan')
          .select('user_id, foto_urls')
          .eq('id', id)
          .single();

      if (temuanResponse['user_id'] != currentUserId) {
        return {
          'success': false,
          'message': 'Anda tidak memiliki akses untuk menghapus data ini',
        };
      }

      // Delete photos if exist
      if (temuanResponse['foto_urls'] != null) {
        final fotoUrls = List<String>.from(temuanResponse['foto_urls']);
        print('🗑️ Menghapus ${fotoUrls.length} foto...');
        await deleteFotos(fotoUrls);
      }

      // Delete temuan record
      await _supabase
          .from('temuan')
          .delete()
          .eq('id', id)
          .eq('user_id', currentUserId!);

      print('✅ Temuan $id berhasil dihapus');

      return {'success': true, 'message': 'Data berhasil dihapus'};
    } catch (e) {
      print('❌ Error delete temuan: $e');
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
      print('🔄 Updating temuan $id untuk user: $currentUserId');

      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final checkResponse = await _supabase
          .from('temuan')
          .select('user_id')
          .eq('id', id)
          .single();

      if (checkResponse['user_id'] != currentUserId) {
        return {
          'success': false,
          'message': 'Anda tidak memiliki akses untuk mengubah data ini',
        };
      }

      final temuanData = temuan.toJson();
      temuanData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('temuan')
          .update(temuanData)
          .eq('id', id)
          .eq('user_id', currentUserId!)
          .select()
          .single();

      print('✅ Temuan $id berhasil diupdate');

      return {
        'success': true,
        'message': 'Data berhasil diperbarui',
        'data': TemuanModel.fromJson(response),
      };
    } catch (e) {
      print('❌ Error update temuan: $e');
      return {
        'success': false,
        'message': 'Gagal memperbarui data: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getTemuanById(String id) async {
    try {
      print('🔄 Getting temuan $id untuk user: $currentUserId');

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
      print('❌ Error get temuan by id: $e');
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
}
