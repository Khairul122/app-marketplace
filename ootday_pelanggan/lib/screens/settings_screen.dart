import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'security_screen.dart';
import 'chat_list_screen.dart';
import 'address_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color headerBg = Color(0xFFE5DADA); // Abu-abu kecoklatan sesuai gambar

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
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
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // SECTION: AKUN SAYA
                  _buildSectionHeader('Akun Saya', headerBg),
                  _buildSettingTile(
                    'Keamanan', 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityScreen())),
                  ),
                  _buildSettingTile(
                    'Alamat Saya',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressScreen())),
                  ),
                  _buildSettingTile('Kartu / Rekening Bank'),

                  // SECTION: PENGATURAN
                  _buildSectionHeader('Pengaturan', headerBg),
                  _buildSettingTile('Pengaturan Notifikasi'),
                  _buildSettingTile('Pengaturan Privasi'),
                  _buildSettingTile('Pengaturan Chat'),
                  _buildSettingTile('Bahasa / Language', subtitle: 'Bahasa Indonesia'),

                  // SECTION: BANTUAN
                  _buildSectionHeader('Bantuan', headerBg),
                  _buildSettingTile('Help Center'),
                  _buildSettingTile('Peraturan Komunitas'),
                  _buildSettingTile('Hapus Akun', showArrow: false),
                ],
              ),
            ),
            
            // SIMPAN BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: bgColor,
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, {String? subtitle, bool showArrow = true, VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          title: Text(
            title,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
          ),
          subtitle: subtitle != null 
            ? Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey))
            : null,
          trailing: showArrow 
            ? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54)
            : null,
          onTap: onTap ?? () {},
        ),
        const Divider(height: 1, indent: 20, endIndent: 20, color: Colors.black12),
      ],
    );
  }
}
