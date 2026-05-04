import 'package:flutter/material.dart';
import '../config/notification_service.dart';
import '../config/temuan_service.dart';
import '../config/app_theme.dart';
import 'edit_temuan.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const NotificationsScreen({super.key, this.onBack});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService.instance;
  final _temuanService = TemuanService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
    // Auto-reload saat ada notifikasi baru masuk via Realtime
    _service.unreadCount.addListener(_onNewNotif);
  }

  @override
  void dispose() {
    _service.unreadCount.removeListener(_onNewNotif);
    super.dispose();
  }

  void _onNewNotif() => _load();

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await _service.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    await _service.markAllAsRead();
    setState(() {
      for (final n in _notifications) {
        n['is_read'] = true;
      }
    });
  }

  Future<void> _onTapNotif(Map<String, dynamic> notif) async {
    // Tandai sudah dibaca
    if (notif['is_read'] != true) {
      await _service.markAsRead(notif['id'] as String);
      setState(() => notif['is_read'] = true);
    }

    // Navigasi ke detail temuan
    final temuanId = notif['temuan_id'] as String?;
    if (temuanId == null || !mounted) return;

    final temuan = await _temuanService.getTemuanByIdAny(temuanId);
    if (!mounted) return;

    if (temuan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data temuan tidak ditemukan')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTemuanScreen(temuan: temuan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => n['is_read'] != true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        automaticallyImplyLeading: false,
        leading:
            widget.onBack == null
                ? null
                : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                  tooltip: 'Kembali',
                ),
        actions: [
          if (unread > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Tandai semua'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _load,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder:
                      (_, i) => _NotifCard(
                        notif: _notifications[i],
                        onTap: () => _onTapNotif(_notifications[i]),
                      ),
                ),
              ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 72, color: context.textHint),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(color: context.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi pengingat temuan akan muncul di sini',
            style: TextStyle(color: context.textHint, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final Map<String, dynamic> notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRead = notif['is_read'] == true;
    final title = notif['title'] as String? ?? '';
    final body = notif['body'] as String? ?? '';
    final createdAt =
        notif['created_at'] != null
            ? DateTime.parse(notif['created_at'] as String).toLocal()
            : null;
    final type = notif['type'] as String? ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color:
              isRead
                  ? context.cardColor
                  : Colors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isRead
                    ? context.borderColor
                    : Colors.orange.withValues(alpha: 0.4),
            width: isRead ? 0.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon tipe
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconBgColor(type),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconData(type), color: _iconColor(type), size: 20),
            ),
            const SizedBox(width: 12),

            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (createdAt != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          _formatDate(createdAt),
                          style: TextStyle(
                            color: context.textHint,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tap untuk lihat detail →',
                          style: TextStyle(
                            color: Colors.blue.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconData(String type) {
    switch (type) {
      case 'reminder_h1':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications;
    }
  }

  Color _iconBgColor(String type) => Colors.orange.withValues(alpha: 0.15);

  Color _iconColor(String type) => Colors.orange;

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
