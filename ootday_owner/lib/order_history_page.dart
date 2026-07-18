import 'package:flutter/material.dart';
import 'order_status_detail_page.dart';
import 'services/api_service.dart';
import 'services/order_service.dart';

/// Ringkasan semua status pemesanan (dari "Riwayat >"), diambil dari
/// GET /my-orders dan dikelompokkan berdasarkan status backend.
class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  static const Color _redMain = Color(0xFFB40001);
  static const Color _darkRed = Color(0xFF7A0000);
  static const Color _greyBg = Color(0xFFF2F2F2);

  final OrderService _orderService = OrderService();
  late Future<List<dynamic>> _future;

  static const List<(String, String, String)> _categories = [
    ('Menunggu Pembayaran', 'menunggu_pembayaran', 'Pesanan yang belum dibayar oleh pembeli.'),
    ('Diproses', 'diproses', 'Pesanan sudah dibayar dan sedang disiapkan/menunggu dikirim.'),
    ('Dikirim', 'dikirim', 'Pesanan sedang dalam perjalanan pengiriman.'),
    ('Selesai', 'selesai', 'Pesanan yang telah selesai diterima pembeli.'),
    ('Dibatalkan', 'dibatalkan', 'Pesanan yang dibatalkan oleh pembeli atau toko.'),
  ];

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() async {
    try {
      return await _orderService.getMyOrders();
    } on ApiException catch (e) {
      _notifyError(e.message);
      return <dynamic>[];
    } catch (_) {
      _notifyError('Gagal memuat riwayat pesanan.');
      return <dynamic>[];
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

  int _countByStatus(List<dynamic> orders, String status) {
    return orders.where((o) => o is Map && o['status'] == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greyBg,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_redMain, _darkRed],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Text(
                  'Riwayat Pemesanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data ?? <dynamic>[];
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final (title, status, description) = _categories[index];
                      final count = _countByStatus(orders, status);
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderStatusDetailPage(
                                  title: title,
                                  status: status,
                                  description: description,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _redMain.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _redMain,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey[400]),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
