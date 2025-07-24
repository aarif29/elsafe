// config/temuan_service.dart - UPDATE
import 'package:supabase_flutter/supabase_flutter.dart';
import 'temuan_model.dart';

class TemuanService {
  final _supabase = Supabase.instance.client;

  // GET USER ID - Helper function
  String? get currentUserId {
    final user = _supabase.auth.currentUser;
    return user?.id;
  }

  // GET USER EMAIL - Helper function
  String? get currentUserEmail {
    final user = _supabase.auth.currentUser;
    return user?.email;
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      if (currentUserId == null) return null;

      final response =
          await _supabase
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

  Future<Map<String, dynamic>> createTemuan(TemuanModel temuan) async {
    try {
      print('🔄 Creating temuan untuk user: $currentUserId');

      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final temuanData = temuan.toJson();
      temuanData['user_id'] = currentUserId;
      temuanData['created_by'] = currentUserEmail;

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

  // GET ALL TEMUAN - HANYA MILIK USER YANG LOGIN
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

      // FILTER berdasarkan user_id
      final response = await _supabase
          .from('temuan')
          .select('*')
          .eq('user_id', currentUserId!) // HANYA DATA USER INI
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

  // DELETE TEMUAN - HANYA MILIK USER YANG LOGIN
  Future<Map<String, dynamic>> deleteTemuanSilent(String id) async {
    try {
      print('🔄 Deleting temuan $id untuk user: $currentUserId');

      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      // Cek ownership dulu
      final checkResponse =
          await _supabase
              .from('temuan')
              .select('user_id')
              .eq('id', id)
              .single();

      if (checkResponse['user_id'] != currentUserId) {
        return {
          'success': false,
          'message': 'Anda tidak memiliki akses untuk menghapus data ini',
        };
      }

      // Delete jika memang milik user
      await _supabase
          .from('temuan')
          .delete()
          .eq('id', id)
          .eq('user_id', currentUserId!); // Double safety

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

  // UPDATE TEMUAN - HANYA MILIK USER YANG LOGIN
  Future<Map<String, dynamic>> updateTemuan(
    String id,
    TemuanModel temuan,
  ) async {
    try {
      print('🔄 Updating temuan $id untuk user: $currentUserId');

      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      // Cek ownership dulu
      final checkResponse =
          await _supabase
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

      // Update jika memang milik user
      final temuanData = temuan.toJson();
      temuanData['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _supabase
              .from('temuan')
              .update(temuanData)
              .eq('id', id)
              .eq('user_id', currentUserId!) // Double safety
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

  // GET TEMUAN BY ID - HANYA MILIK USER YANG LOGIN
  Future<Map<String, dynamic>> getTemuanById(String id) async {
    try {
      print('🔄 Getting temuan $id untuk user: $currentUserId');

      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final response =
          await _supabase
              .from('temuan')
              .select('*')
              .eq('id', id)
              .eq('user_id', currentUserId!) // HANYA MILIK USER INI
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

  // GET STATISTICS - HANYA MILIK USER YANG LOGIN
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      if (currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final response = await _supabase
          .from('temuan')
          .select('id')
          .eq('user_id', currentUserId!);

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
