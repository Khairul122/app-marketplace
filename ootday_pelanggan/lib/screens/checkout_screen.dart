import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_method_screen.dart';
import 'payment_instruction_screen.dart';
import 'order_success_screen.dart';
import 'shipping_method_screen.dart';
import 'address_screen.dart';
import '../utils/order_data.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  /// Opsional: id metode pembayaran/pengiriman yang sudah dipilih sebelumnya
  /// (mis. dilempar langsung lewat Navigator oleh halaman lain). Backend
  /// butuh ID integer, bukan nama string.
  final int? paymentMethodId;
  final int? shippingMethodId;

  const CheckoutScreen({
    super.key,
    required this.items,
    this.paymentMethodId,
    this.shippingMethodId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ApiService _api = ApiService();

  String _selectedPaymentMethod = 'DANA';
  int? _selectedPaymentMethodId;

  String _selectedShippingName = 'Hemat Kargo - SPX Hemat';
  String _selectedShippingDesc = 'Estimasi tiba: 20 - 25 Okt';
  int _shippingPrice = 10000;
  int? _selectedShippingMethodId;

  bool _isPlacingOrder = false;

  // Daftar metode dari backend (dipakai untuk mencocokkan nama -> id selama
  // payment_method_screen.dart/shipping_method_screen.dart masih
  // mengembalikan nama saja, bukan id langsung).
  List<Map<String, dynamic>> _paymentMethods = [];
  List<Map<String, dynamic>> _shippingMethods = [];

  final Color maroonColor = const Color(0xFF5D1A1A);

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethodId = widget.paymentMethodId;
    _selectedShippingMethodId = widget.shippingMethodId;
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    try {
      final payments = await _api.get('/payment-methods');
      final shippings = await _api.get('/shipping-methods');
      if (!mounted) return;
      setState(() {
        _paymentMethods = List<Map<String, dynamic>>.from(payments is List ? payments : []);
        _shippingMethods = List<Map<String, dynamic>>.from(shippings is List ? shippings : []);
      });
    } catch (e) {
      print('Error loading payment/shipping methods: $e');
    }
  }

  int? _findPaymentMethodId(String name) {
    for (final m in _paymentMethods) {
      if (m['name'] == name) return m['id'] as int?;
    }
    return null;
  }

  int? _findShippingMethodId(String name) {
    for (final m in _shippingMethods) {
      if (m['name'] == name) return m['id'] as int?;
    }
    return null;
  }

  List<int> get _cartItemIds {
    return widget.items
        .where((item) => item['id'] != null)
        .map((item) => item['id'] is int ? item['id'] as int : int.parse(item['id'].toString()))
        .toList();
  }

  int get _totalPrice {
    return widget.items.fold(0, (sum, item) {
      int price = int.parse(item['price'].toString().replaceAll('.', ''));
      return sum + (price * (item['quantity'] as int));
    });
  }

  @override
  Widget build(BuildContext context) {
    String totalStr = 'Rp ${_totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5D1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Checkout',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Address Section
              _buildSectionTitle('Alamat Pengiriman'),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressScreen())),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF5D1A1A), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Vanya | (+62) 812 3456 7890', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('jl.Mawar No. 20, RT 05/RW 07, Kel. Cempaka Putih, Muara Satu, Kota Lhokseumawe, Aceh, 12410', 
                                 style: GoogleFonts.outfit(color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const Divider(height: 40),

              // 2. Products Section
              _buildSectionTitle('Pesanan Anda'),
              ...widget.items.map((item) => _buildProductItem(item)).toList(),
              const Divider(height: 40),

              // 3. Shipping Info Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Opsi Pengiriman', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black)),
                    GestureDetector(
                      onTap: _pickShippingMethod,
                      child: Text('Lihat Semua', style: GoogleFonts.outfit(color: maroonColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _pickShippingMethod,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, color: Color(0xFF5D1A1A), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedShippingName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(_selectedShippingDesc, style: GoogleFonts.outfit(color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('Rp ${_shippingPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}', 
                           style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const Divider(height: 40),

              // 4. Payment Method
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Metode Pembayaran', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black)),
                    GestureDetector(
                      onTap: _pickPaymentMethod,
                      child: Text('Lihat Semua', style: GoogleFonts.outfit(color: maroonColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap: _pickPaymentMethod,
                leading: Icon(_getPaymentIcon(), color: const Color(0xFF5D1A1A)),
                title: Text(_selectedPaymentMethod, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              ),
              const Divider(height: 40),

              // 4. Order Summary
              _buildSectionTitle('Ringkasan Pembayaran'),
              _buildSummaryRow('Subtotal Produk', totalStr),
              _buildSummaryRow('Biaya Pengiriman', 'Rp ${_shippingPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Divider(),
              ),
              _buildSummaryRow('Total Pembayaran', 'Rp ${(_totalPrice + _shippingPrice).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}', isTotal: true),
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomAction(totalStr),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black)),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    String priceStr = 'Rp ${item['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item['image'].toString().startsWith('assets/')
                ? Image.asset(item['image'], width: 70, height: 70, fit: BoxFit.cover)
                : Image.network(
                    item['image'],
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
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(item['desc'] ?? 'Varian: ${item['selectedColor'] ?? item['color'] ?? 'Default'}, ${item['selectedSize'] ?? item['size'] ?? 'M'}', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(priceStr, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF5D1A1A))),
                    Text('x${item['quantity']}', style: GoogleFonts.outfit(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: isTotal ? 16 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: GoogleFonts.outfit(fontSize: isTotal ? 18 : 13, fontWeight: FontWeight.bold, color: isTotal ? const Color(0xFF5D1A1A) : Colors.black)),
        ],
      ),
    );
  }

  IconData _getPaymentIcon() {
    if (_selectedPaymentMethod.contains('Bank')) return Icons.account_balance;
    if (_selectedPaymentMethod.contains('COD')) return Icons.handshake;
    return Icons.account_balance_wallet;
  }

  Future<void> _pickPaymentMethod() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentMethodScreen()),
    );
    if (result == null) return;

    // Sudah support id langsung (mis. {'id': 1, 'name': 'DANA'}).
    if (result is Map) {
      setState(() {
        if (result['name'] != null) _selectedPaymentMethod = result['name'].toString();
        if (result['id'] != null) _selectedPaymentMethodId = result['id'] as int;
      });
      return;
    }

    // Masih mengembalikan nama saja (versi lama) -> cocokkan ke daftar
    // metode pembayaran dari backend untuk dapat id-nya.
    final name = result.toString();
    setState(() {
      _selectedPaymentMethod = name;
      _selectedPaymentMethodId = _findPaymentMethodId(name);
    });
  }

  Future<void> _pickShippingMethod() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShippingMethodScreen()),
    );
    if (result == null || result is! Map) return;

    setState(() {
      _selectedShippingName = result['name'] ?? _selectedShippingName;
      _selectedShippingDesc = result['desc'] ?? _selectedShippingDesc;
      _shippingPrice = result['price'] is int ? result['price'] as int : _shippingPrice;
      if (result['id'] != null) {
        _selectedShippingMethodId = result['id'] as int;
      } else {
        _selectedShippingMethodId = _findShippingMethodId(_selectedShippingName);
      }
    });
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;

    final cartItemIds = _cartItemIds;
    if (cartItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item pesanan tidak valid, silakan kembali ke keranjang.')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);
    try {
      final order = await OrderData.addOrder(
        cartItemIds: cartItemIds,
        paymentMethodId: _selectedPaymentMethodId,
        shippingMethodId: _selectedShippingMethodId,
      );

      // Backend sudah otomatis menghapus cart item yang dipakai, jadi tidak
      // perlu CartData.deleteItem lagi di sini.

      if (!mounted) return;
      final paymentMethod = order['payment_method'];
      final isCod = paymentMethod is Map && paymentMethod['type'] == 'cod';
      if (isCod) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OrderSuccessScreen()));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PaymentInstructionScreen(order: order)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat pesanan. Periksa koneksi jaringan.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  Widget _buildBottomAction(String total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Pembayaran', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              Text('Rp ${(_totalPrice + _shippingPrice).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}', 
                   style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF5D1A1A))),
            ],
          ),
          ElevatedButton(
            onPressed: _isPlacingOrder ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isPlacingOrder
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Buat Pesanan', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
