import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ootday_pelanggan/screens/cart_screen.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'my_orders_screen.dart';
import 'product_detail_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  final ApiService _api = ApiService();
  List<Map<String, String>> _recommendations = [];
  bool _isLoadingRecs = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final result = await _api.get('/products');
      final List rawList = (result is Map && result['data'] is List) ? result['data'] : result;
      final items = List<Map<String, dynamic>>.from(rawList).take(8).map((p) {
        String imagePath = 'assets/images/kemeja_wanita/1.jpeg';
        final images = p['images'];
        if (images is List && images.isNotEmpty) {
          final primary = images.firstWhere(
            (img) => img is Map && img['is_primary'] == true,
            orElse: () => images.first,
          );
          if (primary is Map && primary['image_url'] != null) {
            imagePath = primary['image_url'].toString();
          }
        }
        return {
          'id': (p['id'] ?? '').toString(),
          'name': (p['name'] ?? '').toString(),
          'price': (num.tryParse((p['price'] ?? 0).toString()) ?? 0).toStringAsFixed(0),
          'image': imagePath,
          'sold': '${p['sold_count'] ?? 0} terjual',
        };
      }).toList();

      if (mounted) {
        setState(() {
          _recommendations = items;
          _isLoadingRecs = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _recommendations = [];
          _isLoadingRecs = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    final List<Map<String, String>> recommendations = _recommendations;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Maroon Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
                decoration: const BoxDecoration(
                  color: maroonColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
                          child: Stack(
                            children: [
                              const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                  child: const Text('3', style: TextStyle(color: maroonColor, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Hore, Pesananmu Berhasil!',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Tunggu pesananmu terkirim dan bayar setelah pesanan tiba. Cek "Pesanan Saya" untuk lihat detailnya.',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeaderButton('Beranda', () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                        }),
                        const SizedBox(width: 15),
                        _buildHeaderButton('Pesanan Saya', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen(initialTabIndex: 1)));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 2. Recommendations Grid
              Padding(
                padding: const EdgeInsets.all(20),
                child: _isLoadingRecs
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : recommendations.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Center(
                              child: Text('Belum ada rekomendasi produk', style: GoogleFonts.outfit(color: Colors.black54)),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                            itemCount: recommendations.length,
                            itemBuilder: (context, index) {
                              final item = recommendations[index];
                              return _buildProductCard(context, item);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      ),
      child: Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, String> product) {
    final priceNum = int.tryParse(product['price'] ?? '0') ?? 0;
    String formattedPrice = 'Rp ${priceNum.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    final String image = product['image'] ?? '';
    final bool isNetworkImage = image.startsWith('http');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: isNetworkImage
                    ? Image.network(
                        image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported_outlined)),
                      )
                    : Image.asset(image, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'] ?? '', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(formattedPrice, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF5D1A1A))),
                  const SizedBox(height: 5),
                  Text(product['sold'] ?? '', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
