import 'package:flutter/material.dart';
import 'package:ootday_owner/home_page.dart';
import 'package:ootday_owner/notifikasi.dart';
import 'package:ootday_owner/profil_toko.dart';
import 'package:ootday_owner/search_page.dart';
import 'package:ootday_owner/tambah_produk_page.dart';

/// Navbar bawah owner dengan tombol tambah produk di tengah.
class OwnerBottomNav extends StatelessWidget {
  const OwnerBottomNav({
    super.key,
    this.currentIndex = 0,
  });

  /// 0 = Home, 1 = Search, 2 = Notifikasi, 3 = Profil
  final int currentIndex;

  static const Color navRed = Color(0xFF8A0000);

  void _goHome(BuildContext context) {
    if (currentIndex == 0) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  void _goSearch(BuildContext context) {
    if (currentIndex == 1) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
  }

  void _goNotifikasi(BuildContext context) {
    if (currentIndex == 2) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotifikasiPage()),
    );
  }

  void _goProfil(BuildContext context) {
    if (currentIndex == 3) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilToko()),
    );
  }

  void _openTambahProduk(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahProdukPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 70,
            decoration: const BoxDecoration(
              color: navRed,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navIcon(
                  icon: currentIndex == 0 ? Icons.home : Icons.home_outlined,
                  active: currentIndex == 0,
                  onTap: () => _goHome(context),
                ),
                _navIcon(
                  icon: Icons.search,
                  active: currentIndex == 1,
                  onTap: () => _goSearch(context),
                ),
                const SizedBox(width: 56),
                _navIcon(
                  icon: currentIndex == 2
                      ? Icons.notifications
                      : Icons.notifications_outlined,
                  active: currentIndex == 2,
                  onTap: () => _goNotifikasi(context),
                  showDot: true,
                ),
                _navIcon(
                  icon: currentIndex == 3 ? Icons.person : Icons.person_outline,
                  active: currentIndex == 3,
                  onTap: () => _goProfil(context),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => _openTambahProduk(context),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: navRed,
                  size: 34,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIcon({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: active
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, color: Colors.white, size: 28),
                    if (showDot)
                      Positioned(
                        right: -1,
                        top: -1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  if (showDot)
                    Positioned(
                      right: -1,
                      top: -1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
