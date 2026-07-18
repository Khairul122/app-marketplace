import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'notification_screen.dart';
import 'search_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'chat_list_screen.dart';
import 'login_screen.dart';
import 'my_orders_screen.dart';
import '../utils/order_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _activeOrderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOrderCount();
  }

  Future<void> _loadOrderCount() async {
    final orders = await OrderData.getActiveOrders();
    if (mounted) {
      setState(() {
        _activeOrderCount = orders.length;
      });
    }
  }

  void _handleLogout(BuildContext context) async {
    final AuthService authService = AuthService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin keluar dari akun?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Color(0xFF5D1A1A), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;
    const Color maroonColor = Color(0xFF5D1A1A);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
              decoration: const BoxDecoration(color: maroonColor),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
                            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 26),
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    child: const Text('3', style: TextStyle(color: Color(0xFF5D1A1A), fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
                            child: Image.asset('assets/images/icons msg.png', width: 26, height: 26, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/images/profile.png'),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (user?['name'] as String?) ?? (user?['email'] as String?) ?? 'Tamu',
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
                              child: Text('Edit Profil', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Pesanan saya', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen())),
                                child: Row(
                                  children: [
                                    Text('Lihat Riwayat Pesanan ', style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                                    const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.black54),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen(initialTabIndex: 0))),
                                child: _buildOrderItem(Icons.account_balance_wallet_outlined, 'Belum Bayar'),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen(initialTabIndex: 1))),
                                child: _buildOrderItem(Icons.inventory_2_outlined, 'Dikemas', badgeCount: _activeOrderCount),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen(initialTabIndex: 2))),
                                child: _buildOrderItem(Icons.local_shipping_outlined, 'Dikirim'),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen(initialTabIndex: 3))),
                                child: _buildOrderItem(Icons.star_outline, 'Penilaian'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Dompet', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: maroonColor)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
                            child: Text('Wishlist', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: maroonColor)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1, height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(15)),
                        child: Text('Help Center', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: maroonColor)),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => _handleLogout(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(30)),
                          child: Center(
                            child: Text('Logout', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: maroonColor)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 70,
          decoration: const BoxDecoration(color: maroonColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                child: Icon(Icons.home_outlined, color: Colors.white.withOpacity(0.5), size: 28),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
                child: Icon(Icons.search, color: Colors.white.withOpacity(0.5), size: 28),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
                child: Icon(Icons.notifications_none, color: Colors.white.withOpacity(0.5), size: 28),
              ),
              const Icon(Icons.person, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(IconData icon, String label, {int badgeCount = 0}) {
    return Column(
      children: [
        Stack(
          children: [
            Icon(icon, color: const Color(0xFF5D1A1A), size: 30),
            if (badgeCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
