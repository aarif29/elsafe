import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:elsafe/config/snackbar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nipController = TextEditingController();
  final _ulpController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _nameController.dispose();
    _nipController.dispose();
    _ulpController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Tutup keyboard
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final fullName = _nameController.text.trim();
      final nip = _nipController.text.trim();
      final ulp = _ulpController.text.trim();
      final phone = _phoneController.text.trim();

      // 1) Sign Up ke Supabase Auth, kirim metadata juga (optional tapi berguna)
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'nip': nip,
          'ulp': ulp,
          'phone': phone,
        },
        emailRedirectTo: null, // bisa diisi deep link verifikasi kalau perlu
      );

      final userId = res.user?.id;
      if (userId == null) {
        throw const AuthException('Sign up gagal: user tidak terbentuk');
      }

      // 2) Pastikan data masuk ke tabel profiles sekarang juga
      //    Gunakan upsert agar aman jika row sudah dibuat oleh trigger/ sebelumnya
      await _supabase.from('profiles').upsert({
        'id': userId,       // PK UUID, sama dengan auth.users.id
        'email': email,
        'full_name': fullName,
        'nip': nip,
        'ulp': ulp,
        'phone': phone,
      }, onConflict: 'id');

      if (mounted) {
        SnackBarUtils.showSuccess(
          context,
          title: 'Daftar Berhasil!',
          message: 'Akun dibuat. Silakan cek email untuk verifikasi.',
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Pendaftaran Gagal!',
          message: e.message,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Terjadi Kesalahan',
          message: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Daftar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 12),

                _buildInputField(
                  controller: _nameController,
                  hint: 'Nama Lengkap',
                  icon: Icons.person,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Nama diperlukan'
                          : null,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                _buildInputField(
                  controller: _nipController,
                  hint: 'NIP',
                  icon: Icons.badge_outlined,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'NIP diperlukan'
                          : null,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                _buildInputField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Email diperlukan';
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$',
                    );
                    if (!emailRegex.hasMatch(v)) return 'Email tidak valid';
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                _buildInputField(
                  controller: _ulpController,
                  hint: 'Nama ULP',
                  icon: Icons.location_on_outlined,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Nama ULP diperlukan'
                          : null,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                _buildInputField(
                  controller: _phoneController,
                  hint: 'Nomor HP',
                  icon: Icons.phone,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return null; // opsional
                    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(v)) {
                      return 'Format nomor HP tidak valid';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                _buildInputField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (value) {
                    final v = value ?? '';
                    if (v.isEmpty) return 'Password diperlukan';
                    if (v.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                _buildInputField(
                  controller: _confirmPasswordController,
                  hint: 'Konfirmasi Password',
                  icon: Icons.lock_reset,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (value) {
                    final v = value ?? '';
                    if (v.isEmpty) return 'Konfirmasi password diperlukan';
                    if (v != _passwordController.text) {
                      return 'Password tidak sama';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                ),

                const SizedBox(height: 24),

                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[500],
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
        keyboardType: keyboardType ??
            (hint == 'Email'
                ? TextInputType.emailAddress
                : (hint == 'NIP' || hint.contains('HP'))
                    ? TextInputType.number
                    : TextInputType.text),
        textInputAction: textInputAction ?? TextInputAction.next,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          disabledBackgroundColor: Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            : const Text(
                'Daftar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
