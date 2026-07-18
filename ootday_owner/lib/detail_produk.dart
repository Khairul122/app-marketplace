import 'package:flutter/material.dart';

class DetailProduk extends StatelessWidget {
  /// Data produk asli dari API (`Map<String, dynamic>` hasil decode JSON),
  /// mengikuti bentuk yang dikembalikan `/my-products` atau `/products/{id}`:
  /// `{id, name, price, stock, description, images:[{image_url,...}], variants:[{size,color,stock}], category:{name}}`.
  final Map<String, dynamic> product;

  const DetailProduk({super.key, required this.product});

  static const Color redMain = Color(0xFF5D1A1A);
  static const Color darkRed = Color(0xFF7A0000);

  String get _name => (product['name'] as String?) ?? 'Produk';

  num get _price {
    final price = product['price'];
    if (price is num) return price;
    return num.tryParse('$price') ?? 0;
  }

  int get _stock {
    final stock = product['stock'];
    if (stock is num) return stock.toInt();
    return int.tryParse('$stock') ?? 0;
  }

  String get _description =>
      (product['description'] as String?)?.trim().isNotEmpty == true
          ? product['description'] as String
          : 'Belum ada deskripsi untuk produk ini.';

  String? get _categoryName {
    final category = product['category'];
    if (category is Map) return category['name'] as String?;
    return null;
  }

  List<String> get _imageUrls {
    final images = product['images'];
    if (images is List) {
      return images
          .map((img) => img is Map ? img['image_url'] as String? : null)
          .whereType<String>()
          .toList();
    }
    return [];
  }

  List<Map<String, dynamic>> get _variants {
    final variants = product['variants'];
    if (variants is List) {
      return variants.map((v) => Map<String, dynamic>.from(v as Map)).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final images = _imageUrls;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk
                  Container(
                    width: double.infinity,
                    height: 320,
                    decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
                    child: images.isNotEmpty
                        ? PageView.builder(
                            itemCount: images.length,
                            itemBuilder: (context, index) => Image.network(
                              images[index],
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _imagePlaceholder(),
                            ),
                          )
                        : _imagePlaceholder(),
                  ),
                  // Detail Produk
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (_categoryName != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _categoryName!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          'Rp ${_formatPrice(_price)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: redMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Stok: $_stock',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        const Text(
                          'Deskripsi Produk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        if (_variants.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 24),
                          const Text(
                            'Varian',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _variants.map((variant) {
                              final size = variant['size'] ?? '-';
                              final color = variant['color'] ?? '-';
                              final stock = variant['stock'] ?? 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  '$size / $color (stok: $stock)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkRed, redMain],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            const SizedBox(width: 8),
            const Text(
              'Detail Produk',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(num price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Icon(Icons.image, size: 100, color: Colors.grey.shade400),
      ),
    );
  }
}
