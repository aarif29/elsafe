import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/snackbar.dart';
import '../Screen/loginscreen.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔑 [DEBUG] NewPasswordPage initialized');
    _checkRecoverySession();
  }

  Future<void> _checkRecoverySession() async {
    debugPrint('🔍 [DEBUG] Checking for recovery session...');
    try {
      final session = Supabase.instance.client.auth.currentSession;
      debugPrint('🔐 [DEBUG] Current session: ${session != null ? "Exists" : "Null"}');

      if (session == null) {
        debugPrint('⚠️ [DEBUG] No session found, redirecting to login');
        if (mounted) {
          SnackBarUtils.showError(
            context,
            title: 'Sesi Tidak Valid',
            message: 'Sesi reset password tidak valid. Silakan coba lagi.',
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [DEBUG] Error checking session: ${e.toString()}');
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Terjadi Kesalahan',
          message: 'Gagal memeriksa sesi. Silakan coba lagi.',
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _updatePassword() async {
    debugPrint('🔄 [DEBUG] Starting password update process...');

    if (!(_formKey.currentState?.validate() ?? false)) {
      debugPrint('❌ [DEBUG] Form validation failed');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      debugPrint('🔍 [DEBUG] Password mismatch');
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Gagal',
          message: 'Konfirmasi password tidak cocok.',
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    final newPassword = _newPasswordController.text;

    debugPrint('🔑 [DEBUG] Attempting to update password');
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (mounted) {
        SnackBarUtils.showSuccess(
          context,
          title: 'Berhasil!',
          message: 'Password berhasil diperbarui. Silakan login dengan password baru Anda.',
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      debugPrint('❌ [DEBUG] AuthException: ${e.message}');
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Gagal Memperbarui',
          message: e.message,
        );
      }
    } catch (e) {
      debugPrint('❌ [DEBUG] Unexpected error: ${e.toString()}');
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

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Password Baru'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Atur Password Baru Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Silakan masukkan password baru Anda di bawah ini.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    hintText: 'Minimal 6 karakter',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    labelStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                    hintText: 'Ketik ulang password baru Anda',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    labelStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0072FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Perbarui Password',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}