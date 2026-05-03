import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/snackbar.dart';
import '../config/ulp_service.dart';
import '../config/ulp_list.dart';
import '../Screen/admin/admin_approval_screen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nipController = TextEditingController();
  final _phoneController = TextEditingController();
  final supabase = Supabase.instance.client;
  final _ulpService = UlpService();

  bool _isLoading = false;
  String? _profileId;
  String? _currentUlp;
  String? _currentRole;
  bool _hasPendingUlpRequest = false;

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
        final hasPending = await _ulpService.hasPendingRequest();
        setState(() {
          _profileId = data['id'] as String?;
          _fullNameController.text = data['full_name'] ?? '';
          _nipController.text = data['nip'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _currentUlp = data['ulp'] as String?;
          _currentRole = data['role'] as String?;
          _hasPendingUlpRequest = hasPending;
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
      'phone': _phoneController.text,
      'email': user.email,
      // ulp tidak disimpan langsung — harus melalui approval admin
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

  Future<void> _showGantiUlpDialog() async {
    String? ulpBaru;
    final alasanController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setDlgState) => AlertDialog(
                  title: const Text('Minta Ganti ULP'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ULP saat ini: ${_currentUlp ?? "-"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'ULP Baru',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            daftarUlp
                                .where((u) => u != _currentUlp)
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setDlgState(() => ulpBaru = v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: alasanController,
                        decoration: const InputDecoration(
                          labelText: 'Alasan (opsional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed:
                          ulpBaru != null
                              ? () => Navigator.pop(ctx, true)
                              : null,
                      child: const Text(
                        'Kirim Permintaan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );

    if (confirm != true || ulpBaru == null || !mounted) return;

    setState(() => _isLoading = true);
    final result = await _ulpService.requestGantiUlp(
      ulpBaru!,
      alasan:
          alasanController.text.trim().isEmpty
              ? null
              : alasanController.text.trim(),
    );
    alasanController.dispose();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success'] == true) _hasPendingUlpRequest = true;
    });

    if (result['success'] == true) {
      SnackBarUtils.showSuccess(
        context,
        title: 'Berhasil',
        message: result['message'],
      );
    } else {
      SnackBarUtils.showError(
        context,
        title: 'Gagal',
        message: result['message'],
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nipController.dispose();
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

                          // ULP (read-only)
                          _buildUlpRow(),
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

  Widget _buildUlpRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Info ULP (read-only display)
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ULP',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _currentUlp ?? 'Belum disetel',
                          style: TextStyle(
                            color:
                                _currentUlp != null
                                    ? Colors.white
                                    : Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_currentRole == 'admin') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.purple.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.lock_outline,
                color: Color(0xFF4B5563),
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Tombol ganti ULP / status pending
        if (_hasPendingUlpRequest)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.hourglass_empty,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Permintaan ganti ULP sedang menunggu persetujuan admin',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              ],
            ),
          )
        else if (_currentRole != 'admin')
          TextButton.icon(
            onPressed: _showGantiUlpDialog,
            icon: const Icon(Icons.edit, size: 14),
            label: const Text('Minta Ganti ULP'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),

        // Tombol Admin: kelola persetujuan
        if (_currentRole == 'admin') ...[
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminApprovalScreen()),
              );
            },
            icon: const Icon(Icons.admin_panel_settings, size: 16),
            label: const Text('Kelola Persetujuan ULP'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.purple,
              side: const BorderSide(color: Colors.purple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ],
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
