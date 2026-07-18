import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'order_success_screen.dart';

/// Menerima data order (hasil dari `POST /orders`) lewat constructor.
/// Minimal field yang dipakai: `id`, `order_code`, `total_price`,
/// `payment_method` (Map dengan `name`, opsional `type`).
class PaymentInstructionScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const PaymentInstructionScreen({super.key, required this.order});

  @override
  State<PaymentInstructionScreen> createState() => _PaymentInstructionScreenState();
}

class _PaymentInstructionScreenState extends State<PaymentInstructionScreen> {
  bool _isExpanded = true;
  final Color maroonColor = const Color(0xFF5D1A1A);
  final ApiService _api = ApiService();

  Map<String, dynamic> _order = {};

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _refreshOrder();
  }

  Future<void> _refreshOrder() async {
    final id = _order['id'];
    if (id == null) return;
    try {
      final result = await _api.get('/orders/$id');
      final data = (result is Map && result['data'] is Map) ? result['data'] : result;
      if (mounted && data is Map) {
        setState(() {
          _order = {..._order, ...Map<String, dynamic>.from(data)};
        });
      }
    } catch (_) {
      // Biarkan pakai data order yang sudah ada bila refresh gagal.
    }
  }

  String get _bankName {
    final pm = _order['payment_method'];
    if (pm is Map && pm['name'] != null) return pm['name'].toString();
    return 'Bank';
  }

  String get _orderCode => (_order['order_code'] ?? '-').toString();

  String get _totalFormatted {
    final total = num.tryParse((_order['total_price'] ?? 0).toString()) ?? 0;
    return 'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  bool get _isBankTransfer {
    final pm = _order['payment_method'];
    if (pm is Map && pm['type'] != null) return pm['type'] == 'bank_transfer';
    return _bankName.toLowerCase().contains('bank') ||
        _bankName.toLowerCase().contains('bri') ||
        _bankName.toLowerCase().contains('bsi') ||
        _bankName.toLowerCase().contains('mandiri') ||
        _bankName.toLowerCase().contains('aceh');
  }

  // 1. Fungsi Pop-up Sukses
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/pymt_done.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (c, e, s) => Icon(Icons.check_circle_outline, size: 80, color: maroonColor),
                ),
                const SizedBox(height: 20),
                Text(
                  'Pembayaran berhasil',
                  style: GoogleFonts.outfit(color: maroonColor, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Yey, pembayaran berhasil\nPesanan akan segera dibuat',
                  style: GoogleFonts.outfit(color: maroonColor.withOpacity(0.7), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Tombol OK yang mengarah ke OrderSuccessScreen
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup Dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroonColor,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('OK', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color tealColor = Color(0xFF00BFA5);
    const Color vaColor = Color(0xFFD32F2F);

    String logoPath = 'assets/images/bank/bsi.png';
    final String bankNameLower = _bankName.toLowerCase();

    if (bankNameLower.contains('mandiri')) {
      logoPath = 'assets/images/bank/mandiri.png';
    } else if (bankNameLower.contains('bri')) {
      logoPath = 'assets/images/bank/bri.png';
    } else if (bankNameLower.contains('aceh')) {
      logoPath = 'assets/images/bank/aceh.png';
    } else if (bankNameLower.contains('dana')) {
      logoPath = 'assets/images/bank/dana.png';
    } else if (bankNameLower.contains('gopay')) {
      logoPath = 'assets/images/bank/gopay.png';
    } else if (bankNameLower.contains('ovo')) {
      logoPath = 'assets/images/bank/ovo.png';
    }

    // Nomor Virtual Account tidak disediakan backend, jadi kita turunkan dari
    // kode order supaya konsisten per-order tanpa mengarang data acak.
    final String vaNumber = _orderCode.isNotEmpty
        ? _orderCode.replaceAll(RegExp(r'[^0-9A-Za-z]'), '').padRight(12, '0').substring(0, 12)
        : '000000000000';

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
            icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 166, 15, 15)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Pembayaran',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset(logoPath, width: 40, height: 40, errorBuilder: (c, e, s) => Icon(Icons.account_balance, size: 40, color: tealColor)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        _bankName,
                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No. Pesanan', style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(_orderCode, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Text('Total Pembayaran', style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(_totalFormatted, style: GoogleFonts.outfit(color: maroonColor, fontSize: 20, fontWeight: FontWeight.bold)),
                    if (_isBankTransfer) ...[
                      const SizedBox(height: 16),
                      Text('No. Rek/Virtual Account', style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            vaNumber,
                            style: GoogleFonts.outfit(color: vaColor, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: vaNumber));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nomor VA $_bankName disalin!')));
                            },
                            child: Text('Salin', style: GoogleFonts.outfit(color: tealColor, fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Proses verifikasi kurang dari 10 menit setelah pembayaran berhasil', style: GoogleFonts.outfit(color: tealColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 15),
                    Text(
                      _isBankTransfer
                          ? 'Bayar pesanan ke Virtual Account di atas sebelum membuat pesanan kembali dengan Virtual Account agar nomor tetap sama.'
                          : 'Selesaikan pembayaran menggunakan $_bankName sesuai instruksi aplikasi pembayaranmu.',
                      style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
              if (_isBankTransfer) ...[
                Container(height: 10, color: Colors.grey[200]),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                            children: [
                              const TextSpan(text: 'Petunjuk Transfer mBankir '),
                              TextSpan(text: 'Ootday', style: GoogleFonts.outfit(color: maroonColor)),
                            ],
                          ),
                        ),
                        Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                if (_isExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        _buildStepRow(1, 'Pilih Pembayaran.'),
                        _buildStepRow(2, 'Pilih E-commerce > Ootday.'),
                        _buildStepRow(3, 'Pilih nomor rekening yang akan kamu gunakan.'),
                        _buildStepRow(4, 'Masukkan nomor Virtual Account $vaNumber, dan klik Selanjutnya.'),
                        _buildStepRow(5, 'Masukkan PIN Anda dan klik Selanjutnya.'),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 50),
              // Tombol OK di halaman yang memicu Pop-up
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _showSuccessDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroonColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('OK', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
            child: Center(child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87, height: 1.4))),
        ],
      ),
    );
  }
}
