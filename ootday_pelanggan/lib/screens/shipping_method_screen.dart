import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ShippingMethodScreen extends StatefulWidget {
  const ShippingMethodScreen({super.key});

  @override
  State<ShippingMethodScreen> createState() => _ShippingMethodScreenState();
}

class _ShippingMethodScreenState extends State<ShippingMethodScreen> {
  final ApiService _api = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _methods = [];

  @override
  void initState() {
    super.initState();
    _loadShippingMethods();
  }

  Future<void> _loadShippingMethods() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _api.get('/shipping-methods');
      final List rawList = (result is Map && result['data'] is List) ? result['data'] : result;
      final methods = List<Map<String, dynamic>>.from(rawList)
          .where((m) => m['is_active'] == null || m['is_active'] == true || m['is_active'] == 1)
          .toList();
      setState(() {
        _methods = methods;
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
        _errorMessage = 'Gagal memuat opsi pengiriman';
      });
    }
  }

  String _formatPrice(dynamic price) {
    final numValue = num.tryParse(price.toString()) ?? 0;
    return 'Rp ${numValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: maroonColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pilih Opsi Pengiriman',
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
                        onPressed: _loadShippingMethods,
                        style: ElevatedButton.styleFrom(backgroundColor: maroonColor),
                        child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : _methods.isEmpty
                  ? Center(
                      child: Text('Belum ada opsi pengiriman tersedia', style: GoogleFonts.outfit(color: Colors.black54)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      itemCount: _methods.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final method = _methods[index];
                        final priceStr = _formatPrice(method['base_cost']);

                        return ListTile(
                          onTap: () => Navigator.pop(context, method),
                          leading: const Icon(Icons.local_shipping_outlined, color: maroonColor),
                          title: Text((method['name'] ?? '').toString(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                          trailing: Text(priceStr, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: maroonColor)),
                        );
                      },
                    ),
    );
  }
}
