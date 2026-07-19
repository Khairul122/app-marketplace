import 'package:flutter/material.dart';
import 'package:ootday_owner/widgets/owner_bottom_nav.dart';
import 'package:ootday_owner/chat.dart';
import 'package:ootday_owner/services/api_service.dart';
import 'package:ootday_owner/services/auth_service.dart';
import 'package:ootday_owner/services/dashboard_service.dart';
import 'package:ootday_owner/services/order_service.dart';
import 'search_page.dart';
import 'stat_detail_page.dart';
import 'order_status_detail_page.dart';
import 'order_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color redMain = const Color(0xFF5D1A1A);
  final Color lightRed = const Color(0xFFA53C3C);
  final Color greyBG = const Color(0xFFF2F2F2);

  final AuthService _authService = AuthService();
  final DashboardService _dashboardService = DashboardService();
  final OrderService _orderService = OrderService();

  Map<String, dynamic>? _dashboardData;
  List<Map<String, dynamic>> _recentOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dashboard = await _dashboardService.getDashboard();
      final orders = await _orderService.getMyOrders();

      if (!mounted) return;
      setState(() {
        _dashboardData = dashboard;
        _recentOrders = orders
            .map((o) => Map<String, dynamic>.from(o as Map))
            .take(3)
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(int id, String newStatus) async {
    try {
      await _orderService.updateStatus(id, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status pesanan berhasil diperbarui.')),
      );
      _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final ownerName = _authService.currentUser?['name'] ?? 'Bos Muda';

    return Scaffold(
      backgroundColor: greyBG,
      bottomNavigationBar: const OwnerBottomNav(currentIndex: 0),
      body: RefreshIndicator(
        color: redMain,
        onRefresh: _loadData,
        child: Column(
          children: [
            // ================= HEADER WITH LOGO =================
            _header(),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchBar(context),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "Hello! ",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: redMain,
                          ),
                        ),
                        Text(
                          ownerName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: redMain,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.grey,
                            decorationThickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _isLoading
                        ? const SizedBox(
                            height: 120,
                            child: Center(
                              child: CircularProgressIndicator(color: Color(0xFF5D1A1A)),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              statisticGrid(context),
                              const SizedBox(height: 12),
                              statusSection(context),
                              const SizedBox(height: 12),
                              const Text(
                                "Pesanan Baru",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              if (_recentOrders.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Belum ada pesanan masuk",
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ),
                                )
                              else
                                ..._recentOrders.map((order) {
                                  final items = order['items'] as List?;
                                  final firstItem = items != null && items.isNotEmpty
                                      ? items.first as Map
                                      : null;

                                  final imgUrl = firstItem?['image_url'] ?? '';
                                  final title = firstItem?['product_name'] ??
                                      'Pesanan ${order['order_code']}';
                                  final code = order['order_code'] ?? '';
                                  final quantity = '(${firstItem?['quantity'] ?? 1})';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: orderItem(
                                      context: context,
                                      order: order,
                                      img: imgUrl,
                                      title: title,
                                      code: code,
                                      quantity: quantity,
                                    ),
                                  );
                                }),
                            ],
                          ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER WITH LOGO =================
  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: redMain,
      ),
      child: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/logo.png',
            height: 32,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'ootday',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== SEARCH BAR ====================
  Widget searchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SearchPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.black87),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "search",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatPage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Stack(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.black87,
                      size: 24,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STATISTICS GRID ====================
  Widget statisticGrid(BuildContext context) {
    final totalOrders = (_dashboardData?['total_orders'] as num?)?.toInt() ?? 0;
    final totalProducts = (_dashboardData?['total_products'] as num?)?.toInt() ?? 0;
    final revenue = (_dashboardData?['revenue'] as num?)?.toDouble() ?? 0.0;

    final byStatus = _dashboardData?['orders_by_status'] is Map
        ? Map<String, dynamic>.from(_dashboardData!['orders_by_status'] as Map)
        : <String, dynamic>{};
    final selesaiCount = (byStatus['selesai'] as num?)?.toInt() ?? 0;
    final completedPct = totalOrders == 0 ? 0 : ((selesaiCount / totalOrders) * 100).round();

    final cards = <_StatCardData>[
      _StatCardData(
        icon: Icons.people,
        value: '$totalProducts',
        title: 'Total Visitors',
        showGraph: true,
        page: StatDetailData.visitors(),
      ),
      _StatCardData(
        icon: Icons.shopping_bag,
        value: '$totalOrders',
        title: 'Total Orders',
        page: StatDetailData.orders(),
      ),
      _StatCardData(
        icon: Icons.visibility,
        value: 'Rp ${_formatPrice(revenue.toInt())}',
        title: 'Total Views',
        showGraph: true,
        page: StatDetailData.views(),
      ),
      _StatCardData(
        icon: Icons.chat_bubble,
        value: '$completedPct%',
        title: 'Conversation',
        page: StatDetailData.conversation(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.75,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return _tappableCard(
          context: context,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => card.page),
          ).then((_) => _loadData()),
          child: _statCardContent(
            icon: card.icon,
            value: card.value,
            title: card.title,
            showGraph: card.showGraph,
          ),
        );
      },
    );
  }

  Widget _statCardContent({
    required IconData icon,
    required String value,
    required String title,
    bool showGraph = false,
  }) {
    const darkRed = Color(0xFF7A0000);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: darkRed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: darkRed, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            ),
          ),
          if (showGraph)
            Icon(
              Icons.show_chart,
              color: Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
        ],
      ),
    );
  }

  // ==================== STATUS SECTION ====================
  Widget statusSection(BuildContext context) {
    final byStatus = _dashboardData?['orders_by_status'] is Map
        ? Map<String, dynamic>.from(_dashboardData!['orders_by_status'] as Map)
        : <String, dynamic>{};

    final diprosesCount = (byStatus['diproses'] as num?)?.toInt() ?? 0;
    final dibatalkanCount = (byStatus['dibatalkan'] as num?)?.toInt() ?? 0;
    final menungguPembayaranCount = (byStatus['menunggu_pembayaran'] as num?)?.toInt() ?? 0;
    final selesaiCount = (byStatus['selesai'] as num?)?.toInt() ?? 0;

    final statuses = <_StatusCardData>[
      _StatusCardData('Perlu Dikirim', diprosesCount, OrderStatusDetailData.perluDikirim()),
      _StatusCardData('Pembatalan', dibatalkanCount, OrderStatusDetailData.pembatalan()),
      _StatusCardData('Pengembalian', menungguPembayaranCount, OrderStatusDetailData.pengembalian()),
      _StatusCardData('Penilaian', selesaiCount, OrderStatusDetailData.penilaian()),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Status Pemesanan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderHistoryPage(),
                  ),
                ).then((_) => _loadData());
              },
              child: Text(
                'Riwayat >',
                style: TextStyle(
                  fontSize: 12,
                  color: redMain,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: statuses
              .map(
                (s) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _tappableCard(
                      context: context,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => s.page),
                      ).then((_) => _loadData()),
                      child: _statusBoxContent(s.title, s.count),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _statusBoxContent(String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: redMain,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _tappableCard({
    required BuildContext context,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: child,
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    final resolved = ApiService.resolveImageUrl(imageUrl);
    if (resolved.isEmpty) return _placeholderImage();
    return Image.network(
      resolved,
      fit: BoxFit.cover,
      width: 70,
      height: 70,
      errorBuilder: (_, __, ___) => _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 30, color: Colors.grey),
      ),
    );
  }

  // ==================== ORDER ITEM ====================
  Widget orderItem({
    required BuildContext context,
    required Map<String, dynamic> order,
    required String img,
    required String title,
    required String code,
    required String quantity,
  }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Detail Pesanan $code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(img),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Kuantitas: $quantity'),
                const SizedBox(height: 4),
                Text(
                  'Kode: $code',
                  style: TextStyle(color: redMain, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildProductImage(img),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        quantity,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        code,
                        style: TextStyle(
                          fontSize: 12,
                          color: redMain,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    final currentStatus = order['status'] as String?;
                    String nextStatus = 'diproses';
                    if (currentStatus == 'menunggu_pembayaran') {
                      nextStatus = 'diproses';
                    } else if (currentStatus == 'diproses') {
                      nextStatus = 'dikirim';
                    } else if (currentStatus == 'dikirim') {
                      nextStatus = 'selesai';
                    } else {
                      return;
                    }

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Proses Pesanan'),
                        content: Text('Ubah status pesanan $code menjadi ${OrderStatusDetailPage.statusLabels[nextStatus]}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _updateOrderStatus(order['id'] as int, nextStatus);
                            },
                            child: const Text('Ya, Proses', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Batalkan Pesanan'),
                        content: Text('Apakah Anda yakin ingin membatalkan pesanan $code?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _updateOrderStatus(order['id'] as int, 'dibatalkan');
                            },
                            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.icon,
    required this.value,
    required this.title,
    required this.page,
    this.showGraph = false,
  });

  final IconData icon;
  final String value;
  final String title;
  final bool showGraph;
  final StatDetailPage page;
}

class _StatusCardData {
  const _StatusCardData(this.title, this.count, this.page);

  final String title;
  final int count;
  final OrderStatusDetailPage page;
}