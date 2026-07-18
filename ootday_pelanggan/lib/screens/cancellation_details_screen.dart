import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'order_details_screen.dart';

class CancellationDetailsScreen extends StatefulWidget {
  final int orderId;
  const CancellationDetailsScreen({super.key, required this.orderId});

  @override
  State<CancellationDetailsScreen> createState() => _CancellationDetailsScreenState();
}

class _CancellationDetailsScreenState extends State<CancellationDetailsScreen> {
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
        _errorMessage = 'Gagal memuat detail pembatalan';
      });
    }
  }

  String _formatCurrency(dynamic value) {
    final numValue = num.tryParse((value ?? 0).toString()) ?? 0;
    return 'Rp ${numValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
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
    const Color lightBg = Color(0xFFEFEFEF);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: maroonColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Rincian Pembatalan',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
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
                : _buildContent(context, maroonColor),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color maroonColor) {
    final order = _order ?? {};
    final items = (order['items'] is List) ? List<Map<String, dynamic>>.from(order['items']) : <Map<String, dynamic>>[];
    final store = order['store'] is Map ? Map<String, dynamic>.from(order['store']) : {};
    final paymentMethod = order['payment_method'] is Map ? Map<String, dynamic>.from(order['payment_method']) : {};
    final firstItem = items.isNotEmpty ? items.first : <String, dynamic>{};

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Status Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFF8F3F3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pembatalan Berhasil',
                      style: GoogleFonts.outfit(
                        color: maroonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'pada ${_formatDate(order['ordered_at'])}',
                      style: GoogleFonts.outfit(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
                Icon(Icons.check_circle, color: maroonColor, size: 45),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. Order Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
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
                const Divider(height: 25),
                if (items.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: (firstItem['image_url'] != null && firstItem['image_url'].toString().startsWith('http'))
                            ? Image.network(
                                firstItem['image_url'].toString(),
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
                              (firstItem['product_name'] ?? '-').toString(),
                              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text((firstItem['variant_label'] ?? '-').toString(), style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text('x${firstItem['quantity'] ?? 1}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerRight,
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.outfit(color: Colors.black, fontSize: 12),
                      children: [
                        TextSpan(text: 'Total ${items.length} Produk: '),
                        TextSpan(text: _formatCurrency(order['total_price']), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. Details Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _buildDetailRow('Diminta oleh', 'Pembeli'),
                const SizedBox(height: 15),
                _buildDetailRow('Diminta pada', _formatDate(order['ordered_at'])),
                const SizedBox(height: 15),
                _buildDetailRow(
                  'Metode pembayaran',
                  (paymentMethod['name'] ?? '-').toString(),
                  trailingIcon: Icons.account_balance_wallet,
                  iconColor: Colors.blue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // 4. Action Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetailsScreen(orderId: widget.orderId)));
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: maroonColor),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Rincian Pesanan',
                style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? trailingIcon, Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
        Row(
          children: [
            if (trailingIcon != null) ...[
              Icon(trailingIcon, size: 18, color: iconColor),
              const SizedBox(width: 5),
            ],
            Text(value, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
