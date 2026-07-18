import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/auth_user_display.dart';
import 'pengaturan_akun.dart';
import 'informasi_toko.dart';
import 'help_center.dart';
import 'hapus_akun.dart';
import 'logout.dart';
import 'pengaturan_komunikasi.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  final Color redMain = const Color(0xFF5D1A1A);
  final Color darkRed = const Color(0xFF7A0000);

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
                  // ================= PENGATURAN TOKO =================
                  const Text(
                    'Pengaturan Toko',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _settingItem(
                    context: context,
                    title: 'Pengaturan Akun',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PengaturanAkun(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _settingItem(
                    context: context,
                    title: 'Informasi Toko',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InformasiToko(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // ================= MENU LAINNYA =================
                  _settingItem(
                    context: context,
                    title: 'Help Center',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpCenter(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _settingItem(
                    context: context,
                    title: 'Peraturan Komunikasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PengaturanKomunikasi(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _settingItem(
                    context: context,
                    title: 'Hapus Akun',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HapusAkun(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // ================= BUTTON KELUAR =================
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LogoutPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: redMain,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
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
                  'Setting',
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
          AnimatedBuilder(
            animation: AuthState.instance,
            builder: (context, _) {
              final user = AuthState.instance.user;
              final displayName = AuthUserDisplay.name(user);
              final photoUrl = AuthUserDisplay.photoUrl(user);

              return Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      image: photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(photoUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: photoUrl == null
                        ? Center(
                            child: Icon(
                              Icons.person_outline,
                              size: 52,
                              color: redMain,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= SETTING ITEM =================
  Widget _settingItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: redMain,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: redMain,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
