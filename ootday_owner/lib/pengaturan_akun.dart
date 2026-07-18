import 'package:flutter/material.dart';

import 'services/auth_service.dart';

class PengaturanAkun extends StatefulWidget {
  const PengaturanAkun({super.key});

  @override
  State<PengaturanAkun> createState() => _PengaturanAkunState();
}

class _PengaturanAkunState extends State<PengaturanAkun> {
  final Color redMain = const Color(0xFF5D1A1A);
  final Color darkRed = const Color(0xFF7A0000);

  final AuthService _authService = AuthService();

  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController(text: '........');

  final bool _obscurePassword = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = AuthState.instance.user;
    _namaController = TextEditingController(text: user?['name']?.toString() ?? '');
    _emailController = TextEditingController(text: user?['email']?.toString() ?? '');
    _phoneController = TextEditingController(text: user?['phone']?.toString() ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _openChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool submitting = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Ganti Kata Sandi'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Kata sandi saat ini'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Kata sandi baru'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Konfirmasi kata sandi baru'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: submitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: redMain),
                  onPressed: submitting
                      ? null
                      : () async {
                          if (newController.text != confirmController.text) {
                            _showSnack('Konfirmasi kata sandi tidak cocok.', isError: true);
                            return;
                          }
                          if (newController.text.isEmpty || currentController.text.isEmpty) {
                            _showSnack('Lengkapi semua kolom kata sandi.', isError: true);
                            return;
                          }
                          setDialogState(() => submitting = true);
                          try {
                            await _authService.changePassword(
                              currentController.text,
                              newController.text,
                            );
                            if (dialogContext.mounted) Navigator.pop(dialogContext);
                            _showSnack('Kata sandi berhasil diubah.');
                          } on AuthException catch (e) {
                            setDialogState(() => submitting = false);
                            _showSnack(e.message, isError: true);
                          } catch (_) {
                            setDialogState(() => submitting = false);
                            _showSnack('Gagal mengubah kata sandi.', isError: true);
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _saving = true);
    try {
      await _authService.updateProfile(
        name: _namaController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      _showSnack('Perubahan berhasil disimpan');
    } on AuthException catch (e) {
      _showSnack(e.message, isError: true);
    } catch (_) {
      _showSnack('Gagal menyimpan perubahan.', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _inputField(
                    label: 'Nama Lengkap',
                    controller: _namaController,
                  ),
                  const SizedBox(height: 16),
                  _inputField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  _inputField(
                    label: 'Nomor Telepon',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _passwordField(),
                ],
              ),
            ),
          ),
          _saveButton(),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [redMain, darkRed],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pengaturan Akun',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: redMain,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person_outline,
                size: 60,
                color: redMain,
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: AuthState.instance,
            builder: (context, _) {
              final name = AuthState.instance.user?['name']?.toString() ?? '-';
              return Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= INPUT FIELD =================
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: redMain,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            style: TextStyle(
              fontSize: 16,
              color: enabled ? Colors.black87 : Colors.grey,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // ================= PASSWORD FIELD =================
  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kata Sandi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: redMain,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextButton(
                onPressed: _openChangePasswordDialog,
                child: Text(
                  'Ubah',
                  style: TextStyle(
                    color: redMain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= SAVE BUTTON =================
  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _saving ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: redMain,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: redMain, width: 1),
            ),
            elevation: 0,
          ),
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

