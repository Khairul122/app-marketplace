import 'package:flutter/material.dart';
import 'package:ootday_owner/widgets/owner_bottom_nav.dart';
import 'package:ootday_owner/chat.dart';
import 'search_page.dart';
import 'stat_detail_page.dart';
import 'order_status_detail_page.dart';
import 'order_history_page.dart';

class HomePage extends StatelessWidget {
  final Color redMain = const Color(0xFF5D1A1A);
  final Color lightRed = const Color(0xFFA53C3C);
  final Color greyBG = const Color(0xFFF2F2F2);

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyBG,
      bottomNavigationBar: const OwnerBottomNav(currentIndex: 0),
      body: Column(
        children: [
          // ================= HEADER WITH LOGO =================
          _header(),
          Expanded(
        child: SingleChildScrollView(
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
                        "Bos Muda",
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
              statisticGrid(context),
                  const SizedBox(height: 12),
              statusSection(context),
                  const SizedBox(height: 12),
              Text(
                "Pesanan Baru",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              orderItem(
                    context: context,
                img: "assets/image1.png",
                    title: "Kaos oversized polos coklat\ndengan logo bordir di dada kiri",
                    code: "#A7273G6453",
                    quantity: "(1)",
                  ),
                  const SizedBox(height: 12),
              orderItem(
                    context: context,
                img: "assets/image2.png",
                    title: "Dress rajut tali bahu + inner\nblouse putih lengan panjang",
                    code: "#A7273G6453",
                    quantity: "(1)",
                  ),
                  const SizedBox(height: 12),
              orderItem(
                    context: context,
                img: "assets/image3.png",
                title: "Celana jeans biru model cutbray",
                    code: "#A7273G6453",
                    quantity: "(1)",
                  ),
                  const SizedBox(height: 8), // Extra padding at bottom
                ],
              ),
            ),
          ),
        ],
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
        // Navigate to search page when search bar is tapped
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
            const Icon(Icons.search, color: Colors.black87), // Dark grey icon
          const SizedBox(width: 10),
          const Expanded(
              child: Text(
                "search",
                style: TextStyle(
                  color: Colors.grey,
              ),
            ),
          ),

            // CHAT BUBBLE ICON dengan red dot
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
                      color: Colors.black87, // Dark grey
                      size: 24,
                    ),
                    // Red dot di top-right corner
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
    final cards = <_StatCardData>[
      _StatCardData(
        icon: Icons.people,
        value: '857',
        title: 'Total Visitors',
        showGraph: true,
        page: StatDetailData.visitors(),
      ),
      _StatCardData(
        icon: Icons.shopping_bag,
        value: '690',
        title: 'Total Orders',
        page: StatDetailData.orders(),
      ),
      _StatCardData(
        icon: Icons.visibility,
        value: '1213',
        title: 'Total Views',
        showGraph: true,
        page: StatDetailData.views(),
      ),
      _StatCardData(
        icon: Icons.chat_bubble,
        value: '83%',
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
          ),
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
                    fontSize: 20,
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
    final statuses = <_StatusCardData>[
      _StatusCardData('Perlu Dikirim', 0, OrderStatusDetailData.perluDikirim()),
      _StatusCardData('Pembatalan', 0, OrderStatusDetailData.pembatalan()),
      _StatusCardData('Pengembalian', 0, OrderStatusDetailData.pengembalian()),
      _StatusCardData('Penilaian', 2, OrderStatusDetailData.penilaian()),
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
                );
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
                      ),
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

  // ==================== ORDER ITEM ====================
  Widget orderItem({
    required BuildContext context,
    required String img,
    required String title,
    required String code,
    required String quantity,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to order detail page
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
                  child: Image.asset(
                    img,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    ),
                  ),
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
                child: Image.asset(
                  img,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 30),
                  ),
                ),
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
                    // Accept order
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order $code diterima')),
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
                    // Reject order
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Pesanan $code dibatalkan')),
                              );
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