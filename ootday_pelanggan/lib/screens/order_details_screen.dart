import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ootday_pelanggan/screens/cart_screen.dart';
import '../services/api_service.dart';
import 'chat_list_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _api.get('/orders/${widget.orderId}');
      final data = (result is Map && result['data'] is Map) ? result['data'] : result;
      setState(() {
        _order = Map<String, dynamic>.from(data as Map);
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat detail pesanan';
      });
    }
  }

  String _formatCurrency(dynamic value) {
    final numValue = num.tryParse((value ?? 0).toString()) ?? 0;
    return 'Rp ${numValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'menunggu_pembayaran':
        return 'Menunggu Pembayaran';
      case 'diproses':
        return 'Pesanan Anda Sedang Disiapkan';
      case 'dikirim':
        return 'Pesanan Sedang Dikirim';
      case 'selesai':
        return 'Pesanan Selesai';
      case 'dibatalkan':
        return 'Pesanan Dibatalkan';
      default:
        return status ?? '-';
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    try {
      final date = DateTime.parse(value.toString()).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(date.day)}-${two(date.month)}-${date.year} ${two(date.hour)}:${two(date.minute)}';
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color lightPinkBg = Color(0xFFF8F3F3);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: maroonColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Rincian Pesanan',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
              child: const Padding(
                padding: EdgeInsets.only(right: 20, top: 10),
                child: Icon(Icons.shopping_cart_outlined, color: maroonColor, size: 28),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_errorMessage!, style: GoogleFonts.outfit(color: Colors.black54)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _loadOrder,
                          style: ElevatedButton.styleFrom(backgroundColor: maroonColor),
                          child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : _buildContent(context, maroonColor, lightPinkBg),
        bottomSheet: (_isLoading || _errorMessage != null) ? null : _buildBottomButtons(context, maroonColor),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color maroonColor, Color lightPinkBg) {
    final order = _order ?? {};
    final items = (order['items'] is List) ? List<Map<String, dynamic>>.from(order['items']) : <Map<String, dynamic>>[];
    final store = order['store'] is Map ? Map<String, dynamic>.from(order['store']) : {};
    final shippingMethod = order['shipping_method'] is Map ? Map<String, dynamic>.from(order['shipping_method']) : {};
    final paymentMethod = order['payment_method'] is Map ? Map<String, dynamic>.from(order['payment_method']) : {};

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Status Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: lightPinkBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusLabel(order['status']?.toString()),
                  style: GoogleFonts.outfit(color: maroonColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  'No. Pesanan: ${order['order_code'] ?? '-'}',
                  style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Info Pengiriman
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Info Pengiriman', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: maroonColor, size: 30),
                    const SizedBox(width: 15),
                    Text((shippingMethod['name'] ?? '-').toString(), style: GoogleFonts.outfit(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 40),

          // 3. Order Card
          _buildOrderCard(context, maroonColor, store, items, order),

          const Divider(height: 40),

          // 4. Additional Info Section
          _buildInfoSection(maroonColor, order, paymentMethod),

          const SizedBox(height: 120), // Space for bottom buttons
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Color maroonColor, Map store, List<Map<String, dynamic>> items, Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: 20, color: Colors.black),
              const SizedBox(width: 10),
              Text((store['store_name'] ?? 'Toko').toString(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 15),
          for (final item in items) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (item['image_url'] != null && item['image_url'].toString().startsWith('http'))
                        ? Image.network(
                            item['image_url'].toString(),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.image_not_supported_outlined)),
                          )
                        : Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.image_not_supported_outlined)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (item['product_name'] ?? '-').toString(),
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text((item['variant_label'] ?? '-').toString(), style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                            Text('x${item['quantity'] ?? 1}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: Text('Total: ${_formatCurrency(order['total_price'])}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Color maroonColor, Map<String, dynamic> order, Map paymentMethod) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: Color(0xFF5D1A1A), size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text('Pusat Bantuan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14))),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
            ],
          ),
          const Divider(height: 30),
          _buildTextRowWithCopy('No. Pesanan', (order['order_code'] ?? '-').toString()),
          const Divider(height: 30),
          _buildTextRow('Metode Pembayaran', (paymentMethod['name'] ?? '-').toString(), icon: Icons.account_balance_wallet, iconColor: Colors.blue),
          const Divider(height: 30),
          _buildTextRow('Waktu Pemesanan', _formatDate(order['ordered_at'])),
        ],
      ),
    );
  }

  Widget _buildTextRow(String label, String value, {IconData? icon, Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13)),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 5),
            ],
            Flexible(child: Text(value, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500))),
          ],
        ),
      ],
    );
  }

  Widget _buildTextRowWithCopy(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13)),
        Row(
          children: [
            Text(value, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(20)),
              child: Text('Salin', style: GoogleFonts.outfit(fontSize: 10)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context, Color maroonColor) {
    final status = _order?['status']?.toString();
    final canCancel = status == 'menunggu_pembayaran' || status == 'diproses';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          if (canCancel)
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleCancelOrder(context, maroonColor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroonColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Batalkan Pesanan', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          if (canCancel) const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: maroonColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Hubungi Penjual', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancelOrder(BuildContext context, Color maroonColor) async {
    // Endpoint pembatalan order tidak termasuk cakupan tugas ini (tidak ada
    // kontrak endpoint yang diberikan), jadi tombol ini hanya memberi info.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembatalan pesanan belum tersedia dari halaman ini.')),
    );
  }
}
