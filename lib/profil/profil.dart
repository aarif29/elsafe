import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/snackbar.dart';
import '../config/ulp_service.dart';
import '../config/ulp_list.dart';
import '../config/app_theme.dart';
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
    final isDarkMode = context.isDark;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final surface = context.surfaceColor;
    final primaryColor = isDarkMode ? Colors.blue : const Color(0xFF1E88E5);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: surface,
          title: Text('Minta Ganti ULP', style: TextStyle(color: textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ULP saat ini: ${_currentUlp ?? "-"}',
                style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'ULP Baru',
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: textSecondary),
                ),
                dropdownColor: surface,
                items: daftarUlp
                    .where((u) => u != _currentUlp)
                    .map((u) => DropdownMenuItem(value: u, child: Text(u, style: TextStyle(color: textPrimary))))
                    .toList(),
                onChanged: (v) => setDlgState(() => ulpBaru = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: alasanController,
                style: TextStyle(color: textPrimary),
                decoration: InputDecoration(
                  labelText: 'Alasan (opsional)',
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: textSecondary),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal', style: TextStyle(color: textSecondary)),
            ),
            ElevatedButton(
              onPressed: ulpBaru != null ? () => Navigator.pop(ctx, true) : null,
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Kirim Permintaan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirm != true || ulpBaru == null || !mounted) return;

    setState(() => _isLoading = true);
    final result = await _ulpService.requestGantiUlp(
      ulpBaru!,
      alasan: alasanController.text.trim().isEmpty ? null : alasanController.text.trim(),
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
    final bg = context.bgColor;
    final surface = context.surfaceColor;
    final border = context.borderColor;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final isDarkMode = context.isDark;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(color: textPrimary)),
        centerTitle: true,
        backgroundColor: surface,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: isDarkMode ? Colors.blue : const Color(0xFF1E88E5)),
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
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isDarkMode ? Colors.blue : const Color(0xFF1E88E5)).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: isDarkMode ? Colors.blue : const Color(0xFF1E88E5),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        _buildTextField(
                          controller: _fullNameController,
                          label: 'Nama',
                          icon: Icons.person_outline,
                          validator: (value) => value == null || value.isEmpty ? 'Nama lengkap wajib diisi' : null,
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _nipController,
                          label: 'NIP',
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 20),

                        _buildUlpRow(isDarkMode: isDarkMode, surface: surface, border: border, textPrimary: textPrimary, textSecondary: textSecondary),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _phoneController,
                          label: 'Nomor HP',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 40),

                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: isDarkMode
                                  ? const [Color(0xFF1E3A8A), Color(0xFF3B82F6)]
                                  : const [Color(0xFF1E88E5), Color(0xFF1565C0)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDarkMode ? Colors.blue : const Color(0xFF1E88E5)).withValues(alpha: 0.3),
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

Widget _buildUlpRow({required bool isDarkMode, required Color surface, required Color border, required Color textPrimary, required Color textSecondary}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDarkMode ? Colors.blue : const Color(0xFF1E88E5)).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business_outlined,
                  color: isDarkMode ? Colors.blue : const Color(0xFF1E88E5),
                  size: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ULP',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _currentUlp ?? 'Belum disetel',
                          style: TextStyle(
                            color: _currentUlp != null ? textPrimary : Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_currentRole == 'admin') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
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
              Icon(
                Icons.lock_outline,
                color: textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

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
              foregroundColor: isDarkMode ? Colors.blue : const Color(0xFF1E88E5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),

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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDarkMode = context.isDark;
    final surface = context.surfaceColor;
    final inputFill = context.inputFillColor;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;
    final border = context.borderColor;
    final primaryColor = isDarkMode ? Colors.blue : const Color(0xFF1E88E5);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 2)),
          errorStyle: const TextStyle(color: Colors.red),
          filled: true,
          fillColor: inputFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
),
      ),
    );
  }
}
