import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_list_screen.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';
import 'cancellation_details_screen.dart';
import 'order_details_screen.dart';
import '../utils/order_data.dart';

class MyOrdersScreen extends StatefulWidget {
  final int initialTabIndex;
  const MyOrdersScreen({super.key, this.initialTabIndex = 0});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allOrders = [];
  bool _isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: widget.initialTabIndex);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await OrderData.getActiveOrders();
    if (mounted) {
      setState(() {
        _allOrders = orders;
        _isLoadingOrders = false;
      });
    }
  }

  /// Mapping status enum backend (`menunggu_pembayaran, diproses, dikirim,
  /// selesai, dibatalkan`) ke tab yang sudah ada di UI ini. Tab
  /// "Pengembalian" tidak punya status setara di backend, jadi tetap kosong.
  List<Map<String, dynamic>> _ordersByStatus(String status) {
    return _allOrders.where((o) => o['status'] == status).toList();
  }

  List<Map<String, dynamic>> get _unpaidOrders => _ordersByStatus('menunggu_pembayaran');
  List<Map<String, dynamic>> get _processingOrders => _ordersByStatus('diproses');
  List<Map<String, dynamic>> get _shippedOrders => _ordersByStatus('dikirim');
  List<Map<String, dynamic>> get _completedOrders => _ordersByStatus('selesai');
  List<Map<String, dynamic>> get _cancelledOrders => _ordersByStatus('dibatalkan');

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFEFEFEF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: maroonColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Pesanan Saya',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
              child: const Icon(Icons.search, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
              child: Image.asset('assets/images/icons msg.png', width: 24, height: 24, color: maroonColor),
            ),
            const SizedBox(width: 20),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: maroonColor,
            labelColor: maroonColor,
            unselectedLabelColor: Colors.black54,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.outfit(fontSize: 14),
            tabs: [
              const Tab(text: 'Belum Bayar'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Diproses'),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: maroonColor, shape: BoxShape.circle),
                      child: Text(_processingOrders.length.toString(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const Tab(text: 'Dikirim'),
              const Tab(text: 'Selesai'),
              const Tab(text: 'Pengembalian'),
              const Tab(text: 'Dibatalkan'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOrderListView(_unpaidOrders, maroonColor),
            _buildOrderListView(_processingOrders, maroonColor, showEstimation: true),
            _buildOrderListView(_shippedOrders, maroonColor, showEstimation: true),
            _buildOrderListView(_completedOrders, maroonColor, showActionButtons: true),
            _buildEmptyOrdersView(maroonColor),
            _buildOrderListView(
              _cancelledOrders,
              maroonColor,
              showActionButtons: true,
              altButtonLabel: 'Rincian Pembatalan',
            ),
          ],
        ),
      ),
    );
  }

  static const Map<String, String> _statusLabels = {
    'menunggu_pembayaran': 'Menunggu Pembayaran',
    'diproses': 'Diproses',
    'dikirim': 'Dikirim',
    'selesai': 'Selesai',
    'dibatalkan': 'Dibatalkan',
  };

  /// Builder generik untuk daftar pesanan per status/tab. Menggantikan
  /// versi lama yang pakai data mock statis — sekarang semua tab ambil dari
  /// `OrderData.getActiveOrders()` lalu difilter berdasar `status`.
  Widget _buildOrderListView(
    List<Map<String, dynamic>> orders,
    Color maroonColor, {
    bool showEstimation = false,
    bool showActionButtons = false,
    String? altButtonLabel,
  }) {
    if (_isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }
    if (orders.isEmpty) {
      return _buildEmptyOrdersView(maroonColor);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 15),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final items = order['items'] as List? ?? [];
        final firstItem = items.isNotEmpty ? items[0] as Map<String, dynamic> : <String, dynamic>{};
        final totalPrice = order['totalPrice'] ?? 0;
        final int? orderId = order['id'] is int ? order['id'] as int : int.tryParse(order['id'].toString());

        return GestureDetector(
          onTap: orderId == null
              ? null
              : () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsScreen(orderId: orderId))),
          child: _buildStatusOrderCard(
            maroonColor,
            firstItem['name'] ?? 'Produk',
            'Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            firstItem['variant'] ?? '-',
            firstItem['image'] ?? 'assets/images/Produk_1.png',
            storeName: order['store_name'] ?? 'Ootday Fashion Store',
            itemCount: items.length,
            status: _statusLabels[order['status']] ?? '',
            showEstimation: showEstimation,
            showActionButtons: showActionButtons,
            altButtonLabel: altButtonLabel,
            orderId: orderId,
          ),
        );
      },
    );
  }

  Widget _buildStatusOrderCard(
    Color maroonColor,
    String name,
    String price,
    String variation,
    String img,
    {
      String storeName = 'Ootday Fashion Store',
      int itemCount = 1,
      String status = '',
      bool showEstimation = false,
      bool showActionButtons = false,
      String? altButtonLabel,
      int? orderId,
    }
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront_outlined, size: 20, color: Colors.black),
                  const SizedBox(width: 10),
                  Text(storeName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              if (status.isNotEmpty)
                Text(status, style: GoogleFonts.outfit(fontSize: 12, color: Colors.black87)),
            ],
          ),
          const Divider(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: img.startsWith('http')
                    ? Image.network(
                        img,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      )
                    : Image.asset(
                        img,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(variation, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                        Text('x1', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(color: Colors.black, fontSize: 12),
                children: [
                  TextSpan(text: 'Total $itemCount Produk: '),
                  TextSpan(text: price, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
          ),
          if (showEstimation) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Estimasi Tiba: 20 - 25 Okt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
                ],
              ),
            ),
          ],
          if (showActionButtons) ...[
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildOutlinedButton(
                  altButtonLabel ?? 'Lihat Penilaian',
                  onPressed: (altButtonLabel == 'Rincian Pembatalan' && orderId != null)
                    ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => CancellationDetailsScreen(orderId: orderId)))
                    : null,
                ),
                const SizedBox(width: 10),
                _buildOutlinedButton('Beli Lagi'),
              ],
            ),
          ] else if (showEstimation) ...[
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: _buildOutlinedButton('Hubungi Penjual'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOutlinedButton(String label, {VoidCallback? onPressed}) {
    return OutlinedButton(
      onPressed: onPressed ?? () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      ),
      child: Text(label, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildEmptyOrdersView(Color maroonColor) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 100, color: maroonColor.withOpacity(0.8)),
                  Positioned(bottom: 0, right: 0, child: Icon(Icons.help_outline, size: 30, color: maroonColor.withOpacity(0.5))),
                ],
              ),
              const SizedBox(height: 15),
              Text('Belum Ada Pesanan', style: GoogleFonts.outfit(color: Colors.black38, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 60),
          _buildRecommendationHeader(maroonColor),
          _buildProductGrid(),
        ],
      ),
    );
  }

  Widget _buildRecommendationHeader(Color maroonColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDot(maroonColor), _buildDot(maroonColor), _buildDot(maroonColor), _buildDot(maroonColor),
        const SizedBox(width: 10),
        Text('Anda Mungkin Juga Suka', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(width: 10),
        _buildDot(maroonColor), _buildDot(maroonColor), _buildDot(maroonColor), _buildDot(maroonColor),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => _buildProductCard(index),
      ),
    );
  }

  Widget _buildProductCard(int index) {
    final List<Map<String, String>> products = [
      {
        'id': 'rec_1',
        'name': 'Blouse Kerah Sailor Pleated',
        'price': '91000',
        'image': 'assets/images/kemeja_wanita/3.jpeg',
        'sold': '700+',
      },
      {
        'id': 'rec_2',
        'name': 'Kemeja Beige Belted Overshirt',
        'price': '91000',
        'image': 'assets/images/kemeja_wanita/2.jpeg',
        'sold': '1.2RB',
      },
      {
        'id': 'rec_3',
        'name': 'Blouse Tunik Biru Muda Tali Pinggang',
        'price': '94500',
        'image': 'assets/images/kemeja_wanita/1.jpeg',
        'sold': '489',
      },
      {
        'id': 'rec_4',
        'name': 'Blouse Kerah Sailor Pleated',
        'price': '91000',
        'image': 'assets/images/kemeja_wanita/3.jpeg',
        'sold': '700+',
      },
    ];

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: products[index]))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), 
                child: Image.asset(products[index]['image']!, width: double.infinity, fit: BoxFit.cover)
              )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(products[index]['name']!, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text('Rp ${products[index]['price']}', style: GoogleFonts.outfit(color: const Color(0xFF5D1A1A), fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text('4.7', style: GoogleFonts.outfit(fontSize: 10)),
                      const Spacer(),
                      Text('${products[index]['sold']} terjual', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
