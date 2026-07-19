import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/cart_data.dart';
import '../services/api_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await CartData.getCartItems();
    if (mounted) {
      setState(() {
        _cartItems = items;
        _selectAll = _cartItems.isNotEmpty && _cartItems.every((e) => e['selected']);
        _isLoading = false;
      });
    }
  }

  int get _totalPrice {
    return _cartItems
        .where((item) => item['selected'])
        .fold(0, (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int));
  }

  void _toggleSelectAll(bool? value) async {
    final newValue = value ?? false;
    try {
      await CartData.updateSelectAll(newValue);
      setState(() {
        _selectAll = newValue;
        for (var item in _cartItems) {
          item['selected'] = _selectAll;
        }
      });
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal memperbarui keranjang.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFFB01D1D);
    const Color bgColor = Color(0xFFF8F3F3);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5D1A1A)),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Ubah',
                style: GoogleFonts.outfit(color: const Color(0xFF5D1A1A), fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: Image.asset(
                'assets/images/icons msg.png',
                width: 24,
                height: 24,
                color: const Color(0xFF5D1A1A),
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Keranjang Saya',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D1A1A),
                          ),
                        ),
                        Text(
                          '${_cartItems.length} items',
                          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _cartItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text('Keranjang Anda kosong', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return _buildCartItem(item, index);
                            },
                          ),
                  ),
                ],
              ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Checkbox(
                  value: _selectAll,
                  onChanged: _toggleSelectAll,
                  activeColor: maroonColor,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                Text('semua', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Harga',
                      style: GoogleFonts.outfit(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Rp ${_totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, height: 1.1),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                SizedBox(
                  width: 130,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedItems = _cartItems.where((item) => item['selected']).toList();
                      if (selectedItems.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(items: selectedItems),
                          ),
                        ).then((_) => _loadCart());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pilih produk terlebih dahulu!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroonColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      'Checkout',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    const Color maroonColor = Color(0xFFB01D1D);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Checkbox(
            value: item['selected'],
            onChanged: (value) async {
              try {
                await CartData.updateSelection(item['id'].toString(), value!);
                setState(() {
                  item['selected'] = value;
                  _selectAll = _cartItems.every((e) => e['selected']);
                });
              } on ApiException catch (e) {
                _showError(e.message);
              } catch (_) {
                _showError('Gagal memperbarui keranjang.');
              }
            },
            activeColor: maroonColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: item['image'].toString().startsWith('assets/')
                ? Image.asset(
                    item['image'],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                  )
                : Image.network(
                    item['image'],
                    headers: const {'localtonet-skip-warning': 'true'},
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                Text(
                  item['desc'],
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${item['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _buildQtyBtn(Icons.remove, () async {
                            if (item['quantity'] > 1) {
                              final newQty = item['quantity'] - 1;
                              try {
                                await CartData.updateQuantity(item['id'].toString(), newQty);
                                setState(() {
                                  item['quantity'] = newQty;
                                });
                              } on ApiException catch (e) {
                                _showError(e.message);
                              } catch (_) {
                                _showError('Gagal memperbarui jumlah.');
                              }
                            }
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${item['quantity']}',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                            ),
                          ),
                          _buildQtyBtn(Icons.add, () async {
                            final newQty = item['quantity'] + 1;
                            try {
                              await CartData.updateQuantity(item['id'].toString(), newQty);
                              setState(() {
                                item['quantity'] = newQty;
                              });
                            } on ApiException catch (e) {
                              _showError(e.message);
                            } catch (_) {
                              _showError('Gagal memperbarui jumlah.');
                            }
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: Colors.black54),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey, size: 30),
    );
  }
}
