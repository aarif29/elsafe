import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_logger.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _supabase = Supabase.instance.client;

  /// Jumlah notifikasi yang belum dibaca — reactive, dipantau widget
  final unreadCount = ValueNotifier<int>(0);

  RealtimeChannel? _channel;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Panggil sekali setelah user login (di MainShell.initState)
  Future<void> initialize() async {
    await refreshUnreadCount();
    _subscribeRealtime();
  }

  /// Perbarui hitungan notifikasi belum dibaca dari DB
  Future<void> refreshUnreadCount() async {
    try {
      if (_currentUserId == null) return;
      final res = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', _currentUserId!)
          .eq('is_read', false);
      unreadCount.value = (res as List).length;
    } catch (e) {
      appLog.e('Error refresh unread count', error: e);
    }
  }

  /// Berlangganan Realtime — otomatis naikkan badge saat notif baru masuk
  void _subscribeRealtime() {
    if (_currentUserId == null) return;

    _channel?.unsubscribe();
    _channel = _supabase
        .channel('notif_$_currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (_) {
            unreadCount.value++;
            appLog.d('🔔 Notifikasi baru masuk');
          },
        )
        .subscribe();
  }

  /// Ambil semua notifikasi user (max 50, terbaru dulu)
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      if (_currentUserId == null) return [];
      final res = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      appLog.e('Error get notifications', error: e);
      return [];
    }
  }

  /// Tandai satu notifikasi sebagai sudah dibaca
  Future<void> markAsRead(String id) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
      await refreshUnreadCount();
    } catch (e) {
      appLog.e('Error mark as read', error: e);
    }
  }

  /// Tandai semua notifikasi user sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    try {
      if (_currentUserId == null) return;
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _currentUserId!)
          .eq('is_read', false);
      unreadCount.value = 0;
    } catch (e) {
      appLog.e('Error mark all as read', error: e);
    }
  }

  /// Cek saat simpan temuan: jika tgl_reminder sudah ≥19 hari lalu & status Open,
  /// langsung buat notifikasi tanpa menunggu cron harian.
  Future<void> checkAndNotifyOverdue({
    required String temuanId,
    required String namaPemilik,
    required String lokasi,
    required DateTime tglReminder,
  }) async {
    try {
      final now = DateTime.now();
      final daysPassed = now.difference(tglReminder).inDays;
      if (daysPassed < 19) return; // Belum waktunya

      // Ambil user_id & ulp dari temuan (untuk notif creator)
      final temuanRow = await _supabase
          .from('temuan')
          .select('user_id, ulp, jenis_closing, status_temuan')
          .eq('id', temuanId)
          .maybeSingle();

      if (temuanRow == null) return;
      if (temuanRow['jenis_closing'] != null) return; // Sudah di-closing
      if (temuanRow['status_temuan'] != 'Open') return;

      final creatorId = temuanRow['user_id'] as String;
      final ulp = temuanRow['ulp'] as String? ?? '-';

      // Ambil semua admin
      final adminRows = await _supabase
          .from('profiles')
          .select('id')
          .eq('role', 'admin') as List;
      final adminIds = adminRows.map((r) => r['id'] as String).toList();

      final targetIds = {creatorId, ...adminIds};
      final title = "Temuan '$namaPemilik' belum ditindaklanjuti";
      final body =
          'Sudah $daysPassed hari sejak pengingat diatur. Lokasi: $lokasi. ULP: $ulp. Segera lakukan tindak lanjut.';

      final today = DateTime(now.year, now.month, now.day).toUtc();

      for (final userId in targetIds) {
        // Hindari duplikat di hari yang sama
        final existing = await _supabase
            .from('notifications')
            .select('id')
            .eq('user_id', userId)
            .eq('temuan_id', temuanId)
            .eq('type', 'reminder_h1')
            .gte('created_at', today.toIso8601String())
            .maybeSingle();

        if (existing == null) {
          await _supabase.from('notifications').insert({
            'user_id': userId,
            'temuan_id': temuanId,
            'title': title,
            'body': body,
            'type': 'reminder_h1',
          });
        }
      }

      appLog.d('🔔 checkAndNotifyOverdue: notifikasi dibuat untuk $temuanId ($daysPassed hari)');
    } catch (e) {
      appLog.e('Error checkAndNotifyOverdue', error: e);
    }
  }

  /// Hapus notifikasi reminder jika tgl_reminder diubah ke tanggal belum overdue (< 19 hari)
  Future<void> clearReminderNotifIfNotOverdue({
    required String temuanId,
    required DateTime? tglReminder,
  }) async {
    try {
      final shouldClear = tglReminder == null ||
          DateTime.now().difference(tglReminder).inDays < 19;
      if (!shouldClear) return;

      await _supabase
          .from('notifications')
          .delete()
          .eq('temuan_id', temuanId)
          .eq('type', 'reminder_h1');

      appLog.d('🗑️ clearReminderNotif: notifikasi dihapus untuk $temuanId');
    } catch (e) {
      appLog.e('Error clearReminderNotif', error: e);
    }
  }

  /// Bersihkan saat logout
  void reset() {
    _channel?.unsubscribe();
    _channel = null;
    unreadCount.value = 0;
  }
}
