import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final ApiService _api = ApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _methods = [];
  Map<String, dynamic>? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _api.get('/payment-methods');
      final List rawList = (result is Map && result['data'] is List) ? result['data'] : result;
      final methods = List<Map<String, dynamic>>.from(rawList)
          .where((m) => m['is_active'] == null || m['is_active'] == true || m['is_active'] == 1)
          .toList();
      setState(() {
        _methods = methods;
        _isLoading = false;
        if (_methods.isNotEmpty) {
          _selectedMethod = _methods.first;
        }
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat metode pembayaran';
      });
    }
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'ewallet':
        return Icons.account_balance_wallet_outlined;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'cod':
        return Icons.handshake_outlined;
      default:
        return Icons.payment;
    }
  }

  String _labelForType(String? type) {
    switch (type) {
      case 'ewallet':
        return 'E-Wallet';
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'cod':
        return 'Bayar di Tempat';
      default:
        return 'Lainnya';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color lightBg = Color(0xFFF3F0F0);

    // Group methods by type while preserving backend order.
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final m in _methods) {
      final type = (m['type'] ?? 'lainnya').toString();
      grouped.putIfAbsent(type, () => []).add(m);
    }

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
            'Metode Pembayaran',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_errorMessage!, style: GoogleFonts.outfit(color: Colors.black54)),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _loadPaymentMethods,
                                style: ElevatedButton.styleFrom(backgroundColor: maroonColor),
                                child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : _methods.isEmpty
                          ? Center(
                              child: Text('Belum ada metode pembayaran tersedia', style: GoogleFonts.outfit(color: Colors.black54)),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final type in grouped.keys) ...[
                                    _buildSectionHeader(_labelForType(type), _iconForType(type)),
                                    for (final method in grouped[type]!)
                                      _buildPaymentItem(method),
                                    const SizedBox(height: 10),
                                  ],
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
            ),

            // Confirm Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _selectedMethod == null
                    ? null
                    : () => Navigator.pop(context, _selectedMethod),
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroonColor,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'KONFIRMASI',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 15),
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> method) {
    final bool isSelected = _selectedMethod != null && _selectedMethod!['id'] == method['id'];
    final String name = (method['name'] ?? '').toString();

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 30,
              alignment: Alignment.centerLeft,
              child: Icon(_iconForType(method['type']?.toString()), color: Colors.black87),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black : Colors.black87,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
              size: 16,
              color: isSelected ? const Color(0xFF5D1A1A) : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
