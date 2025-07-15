import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/snackbar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nipController = TextEditingController();
  final _ulpController = TextEditingController();
  final _phoneController = TextEditingController();
  final supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _profileId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Error',
          message: 'User belum login',
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final data =
          await supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

      if (data != null) {
        setState(() {
          _profileId = data['id'] as String?;
          _fullNameController.text = data['full_name'] ?? '';
          _nipController.text = data['nip'] ?? '';
          _ulpController.text = data['ulp'] ?? '';
          _phoneController.text = data['phone'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Error',
          message: 'Gagal load profil: $e',
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final user = supabase.auth.currentUser;
    if (user == null) {
      SnackBarUtils.showError(
        context,
        title: 'Error',
        message: 'User belum login',
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final profileData = {
      'id': user.id,
      'full_name': _fullNameController.text,
      'nip': _nipController.text,
      'ulp': _ulpController.text,
      'phone': _phoneController.text,
      'email': user.email,
    };

    try {
      if (_profileId == null) {
        // Insert new profile
        await supabase.from('profiles').insert(profileData);
        _profileId = user.id;
      } else {
        // Update existing profile
        await supabase.from('profiles').update(profileData).eq('id', user.id);
      }

      if (mounted) {
        SnackBarUtils.showSuccess(
          context,
          title: 'Berhasil',
          message: 'Profil berhasil disimpan',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(
          context,
          title: 'Error',
          message: 'Gagal simpan profil: $e',
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nipController.dispose();
    _ulpController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Background hitam gelap
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
              : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Avatar dengan glow effect
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Dark theme text fields
                          _buildDarkTextField(
                            controller: _fullNameController,
                            label: 'Nama',
                            icon: Icons.person_outline,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Nama lengkap wajib diisi'
                                        : null,
                          ),
                          const SizedBox(height: 20),

                          _buildDarkTextField(
                            controller: _nipController,
                            label: 'NIP',
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 20),

                          _buildDarkTextField(
                            controller: _ulpController,
                            label: 'ULP',
                            icon: Icons.business_outlined,
                          ),
                          const SizedBox(height: 20),

                          _buildDarkTextField(
                            controller: _phoneController,
                            label: 'Nomor HP',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 40),

                          // Dark theme button
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1E3A8A), // Blue-900
                                  Color(0xFF3B82F6), // Blue-500
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Simpan Profil',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  // Method untuk dark theme text field
  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark grey background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A), // Subtle border
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          color: Colors.white, // White text
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF9CA3AF), // Grey-400 for label
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2), // Blue tint
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          errorStyle: const TextStyle(color: Colors.red),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
