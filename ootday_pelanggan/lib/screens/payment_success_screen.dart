import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'my_orders_screen.dart';

/// Halaman konfirmasi sukses pembayaran. Menerima data order opsional
/// (hasil `POST /orders` / `GET /orders/{id}`) untuk menampilkan
/// no. pesanan & total alih-alih hanya pesan statis.
class PaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic>? order;
  const PaymentSuccessScreen({super.key, this.order});

  String get _orderCode => (order?['order_code'] ?? '').toString();

  String get _totalFormatted {
    if (order == null) return '';
    final total = num.tryParse((order?['total_price'] ?? 0).toString()) ?? 0;
    return 'Rp ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration from user reference
              Image.asset(
                'assets/images/pymt_done.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle_outline, size: 100, color: maroonColor),
              ),
              const SizedBox(height: 20),
              Text(
                'Pembayaran berhasil',
                style: GoogleFonts.outfit(
                  color: maroonColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Yey, pembayaran berhasil\nPesanan akan segera dibuat',
                style: GoogleFonts.outfit(
                  color: maroonColor.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (order != null && _orderCode.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'No. Pesanan: $_orderCode',
                  style: GoogleFonts.outfit(color: maroonColor, fontSize: 13, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                if (_totalFormatted.isNotEmpty)
                  Text(
                    'Total: $_totalFormatted',
                    style: GoogleFonts.outfit(color: maroonColor, fontSize: 13, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
              ],
              const SizedBox(height: 80),

              // Action Buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroonColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Kembali ke Beranda',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrdersScreen(initialTabIndex: 1)), // Go to 'Diproses'
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: maroonColor),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Lihat Pesanan',
                  style: GoogleFonts.outfit(color: maroonColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
