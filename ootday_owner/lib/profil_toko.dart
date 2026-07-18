import 'package:flutter/material.dart';
import 'package:ootday_owner/widgets/owner_bottom_nav.dart';
import 'home_page.dart';
import 'profil_kategori.dart';
import 'profil_produk_tab.dart';
import 'services/auth_service.dart';
import 'services/auth_user_display.dart';
import 'services/profile_photo_service.dart';
import 'setting.dart';

class ProfilToko extends StatefulWidget {
  const ProfilToko({super.key});

  @override
  State<ProfilToko> createState() => _ProfilTokoState();
}

class _ProfilTokoState extends State<ProfilToko>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUpdatingPhoto = false;

  static const Color _redMain = Color(0xFFB40001);
  static const Color _darkRed = Color(0xFF7A0000);
  static const Color _greyBg = Color(0xFFF2F2F2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshUserProfile() async {
    try {
      await AuthService().restoreSession();
    } catch (_) {
      // Kalau gagal refresh dari server, tetap pakai data lokal yang ada.
    }
    if (mounted) setState(() {});
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Future<void> _editProfilePhoto() async {
    if (_isUpdatingPhoto) return;
    setState(() => _isUpdatingPhoto = true);
    try {
      final photoUrl = await ProfilePhotoService.pickAndUpdatePhoto();
      if (mounted && photoUrl != null) {
        setState(() {});
        _showSnack('Foto toko berhasil diperbarui');
      }
    } catch (e) {
      _showSnack('Gagal memperbarui foto: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUpdatingPhoto = false);
    }
  }

  Future<void> _confirmDeleteProfilePhoto() async {
    if (_isUpdatingPhoto) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus foto profil?'),
        content: const Text(
          'Foto profil akan dihapus dari akun Anda. Anda bisa mengunggah foto baru kapan saja.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: _redMain)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isUpdatingPhoto = true);
    try {
      await ProfilePhotoService.removePhoto();
      if (mounted) {
        setState(() {});
        _showSnack('Foto toko berhasil dihapus');
      }
    } catch (e) {
      _showSnack('Gagal menghapus foto: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUpdatingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greyBg,
      bottomNavigationBar: const OwnerBottomNav(currentIndex: 3),
      body: Column(
        children: [
          _header(context),
          _tabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _tokoTab(),
                const ProfilProdukTab(),
                const ProfilKategori(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_redMain, _darkRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomePage(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Profil Toko',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: AuthState.instance,
                builder: (context, _) {
                  final user = AuthState.instance.user;
                  final displayName = AuthUserDisplay.name(user);
                  final photoUrl = AuthUserDisplay.photoUrl(user);
                  final email = user?['email'] as String?;

                  return Column(
                    children: [
                      _profileAvatar(photoUrl),
                      const SizedBox(height: 14),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (email != null && email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _ratingChip(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ratingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 6),
          Text(
            '4.8',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 1,
            height: 14,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          Text(
            'Pemilik Toko',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileAvatar(String? photoUrl) {
    const double size = 96;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                color: Colors.white,
                child: photoUrl != null
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                      )
                    : _avatarPlaceholder(),
              ),
            ),
          ),
          if (_isUpdatingPhoto)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _profilePhotoActionButton(
              icon: Icons.camera_alt_rounded,
              tooltip: 'Ubah foto profil',
              onTap: _isUpdatingPhoto ? null : _editProfilePhoto,
            ),
          ),
          if (photoUrl != null)
            Positioned(
              left: 0,
              top: 0,
              child: _profilePhotoActionButton(
                icon: Icons.delete_outline_rounded,
                tooltip: 'Hapus foto profil',
                onTap: _isUpdatingPhoto ? null : _confirmDeleteProfilePhoto,
                isDestructive: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Center(
      child: Icon(Icons.person_rounded, size: 52, color: _redMain),
    );
  }

  Widget _profilePhotoActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: isDestructive ? Colors.red.shade50 : Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(
              icon,
              size: 16,
              color: isDestructive ? Colors.red.shade700 : _redMain,
            ),
          ),
        ),
      ),
    );
  }

  // ================= TAB BAR =================
  Widget _tabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        dividerHeight: 0,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: _redMain,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Toko'),
          Tab(text: 'Produk'),
          Tab(text: 'Kategori'),
        ],
      ),
    );
  }

  // ================= TOKO TAB =================
  Widget _tokoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _storeCard(),
          const SizedBox(height: 16),
          const Text(
            'Statistik Toko',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniStatCard(
                  icon: Icons.star_rounded,
                  label: 'Rating',
                  value: '4.8',
                  color: Colors.amber.shade700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniStatCard(
                  icon: Icons.people_outline_rounded,
                  label: 'Pengikut',
                  value: '395',
                  color: _redMain,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniStatCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Produk',
                  value: '24',
                  color: _darkRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _storeCard() {
    final store = AuthState.instance.user?['store'] as Map<String, dynamic>?;
    final storeName = (store?['store_name'] as String?)?.trim();
    final description = (store?['description'] as String?)?.trim();
    final photoUrl = (store?['photo_url'] as String?)?.trim();
    final status = (store?['status'] as String?)?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _greyBg,
              shape: BoxShape.circle,
              border: Border.all(color: _redMain.withValues(alpha: 0.2)),
            ),
            child: ClipOval(
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _storeLogoFallback(),
                    )
                  : _storeLogoFallback(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName != null && storeName.isNotEmpty
                      ? storeName
                      : 'Toko Anda',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description != null && description.isNotEmpty
                      ? description
                      : 'Belum ada deskripsi toko',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _storeBadge(
                      Icons.verified_outlined,
                      status == 'active' ? 'Terverifikasi' : 'Menunggu Review',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeLogoFallback() {
    return Image.asset(
      'assets/logo.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_rounded, color: _redMain, size: 32),
          const SizedBox(height: 4),
          Text(
            'Ootday',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _redMain,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _redMain.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _redMain),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _redMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
