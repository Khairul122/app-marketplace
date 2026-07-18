import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'services/dashboard_service.dart';

/// Detail satu kartu statistik di home page. Data nyata diambil dari
/// GET /owner/dashboard —
/// `{total_products, total_orders, orders_by_status, revenue, top_products}`.
///
/// Catatan: backend hanya menyediakan satu endpoint ringkasan dashboard yang
/// sama untuk semua kartu (tidak ada endpoint terpisah utk "visitors",
/// "views", atau "conversation rate"), jadi keempat kartu di home page
/// menampilkan potongan data yang paling relevan dari payload yang sama:
/// - Total Orders -> total_orders
/// - Total Visitors -> total_products (proxy: jumlah produk aktif di toko)
/// - Total Views -> revenue (Rp)
/// - Conversation -> rasio pesanan selesai terhadap total pesanan
class StatDetailPage extends StatefulWidget {
  const StatDetailPage({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.showGraph = false,
    required this.summaryLines,
    required this.activities,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool showGraph;
  final List<String> summaryLines;
  final List<StatActivityItem> activities;

  static const Color _redMain = Color(0xFF5D1A1A);
  static const Color _darkRed = Color(0xFF7A0000);
  static const Color _greyBg = Color(0xFFF2F2F2);

  @override
  State<StatDetailPage> createState() => _StatDetailPageState();
}

class _StatDetailPageState extends State<StatDetailPage> {
  final DashboardService _dashboardService = DashboardService();
  late Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Map<String, dynamic>?> _load() async {
    try {
      return await _dashboardService.getDashboard();
    } on ApiException catch (e) {
      _notifyError(e.message);
      return null;
    } catch (_) {
      _notifyError('Gagal memuat data dashboard.');
      return null;
    }
  }

  void _notifyError(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    });
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  String _valueFor(Map<String, dynamic> dashboard) {
    final title = widget.title.toLowerCase();
    final totalOrders = (dashboard['total_orders'] as num?)?.toInt() ?? 0;
    final totalProducts = (dashboard['total_products'] as num?)?.toInt() ?? 0;
    final revenue = (dashboard['revenue'] as num?)?.toInt() ?? 0;
    final byStatus = dashboard['orders_by_status'] is Map
        ? Map<String, dynamic>.from(dashboard['orders_by_status'] as Map)
        : <String, dynamic>{};
    final selesai = (byStatus['selesai'] as num?)?.toInt() ?? 0;

    if (title.contains('order')) return '$totalOrders';
    if (title.contains('visitor')) return '$totalProducts';
    if (title.contains('view')) return 'Rp$revenue';
    if (title.contains('conversation') || title.contains('conversion')) {
      final pct = totalOrders == 0 ? 0 : ((selesai / totalOrders) * 100).round();
      return '$pct%';
    }
    return widget.value;
  }

  List<String> _summaryFor(Map<String, dynamic> dashboard) {
    final totalOrders = (dashboard['total_orders'] as num?)?.toInt() ?? 0;
    final totalProducts = (dashboard['total_products'] as num?)?.toInt() ?? 0;
    final revenue = (dashboard['revenue'] as num?)?.toInt() ?? 0;
    final byStatus = dashboard['orders_by_status'] is Map
        ? Map<String, dynamic>.from(dashboard['orders_by_status'] as Map)
        : <String, dynamic>{};

    return [
      'Total produk aktif: $totalProducts',
      'Total pesanan: $totalOrders',
      'Pendapatan: Rp$revenue',
      'Menunggu pembayaran: ${byStatus['menunggu_pembayaran'] ?? 0} · '
          'Diproses: ${byStatus['diproses'] ?? 0} · '
          'Dikirim: ${byStatus['dikirim'] ?? 0} · '
          'Selesai: ${byStatus['selesai'] ?? 0} · '
          'Dibatalkan: ${byStatus['dibatalkan'] ?? 0}',
    ];
  }

  List<StatActivityItem> _activitiesFor(Map<String, dynamic> dashboard) {
    final topProducts = dashboard['top_products'] is List
        ? List<dynamic>.from(dashboard['top_products'] as List)
        : <dynamic>[];

    if (topProducts.isEmpty) return const [];

    return topProducts.map((raw) {
      final product = Map<String, dynamic>.from(raw as Map);
      final name = product['name']?.toString() ?? 'Produk';
      final sold = product['sold_count'] ?? 0;
      final price = product['price'] ?? 0;
      return StatActivityItem(
        icon: Icons.shopping_bag,
        title: name,
        subtitle: 'Terjual $sold kali · Rp$price',
        time: '',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StatDetailPage._greyBg,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final dashboard = snapshot.data;
                final value = dashboard != null ? _valueFor(dashboard) : widget.value;
                final summaryLines =
                    dashboard != null ? _summaryFor(dashboard) : widget.summaryLines;
                final activities =
                    dashboard != null ? _activitiesFor(dashboard) : widget.activities;

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _summaryCard(value),
                        const SizedBox(height: 20),
                        const Text(
                          'Ringkasan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _infoCard(
                          child: Column(
                            children: summaryLines
                                .map(
                                  (line) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: StatDetailPage._redMain.withValues(alpha: 0.6),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            line,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Produk Terlaris',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (activities.isEmpty)
                          _infoCard(
                            child: Row(
                              children: [
                                Icon(Icons.inbox_outlined, color: Colors.grey[500]),
                                const SizedBox(width: 12),
                                Text(
                                  'Belum ada aktivitas.',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        else
                          ...activities.map(_activityTile),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [StatDetailPage._redMain, StatDetailPage._darkRed],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StatDetailPage._darkRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: StatDetailPage._darkRed, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showGraph)
            Icon(
              Icons.show_chart,
              color: Colors.white.withValues(alpha: 0.7),
              size: 28,
            ),
        ],
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _activityTile(StatActivityItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _infoCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: StatDetailPage._redMain.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: StatDetailPage._redMain, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (item.time.isNotEmpty)
              Text(
                item.time,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
          ],
        ),
      ),
    );
  }
}

class StatActivityItem {
  const StatActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
}

/// Factory untuk kompatibilitas dengan home_page.dart yang masih memanggil
/// method ini tanpa argumen. Nilai di sini hanya dipakai sebagai fallback
/// selagi [StatDetailPage] memuat data asli dari GET /owner/dashboard.
class StatDetailData {
  StatDetailData._();

  static StatDetailPage visitors() => const StatDetailPage(
        title: 'Total Visitors',
        value: '-',
        icon: Icons.people,
        showGraph: true,
        summaryLines: [],
        activities: [],
      );

  static StatDetailPage orders() => const StatDetailPage(
        title: 'Total Orders',
        value: '-',
        icon: Icons.shopping_bag,
        summaryLines: [],
        activities: [],
      );

  static StatDetailPage views() => const StatDetailPage(
        title: 'Total Views',
        value: '-',
        icon: Icons.visibility,
        showGraph: true,
        summaryLines: [],
        activities: [],
      );

  static StatDetailPage conversation() => const StatDetailPage(
        title: 'Conversation',
        value: '-',
        icon: Icons.chat_bubble,
        summaryLines: [],
        activities: [],
      );
}
