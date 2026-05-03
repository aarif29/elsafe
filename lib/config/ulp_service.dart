import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_logger.dart';

class UlpService {
  final _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;
  String? get _currentUserEmail => _supabase.auth.currentUser?.email;

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      if (_currentUserId == null) return null;
      final data = await _supabase
          .from('profiles')
          .select('id, full_name, nip, ulp, role, ulp_status')
          .eq('id', _currentUserId!)
          .maybeSingle();
      return data;
    } catch (e) {
      appLog.e('Error get profile (UlpService)', error: e);
      return null;
    }
  }

  Future<bool> isAdmin() async {
    final profile = await getCurrentUserProfile();
    return profile?['role'] == 'admin';
  }

  /// Dipanggil satu kali saat user pertama kali login via Google OAuth
  /// dan belum memilih ULP.
  Future<Map<String, dynamic>> setUserUlp(String ulp) async {
    try {
      if (_currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }
      await _supabase.from('profiles').upsert({
        'id': _currentUserId,
        'email': _currentUserEmail,
        'ulp': ulp,
        'ulp_status': 'active',
        'role': 'user',
      });
      appLog.d('✅ ULP disetel: $ulp');
      return {'success': true, 'message': 'ULP berhasil disetel'};
    } catch (e) {
      appLog.e('Error set ULP', error: e);
      return {'success': false, 'message': 'Gagal menyetel ULP: $e'};
    }
  }

  /// User mengajukan permintaan ganti ULP, menunggu persetujuan admin.
  Future<Map<String, dynamic>> requestGantiUlp(
    String ulpBaru, {
    String? alasan,
  }) async {
    try {
      if (_currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final profile = await getCurrentUserProfile();
      final ulpLama = profile?['ulp'] as String?;
      if (ulpLama == null || ulpLama.isEmpty) {
        return {'success': false, 'message': 'ULP saat ini belum disetel'};
      }
      if (ulpLama == ulpBaru) {
        return {'success': false, 'message': 'ULP yang dipilih sama dengan ULP saat ini'};
      }

      // Cek apakah sudah ada permintaan yang pending
      final existing = await _supabase
          .from('ulp_change_requests')
          .select('id')
          .eq('user_id', _currentUserId!)
          .eq('status', 'pending')
          .maybeSingle();

      if (existing != null) {
        return {
          'success': false,
          'message': 'Anda sudah memiliki permintaan ganti ULP yang menunggu persetujuan admin',
        };
      }

      await _supabase.from('ulp_change_requests').insert({
        'user_id': _currentUserId,
        'ulp_lama': ulpLama,
        'ulp_baru': ulpBaru,
        'alasan': alasan,
        'status': 'pending',
      });

      appLog.d('✅ Permintaan ganti ULP dikirim: $ulpLama → $ulpBaru');
      return {
        'success': true,
        'message': 'Permintaan ganti ULP telah dikirim. Menunggu persetujuan admin.',
      };
    } catch (e) {
      appLog.e('Error request ganti ULP', error: e);
      return {'success': false, 'message': 'Gagal mengirim permintaan: $e'};
    }
  }

  /// Cek apakah user punya permintaan pending
  Future<bool> hasPendingRequest() async {
    try {
      if (_currentUserId == null) return false;
      final existing = await _supabase
          .from('ulp_change_requests')
          .select('id')
          .eq('user_id', _currentUserId!)
          .eq('status', 'pending')
          .maybeSingle();
      return existing != null;
    } catch (_) {
      return false;
    }
  }

  /// Admin: ambil semua permintaan pending
  Future<Map<String, dynamic>> getPendingRequests() async {
    try {
      // Ambil semua request pending
      final requests = await _supabase
          .from('ulp_change_requests')
          .select('*')
          .eq('status', 'pending')
          .order('created_at', ascending: false) as List;

      if (requests.isEmpty) {
        return {'success': true, 'data': <dynamic>[]};
      }

      // Ambil profil user untuk setiap request
      final userIds = requests.map((r) => r['user_id'] as String).toSet().toList();
      final profiles = await _supabase
          .from('profiles')
          .select('id, full_name, nip')
          .inFilter('id', userIds) as List;

      final profileMap = {for (final p in profiles) p['id'] as String: p};

      // Gabungkan
      final enriched = requests.map((r) {
        final map = Map<String, dynamic>.from(r as Map);
        map['profiles'] = profileMap[r['user_id'] as String];
        return map;
      }).toList();

      return {'success': true, 'data': enriched};
    } catch (e) {
      appLog.e('Error get pending requests', error: e);
      return {
        'success': false,
        'message': 'Gagal memuat permintaan: $e',
        'data': <dynamic>[],
      };
    }
  }

  /// Admin: setujui permintaan ganti ULP
  Future<Map<String, dynamic>> approveRequest(String requestId) async {
    try {
      if (_currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      final request = await _supabase
          .from('ulp_change_requests')
          .select('user_id, ulp_baru')
          .eq('id', requestId)
          .single();

      final targetUserId = request['user_id'] as String;
      final ulpBaru = request['ulp_baru'] as String;

      // Update status permintaan
      await _supabase.from('ulp_change_requests').update({
        'status': 'approved',
        'reviewed_by': _currentUserId,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', requestId);

      // Update ULP user yang meminta
      await _supabase
          .from('profiles')
          .update({'ulp': ulpBaru})
          .eq('id', targetUserId);

      appLog.d('✅ Request $requestId disetujui');
      return {'success': true, 'message': 'Permintaan berhasil disetujui'};
    } catch (e) {
      appLog.e('Error approve request', error: e);
      return {'success': false, 'message': 'Gagal menyetujui permintaan: $e'};
    }
  }

  /// Admin: tolak permintaan ganti ULP
  Future<Map<String, dynamic>> rejectRequest(String requestId) async {
    try {
      if (_currentUserId == null) {
        return {'success': false, 'message': 'User tidak terautentikasi'};
      }

      await _supabase.from('ulp_change_requests').update({
        'status': 'rejected',
        'reviewed_by': _currentUserId,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', requestId);

      appLog.d('✅ Request $requestId ditolak');
      return {'success': true, 'message': 'Permintaan ditolak'};
    } catch (e) {
      appLog.e('Error reject request', error: e);
      return {'success': false, 'message': 'Gagal menolak permintaan: $e'};
    }
  }
}
