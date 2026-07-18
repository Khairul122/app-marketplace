import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ootday_owner/login.dart';
import 'package:ootday_owner/services/auth_service.dart';

class DaftarPage extends StatefulWidget {
  const DaftarPage({super.key});

  @override
  State<DaftarPage> createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  static const Color maroonColor = Color(0xFF5D1A1A);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureRePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _storeNameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit()),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: maroonColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.tick_circle,
                    size: 52,
                    color: maroonColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Registrasi Berhasil!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: maroonColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Akun owner Anda sudah siap. Masuk untuk mulai mengelola toko dan produk di Ootday.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: maroonColor.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Masuk Sekarang',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> register() async {
    final name = _nameController.text.trim();
    final storeName = _storeNameController.text.trim();
    final phone = _numberController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final rePassword = _rePasswordController.text.trim();

    if (name.isEmpty ||
        storeName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        rePassword.isEmpty) {
      _showMessage('Semua field wajib diisi');
      return;
    }

    if (password != rePassword) {
      _showMessage('Password tidak cocok!');
      return;
    }

    if (password.length < 8) {
      _showMessage('Password minimal 8 karakter');
      return;
    }

    try {
      setState(() => isLoading = true);

      await _authService.register(
        name: name,
        email: email,
        password: password,
        storeName: storeName,
        phone: phone,
      );

      if (!mounted) return;
      setState(() => isLoading = false);
      _showSuccessDialog();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage(e.message, backgroundColor: Colors.red);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('$e', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                IconButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Iconsax.arrow_left_2,
                    color: maroonColor,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Buat Akun Owner',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: maroonColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lengkapi data di bawah ini untuk membuka dan mengelola toko Anda di Ootday.',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: maroonColor.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                _buildInputField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap Anda',
                  icon: Iconsax.user,
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Nama Toko',
                  hint: 'Masukkan nama toko Anda',
                  icon: Iconsax.shop,
                  controller: _storeNameController,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Email',
                  hint: 'Alamat email aktif',
                  icon: Iconsax.sms,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Nomor HP',
                  hint: 'Contoh: 08123456789',
                  icon: Iconsax.call,
                  keyboardType: TextInputType.phone,
                  controller: _numberController,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Password',
                  hint: 'Masukkan password',
                  icon: Iconsax.lock,
                  isPassword: true,
                  isObscured: _obscurePassword,
                  controller: _passwordController,
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password',
                  icon: Iconsax.lock,
                  isPassword: true,
                  isObscured: _obscureRePassword,
                  controller: _rePasswordController,
                  onToggleVisibility: () {
                    setState(() => _obscureRePassword = !_obscureRePassword);
                  },
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroonColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          maroonColor.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Daftar Sekarang',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: GoogleFonts.outfit(
                        color: maroonColor.withValues(alpha: 0.6),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Masuk di sini',
                        style: GoogleFonts.outfit(
                          color: maroonColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    TextEditingController? controller,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: maroonColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscured,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: GoogleFonts.outfit(color: maroonColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              color: maroonColor.withValues(alpha: 0.3),
            ),
            prefixIcon: Icon(
              icon,
              color: maroonColor.withValues(alpha: 0.5),
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isObscured ? Iconsax.eye_slash : Iconsax.eye,
                      color: maroonColor.withValues(alpha: 0.5),
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.withValues(alpha: 0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: maroonColor.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

}
