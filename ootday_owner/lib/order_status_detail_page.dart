import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'services/order_service.dart';

/// Halaman detail satu kelompok status pesanan. Data diambil langsung dari
/// GET /my-orders (difilter di sisi klien berdasarkan [status]), lalu tiap
/// pesanan bisa diubah statusnya lewat PUT /my-orders/{id}/status.
class OrderStatusDetailPage extends StatefulWidget {
  const OrderStatusDetailPage({
    super.key,
    required this.title,
    required this.status,
    required this.description,
  });

  /// Judul yang ditampilkan di header halaman ini.
  final String title;

  /// Salah satu enum status backend:
  /// menunggu_pembayaran, diproses, dikirim, selesai, dibatalkan.
  final String status;

  final String description;

  static const Color redMain = Color(0xFF5D1A1A);
  static const Color darkRed = Color(0xFF7A0000);
  static const Color greyBg = Color(0xFFF2F2F2);

  static const List<String> allStatuses = [
    'menunggu_pembayaran',
    'diproses',
    'dikirim',
    'selesai',
    'dibatalkan',
  ];

  static const Map<String, String> statusLabels = {
    'menunggu_pembayaran': 'Menunggu Pembayaran',
    'diproses': 'Diproses',
    'dikirim': 'Dikirim',
    'selesai': 'Selesai',
    'dibatalkan': 'Dibatalkan',
  };

  static const Map<String, Color> statusColors = {
    'menunggu_pembayaran': Colors.orange,
    'diproses': Colors.blue,
    'dikirim': Colors.purple,
    'selesai': Colors.green,
    'dibatalkan': Colors.red,
  };

  @override
  State<OrderStatusDetailPage> createState() => _OrderStatusDetailPageState();
}

class _OrderStatusDetailPageState extends State<OrderStatusDetailPage> {
  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    try {
      final orders = await _orderService.getMyOrders();
      return orders
          .whereType<Map>()
          .map((o) => Map<String, dynamic>.from(o))
          .where((o) => o['status'] == widget.status)
          .toList();
    } on ApiException catch (e) {
      _notify(e.message, isError: true);
      return <Map<String, dynamic>>[];
    } catch (_) {
      _notify('Gagal memuat pesanan.', isError: true);
      return <Map<String, dynamic>>[];
    }
  }

  void _notify(String message, {bool isError = false}) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    });
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  Future<void> _updateStatus(Map<String, dynamic> order, String newStatus) async {
    try {
      await _orderService.updateStatus(order['id'] as int, newStatus);
      _notify('Status pesanan berhasil diperbarui.');
      await _refresh();
    } on ApiException catch (e) {
      _notify(e.message, isError: true);
    } catch (_) {
      _notify('Gagal memperbarui status pesanan.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrderStatusDetailPage.greyBg,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data ?? <Map<String, dynamic>>[];
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _summaryCard(orders.length),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Daftar Pesanan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${orders.length} item',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (orders.isEmpty)
                          _emptyState()
                        else
                          ...orders.map(_orderCard),
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
          colors: [OrderStatusDetailPage.redMain, OrderStatusDetailPage.darkRed],
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
    );
  }

  Widget _summaryCard(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OrderStatusDetailPage.redMain,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pesanan dengan status ini akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final items = (order['items'] as List?) ?? const [];
    final firstItem = items.isNotEmpty && items.first is Map
        ? Map<String, dynamic>.from(items.first as Map)
        : <String, dynamic>{};
    final productName = firstItem['product_name']?.toString() ?? 'Produk';
    final extra = items.length > 1 ? ' +${items.length - 1} lainnya' : '';
    final imageUrl = ApiService.resolveImageUrl(firstItem['image_url']?.toString());
    final status = order['status']?.toString() ?? widget.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openDetailSheet(order),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.isEmpty
                      ? Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        )
                      : Image.network(
                          imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
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
                        '$productName$extra',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['order_code']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: OrderStatusDetailPage.redMain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rp${order['total_price'] ?? 0}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (OrderStatusDetailPage.statusColors[status] ?? Colors.grey)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    OrderStatusDetailPage.statusLabels[status] ?? status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: OrderStatusDetailPage.statusColors[status] ?? Colors.grey,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetailSheet(Map<String, dynamic> order) {
    final items = (order['items'] as List?) ?? const [];
    final user = order['user'] is Map ? Map<String, dynamic>.from(order['user'] as Map) : null;
    final paymentMethod = order['payment_method'] is Map
        ? Map<String, dynamic>.from(order['payment_method'] as Map)
        : null;
    final shippingMethod = order['shipping_method'] is Map
        ? Map<String, dynamic>.from(order['shipping_method'] as Map)
        : null;
    String selectedStatus = order['status']?.toString() ?? widget.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['order_code']?.toString() ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pembeli: ${user?['name'] ?? '-'}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 14),
                    ...items.map((raw) {
                      final item = Map<String, dynamic>.from(raw as Map);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 44,
                                height: 44,
                                color: Colors.grey[200],
                                child: (item['image_url']?.toString() ?? '').isEmpty
                                    ? const Icon(Icons.image, color: Colors.grey, size: 20)
                                    : Image.network(
                                        ApiService.resolveImageUrl(item['image_url'].toString()),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.image, color: Colors.grey, size: 20),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['product_name']?.toString() ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  if ((item['variant_label']?.toString() ?? '').isNotEmpty)
                                    Text(
                                      item['variant_label'].toString(),
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  Text(
                                    '${item['quantity'] ?? 0} x Rp${item['price'] ?? 0}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 24),
                    _summaryRow('Subtotal', order['subtotal']),
                    _summaryRow('Ongkos Kirim', order['shipping_cost']),
                    _summaryRow('Total', order['total_price'], bold: true),
                    const SizedBox(height: 8),
                    if (paymentMethod != null)
                      Text('Pembayaran: ${paymentMethod['name'] ?? '-'}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    if (shippingMethod != null)
                      Text('Pengiriman: ${shippingMethod['name'] ?? '-'}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    const SizedBox(height: 20),
                    const Text(
                      'Ubah Status Pesanan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: OrderStatusDetailPage.allStatuses
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(OrderStatusDetailPage.statusLabels[s] ?? s),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setSheetState(() => selectedStatus = v);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrderStatusDetailPage.redMain,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _updateStatus(order, selectedStatus);
                        },
                        child: const Text(
                          'Simpan Status',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _summaryRow(String label, dynamic value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          Text(
            'Rp${value ?? 0}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Factory statis untuk kompatibilitas dengan pemanggil lama (home_page.dart)
/// yang masih memakai nama method ini tanpa argumen.
///
/// Catatan: backend tidak punya status "pengembalian" (retur), jadi kartu
/// tersebut untuk sementara diarahkan ke status `menunggu_pembayaran` sampai
/// backend menambah dukungan retur.
class OrderStatusDetailData {
  OrderStatusDetailData._();

  static OrderStatusDetailPage perluDikirim() => const OrderStatusDetailPage(
        title: 'Perlu Dikirim',
        status: 'diproses',
        description: 'Pesanan yang sudah dibayar dan menunggu diproses/dikirim.',
      );

  static OrderStatusDetailPage pembatalan() => const OrderStatusDetailPage(
        title: 'Pembatalan',
        status: 'dibatalkan',
        description: 'Pesanan yang dibatalkan oleh pembeli atau toko.',
      );

  static OrderStatusDetailPage pengembalian() => const OrderStatusDetailPage(
        title: 'Pengembalian',
        status: 'menunggu_pembayaran',
        description:
            'Backend belum mendukung status retur/pengembalian; sementara menampilkan pesanan yang menunggu pembayaran.',
      );

  static OrderStatusDetailPage penilaian() => const OrderStatusDetailPage(
        title: 'Penilaian',
        status: 'selesai',
        description: 'Pesanan selesai yang menunggu ulasan pembeli.',
      );
}
