import 'package:flutter/material.dart';

class PengaturanKomunikasi extends StatelessWidget {
  const PengaturanKomunikasi({super.key});

  final Color redMain = const Color(0xFF5D1A1A);
  final Color darkRed = const Color(0xFF7A0000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),

          /// ================= CONTENT (NO SCROLL) =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Peraturan Komunikasi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Aturan dan pedoman komunikasi dengan pelanggan',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 4, 4, 4),
                  ),
                ),
                const SizedBox(height: 16),

                _expansionSection(
                  title: '1. Waktu Respon',
                  children: [
                    _contentText(
                        'Respon maksimal 2 jam pada hari kerja (09:00–18:00 WIB).'),
                    _contentText(
                        'Akhir pekan & hari libur maksimal 4 jam.'),
                  ],
                ),

                _expansionSection(
                  title: '2. Etika Komunikasi',
                  children: [
                    _contentText(
                        'Gunakan sapaan ramah dan sopan kepada pelanggan.'),
                    _contentText(
                        'Gunakan bahasa Indonesia yang baik dan jelas.'),
                    _contentText(
                        'Tetap profesional dan tidak emosional.'),
                  ],
                ),

                _expansionSection(
                  title: '3. Informasi Produk',
                  children: [
                    _contentText(
                        'Sampaikan informasi produk dengan akurat.'),
                    _contentText(
                        'Update stok secara berkala.'),
                  ],
                ),

                _expansionSection(
                  title: '4. Penanganan Keluhan',
                  children: [
                    _contentText(
                        'Dengarkan keluhan pelanggan dengan baik.'),
                    _contentText(
                        'Berikan solusi dan estimasi yang jelas.'),
                    _contentText(
                        'Lakukan follow up setelah masalah selesai.'),
                  ],
                ),

                _expansionSection(
                  title: '5. Privasi & Keamanan',
                  children: [
                    _contentText(
                        'Jaga kerahasiaan data pelanggan.'),
                    _contentText(
                        'Jangan meminta data sensitif melalui chat.'),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: redMain.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: redMain.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: redMain),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pelanggaran dapat mengakibatkan sanksi atau penangguhan akun.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= HEADER =================
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 48, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [redMain, darkRed],
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
            'Peraturan Komunikasi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= EXPANSION SECTION =================
  Widget _expansionSection({
    required String title,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: redMain,
        ),
      ),
      children: children,
    );
  }

  Widget _contentText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Text(
        '• $text',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          height: 1.4,
        ),
      ),
    );
  }
}
