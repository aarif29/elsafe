import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/snackbar.dart';
import 'package:flutter/foundation.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
  if (!(_formKey.currentState?.validate() ?? false)) {
    return;
  }

  setState(() => _isLoading = true);

  try {
    await Supabase.instance.client.auth.resetPasswordForEmail(
      _emailController.text.trim(),
      redirectTo: kIsWeb
          ? 'http://localhost:8080/'
          : 'io.supabase.flutter://reset-callback/',
    );

    if (mounted) {
      SnackBarUtils.showSuccess(
        context,
        title: 'Berhasil!',
        message: 'Link reset password telah dikirim ke email Anda. Silakan cek email Anda.',
        duration: const Duration(seconds: 5),
      );
      Navigator.of(context).pop();
    }
  } on AuthException catch (e) {
    if (mounted) {
      String errorMessage = _mapSupabaseAuthError(e.message);
      SnackBarUtils.showError(
        context,
        title: 'Gagal Mengirim',
        message: errorMessage,
      );
    }
  } catch (e) {
    if (mounted) {
      SnackBarUtils.showError(
        context,
        title: 'Terjadi Kesalahan',
        message: 'Gagal terhubung ke server. Coba lagi nanti.',
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  String _mapSupabaseAuthError(String message) {
    debugPrint('🔍 [DEBUG] Mapping auth error: $message');
    final msg = message.toLowerCase();
    
    if (msg.contains('user not found')) {
      return 'Email tidak terdaftar.';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return 'Gagal terhubung ke server. Cek koneksi internet Anda.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🖌️ [DEBUG] Building ForgotPasswordDialog');
    
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Lupa Password?',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Masukkan email Anda untuk menerima link reset password.',
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email Anda',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500]),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  debugPrint('🚪 [DEBUG] Cancel button pressed');
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  debugPrint('🔄 [DEBUG] Reset password button pressed');
                  _resetPassword();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Kirim Link',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}