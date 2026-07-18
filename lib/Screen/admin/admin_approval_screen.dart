import 'package:flutter/material.dart';
import '../../config/ulp_service.dart';
import '../../config/ulp_list.dart';
import '../../config/app_theme.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  final _ulpService = UlpService();
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final result = await _ulpService.getPendingRequests();
    if (mounted) {
      setState(() {
        _requests = result['data'] as List? ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _approve(String id) async {
    final confirm = await _showConfirmDialog(
      title: 'Setujui Permintaan',
      message: 'Perubahan ULP akan langsung diterapkan ke akun pengguna.',
      confirmLabel: 'Setujui',
      confirmColor: Colors.green,
    );
    if (!confirm || !mounted) return;

    _showLoading();
    final result = await _ulpService.approveRequest(id);
    if (mounted) Navigator.pop(context); // dismiss loading
    if (!mounted) return;

    _showResultSnackbar(result);
    if (result['success'] == true) _loadRequests();
  }

  Future<void> _reject(String id) async {
    final confirm = await _showConfirmDialog(
      title: 'Tolak Permintaan',
      message: 'Pengguna tetap berada di ULP saat ini.',
      confirmLabel: 'Tolak',
      confirmColor: Colors.red,
    );
    if (!confirm || !mounted) return;

    _showLoading();
    final result = await _ulpService.rejectRequest(id);
    if (mounted) Navigator.pop(context); // dismiss loading
    if (!mounted) return;

    _showResultSnackbar(result);
    if (result['success'] == true) _loadRequests();
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  confirmLabel,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showResultSnackbar(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? ''),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persetujuan Ganti ULP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _requests.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                onRefresh: _loadRequests,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder:
                      (_, i) => _RequestCard(
                        request: _requests[i] as Map<String, dynamic>,
                        onApprove: () => _approve(_requests[i]['id'] as String),
                        onReject: () => _reject(_requests[i]['id'] as String),
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
          Icon(Icons.check_circle_outline, size: 64, color: context.textHint),
          const SizedBox(height: 16),
          Text(
            'Tidak ada permintaan menunggu',
            style: TextStyle(color: context.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final profile = request['profiles'] as Map<String, dynamic>?;
    final namaUser = profile?['full_name'] as String? ?? 'Tanpa Nama';
    final nipUser = profile?['nip'] as String? ?? '-';
    final ulpLama = request['ulp_lama'] as String? ?? '-';
    final ulpBaru = request['ulp_baru'] as String? ?? '-';
    final alasan = request['alasan'] as String?;
    final createdAt =
        request['created_at'] != null
            ? DateTime.parse(request['created_at'] as String)
            : null;

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: nama + tanggal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.blue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaUser,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (nipUser != '-')
                      Text(
                        'NIP: $nipUser',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (createdAt != null)
                Text(
                  '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}',
                  style: TextStyle(color: context.textHint, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ULP perubahan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.subtleSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ULP Saat Ini',
                        style: TextStyle(color: context.textHint, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        namaUlp(ulpLama),
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.orange, size: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ULP Baru',
                        style: TextStyle(color: context.textHint, fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        namaUlp(ulpBaru),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Alasan (jika ada)
          if (alasan != null && alasan.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: context.textHint),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    alasan,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Tombol aksi
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Tolak'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 16, color: Colors.white),
                  label: const Text('Setujui'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
