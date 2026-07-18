import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'chat_list_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ganti Password', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password saat ini'),
            ),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password baru'),
            ),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Konfirmasi password baru'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan', style: TextStyle(color: Color(0xFF5D1A1A))),
          ),
        ],
      ),
    );

    if (result != true) return;

    if (newController.text != confirmController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konfirmasi password tidak cocok')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.changePassword(currentController.text, newController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah')),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color headerBg = Color(0xFFD9D9D9);

    final user = AuthState.instance.user;
    final String userEmail = user?['email'] as String? ?? 'Tidak ada email';
    final String? phone = user?['phone'] as String?;

    String displayPhone = phone ?? 'Belum Ditambahkan';
    if (phone != null && phone.length > 4) {
      displayPhone = '${phone.substring(0, 4)}******${phone.substring(phone.length - 2)}';
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: headerBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: maroonColor),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Pengaturan Akun',
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
                child: Image.asset(
                  'assets/images/icons msg.png',
                  width: 26,
                  height: 26,
                  color: maroonColor,
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: maroonColor))
            : Column(
                children: [
                  const SizedBox(height: 10),
                  _buildSecurityTile(
                    'Atur Ulang Password',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
                    onTap: _showChangePasswordDialog,
                  ),
                  _buildSecurityTile(
                    'Alamat Email',
                    value: userEmail,
                    valueColor: Colors.blue.withOpacity(0.3),
                  ),
                  _buildSecurityTile('No. Telp', value: displayPhone),
                ],
              ),
      ),
    );
  }

  Widget _buildSecurityTile(String title, {Widget? trailing, String? value, Color? valueColor, VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          title: Text(
            title,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
          ),
          trailing: trailing ?? (value != null ? Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: valueColor ?? Colors.black26,
              decoration: valueColor != null ? TextDecoration.underline : null,
            ),
          ) : null),
          onTap: onTap ?? () {},
        ),
        const Divider(height: 1, indent: 20, endIndent: 20, color: Colors.black12),
      ],
    );
  }
}
