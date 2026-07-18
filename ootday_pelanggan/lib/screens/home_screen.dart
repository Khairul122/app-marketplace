import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'search_screen.dart';
import 'chat_list_screen.dart';
import 'search_result_screen.dart';
import 'cart_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/cart_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _errorMsg = '';
  int _cartCount = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Dress in Style\n&\nSave More',
      'subtitle': 'Trendy fashion, best deals!',
      'color': const Color(0xFF5D1A1A),
      'image': 'assets/images/iklan.png',
    },
    {
      'title': 'Special Offer\nDiskon 50%',
      'subtitle': 'Koleksi Terbaru!',
      'color': const Color(0xFF7F0909),
      'image': 'assets/images/Iklan_2.png', 
    },
    {
      'title': 'New Arrival\nTrending Now',
      'subtitle': 'Cek koleksinya sekarang',
      'color': const Color(0xFF4A1414),
      'image': 'assets/images/iklan_3.png',
    },
    {
      'title': 'Voucher Belanja\nHingga 100rb',
      'subtitle': 'Klaim sekarang juga!',
      'color': const Color(0xFF3E0D0D),
      'image': 'assets/images/iklan_4.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() { _isLoading = true; _errorMsg = ''; });
    try {
      final catResult = await _api.get('/categories');
      final prodResult = await _api.get('/products');
      int count = 0;
      try {
        final cartItems = await CartData.getCartItems();
        count = cartItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
      } catch (e) {
        print('Error fetching cart count: $e');
      }

      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(catResult is List ? catResult : []);
          _products = List<Map<String, dynamic>>.from(prodResult is List ? prodResult : []);
          _cartCount = count;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      print('Error fetching data via HTTP API: ${e.message}');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = e.message;
        });
      }
    } catch (e) {
      print('Error fetching data via HTTP API: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Gagal memuat data. Periksa koneksi jaringan.';
        });
      }
    }
  }

  Future<void> _refreshCartCount() async {
    try {
      final cartItems = await CartData.getCartItems();
      final count = cartItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
      if (mounted) {
        setState(() {
          _cartCount = count;
        });
      }
    } catch (e) {
      print('Error refreshing cart count: $e');
    }
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        if (_currentBanner < _banners.length - 1) {
          _currentBanner++;
        } else {
          _currentBanner = 0;
        }
        _bannerController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color bgColor = Color(0xFFEEE4E4);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  color: bgColor,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())).then((_) => _refreshCartCount()),
                              child: Container(
                                height: 45,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: maroonColor.withOpacity(0.5), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text('search', style: GoogleFonts.outfit(color: maroonColor.withOpacity(0.5)))),
                                    Icon(Icons.photo_camera_outlined, color: maroonColor.withOpacity(0.5), size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                           GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())).then((_) => _refreshCartCount()),
                            child: Stack(
                              children: [
                                const Icon(Icons.shopping_cart_outlined, color: maroonColor, size: 28),
                                if (_cartCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(color: maroonColor, shape: BoxShape.circle),
                                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                      child: Text(
                                        '$_cartCount',
                                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
                            child: Image.asset('assets/images/icons msg.png', width: 28, height: 28, color: maroonColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi, ${user?['name'] ?? user?['email'] ?? 'Pelanggan Ootday'}',
                                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: maroonColor),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text('Selamat datang di Ootday', style: GoogleFonts.outfit(fontSize: 14, color: maroonColor.withOpacity(0.7))),
                              ],
                            ),
                          ),
                          const CircleAvatar(radius: 35, backgroundColor: Colors.white, child: CircleAvatar(radius: 32, backgroundImage: AssetImage('assets/images/profile.png'))),
                        ],
                      ),
                    ],
                  ),
                ),

                // AUTO SCROLL BANNER SECTION
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (index) => setState(() => _currentBanner = index),
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      final banner = _banners[index];
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: banner['color'],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      banner['title'],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(15)),
                                      child: Text(banner['subtitle'], style: GoogleFonts.outfit(color: banner['color'], fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 10, bottom: 0, top: 0,
                                child: Image.asset(banner['image'], fit: BoxFit.contain),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // BANNER INDICATOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _banners.asMap().entries.map((entry) {
                    return Container(
                      width: _currentBanner == entry.key ? 20 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentBanner == entry.key ? maroonColor : Colors.grey[300],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 15),
                // Categories Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kategori', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: maroonColor)),
                      const SizedBox(height: 15),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _errorMsg.isNotEmpty
                              ? Center(
                                  child: Column(
                                    children: [
                                      Text(_errorMsg, style: const TextStyle(color: Colors.red)),
                                      TextButton(onPressed: _fetchData, child: const Text('Coba Lagi'))
                                    ],
                                  ),
                                )
                          : _categories.isEmpty
                              ? const Center(child: Text('Kategori tidak tersedia'))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: _categories.map((cat) {
                                    return _buildCategoryItem(
                                      context,
                                      cat['name'] ?? '',
                                      cat['icon_url'] != null
                                          ? CartData.resolveImageUrl(cat['icon_url'] as String?)
                                          : 'assets/images/wanita_icons.png',
                                      const Color(0xFF7F0909),
                                    );
                                  }).toList(),
                                ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Popular Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Populer', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: maroonColor)),
                      const SizedBox(height: 15),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _products.isEmpty
                              ? const Center(child: Text('Tidak ada produk populer'))
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.75),
                                  itemCount: _products.length,
                                  itemBuilder: (context, index) => _buildProductItem(index),
                                ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 70,
          decoration: const BoxDecoration(color: maroonColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                child: const Icon(Icons.home, color: Colors.white, size: 28),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())).then((_) => _refreshCartCount()), 
                child: Icon(Icons.search, color: Colors.white.withOpacity(0.5), size: 28)
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())).then((_) => _refreshCartCount()),
                child: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())).then((_) => _refreshCartCount()),
                child: Icon(Icons.person_outline, color: Colors.white.withOpacity(0.5), size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, String imagePath, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SearchResultScreen(searchQuery: label))).then((_) => _refreshCartCount()),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: imagePath.startsWith('http')
                ? Image.network(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/images/wanita_icons.png', fit: BoxFit.contain),
                  )
                : Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/images/wanita_icons.png', fit: BoxFit.contain),
                  ),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  ImageProvider _imageProvider(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  /// Response `/products` sekarang punya `images:[{image_url,is_primary}]`
  /// (bukan flat `image_url`) dan `description`/`stock` sudah di level
  /// produk (bukan lagi field yang dulu tidak dikirim endpoint lama).
  String _primaryProductImage(Map<String, dynamic> product) {
    final images = product['images'] as List? ?? [];
    if (images.isEmpty) return CartData.resolveImageUrl(null);
    final primary = images.firstWhere(
      (img) => img['is_primary'] == true,
      orElse: () => images.first,
    );
    return CartData.resolveImageUrl(primary['image_url'] as String?);
  }

  Widget _buildProductItem(int index) {
    final product = _products[index];
    final String imageUrl = _primaryProductImage(product);
    final String priceStr = product['price'].toString().replaceAll(RegExp(r'\.0+$'), '');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProductDetailScreen(product: {
          'id': product['id'].toString(),
          'name': product['name'] ?? '',
          'price': priceStr,
          'image': imageUrl,
          'description': product['description'] ?? '',
          'stock': product['stock']?.toString() ?? '0',
        })),
      ).then((_) => _refreshCartCount()),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(image: _imageProvider(imageUrl), fit: BoxFit.cover)
            )
          ),
          Positioned(
            top: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), 
              decoration: BoxDecoration(
                color: const Color(0xFFE5989B).withOpacity(0.8), 
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), topRight: Radius.circular(10))
              ), 
              child: Text(index % 2 == 0 ? '-50%' : '-60%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
            ),
          ),
        ],
      ),
    );
  }
}
