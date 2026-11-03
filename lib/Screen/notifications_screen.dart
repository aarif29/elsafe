import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/notification_service.dart';
import '../config/temuan_service.dart';
import '../config/app_theme.dart';
import '../config/snackbar.dart';
import '../config/ulp_service.dart';
import '../widgets/daftar_temuan/temuan_detail_dialog.dart';
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
  final _ulpService = UlpService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
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

  Future<void> _loadRole() async {
    final isAdmin = await _ulpService.isAdmin();
    if (!mounted) return;
    setState(() => _isAdmin = isAdmin);
  }

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

    _isAdmin = await _ulpService.isAdmin();
    if (_isAdmin) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (context) => TemuanDetailDialog(
              temuan: temuan,
              onOpenMaps: _openGoogleMaps,
              onCopyCoordinates: _copyCoordinates,
              onEdit: null,
            ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTemuanScreen(temuan: temuan)),
    );
  }

  Future<void> _openGoogleMaps(
    double latitude,
    double longitude,
    String lokasi,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      SnackBarUtils.showInfo(
        context,
        title: 'Maps',
        message: 'Membuka lokasi di Google Maps...',
      );
    }
  }

  Future<void> _copyCoordinates(double latitude, double longitude) async {
    final coordinates = '$latitude, $longitude';
    await Clipboard.setData(ClipboardData(text: coordinates));
    if (!mounted) return;
    SnackBarUtils.showSuccess(
      context,
      title: 'Disalin!',
      message: 'Koordinat: $coordinates',
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => n['is_read'] != true).length;
    final horizontalPadding =
        MediaQuery.sizeOf(context).width < 600 ? 16.0 : 28.0;
    final compactActions = MediaQuery.sizeOf(context).width < 420;

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
            compactActions
                ? IconButton(
                  onPressed: _markAllRead,
                  icon: const Icon(Icons.done_all_outlined),
                  tooltip: 'Tandai semua sudah dibaca',
                )
                : TextButton.icon(
                  onPressed: _markAllRead,
                  icon: const Icon(Icons.done_all_outlined, size: 18),
                  label: const Text('Tandai semua dibaca'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat ulang notifikasi',
            onPressed: _load,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
              ? _buildEmpty()
              : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        28,
                        horizontalPadding,
                        32,
                      ),
                      itemCount: _notifications.length + 1,
                      separatorBuilder:
                          (_, i) => SizedBox(height: i == 0 ? 20 : 10),
                      itemBuilder:
                          (_, i) =>
                              i == 0
                                  ? _buildSummary(unread)
                                  : _NotifCard(
                                    notif: _notifications[i - 1],
                                    onTap:
                                        () =>
                                            _onTapNotif(_notifications[i - 1]),
                                  ),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildSummary(int unread) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas terbaru',
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$unread belum dibaca dari ${_notifications.length} notifikasi',
          style: TextStyle(color: context.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pengingat tindak lanjut temuan akan muncul di sini.',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
    final title = (notif['title'] as String?)?.trim() ?? '';
    final body = (notif['body'] as String?)?.trim() ?? '';
    final createdAt =
        DateTime.tryParse(notif['created_at']?.toString() ?? '')?.toLocal();
    final isReminder = notif['type'] == 'reminder_h1';
    final accent =
        isReminder
            ? (context.isDark
                ? Colors.orange.shade300
                : Colors.deepOrange.shade700)
            : Theme.of(context).colorScheme.primary;
    final hasTemuan = notif['temuan_id'] != null;

    return Material(
      color: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color:
              isRead
                  ? context.borderColor
                  : Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.38),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(
                        alpha: context.isDark ? 0.16 : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isReminder
                          ? Icons.notification_important_outlined
                          : Icons.notifications_none_rounded,
                      color: accent,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isReminder ? 'Pengingat tindak lanjut' : 'Notifikasi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isRead ? 'Sudah dibaca' : 'Belum dibaca',
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title.isEmpty ? 'Pembaruan temuan' : title,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                ),
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    body,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
              if (createdAt != null || hasTemuan) ...[
                const SizedBox(height: 16),
                Divider(height: 1, color: context.borderColor),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (createdAt != null)
                      Flexible(
                        child: Text(
                          _formatDate(createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (hasTemuan) ...[
                      const Spacer(),
                      Text(
                        'Buka temuan',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.isNegative || diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
