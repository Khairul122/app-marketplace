import 'package:flutter/material.dart';
import 'package:ootday_owner/detail_produk.dart';
import 'package:ootday_owner/services/product_service.dart';
import 'package:ootday_owner/tambah_produk_page.dart';

class ProfilProdukTab extends StatefulWidget {
  const ProfilProdukTab({super.key});

  @override
  State<ProfilProdukTab> createState() => ProfilProdukTabState();
}

class ProfilProdukTabState extends State<ProfilProdukTab> {
  final Color redMain = const Color(0xFF5D1A1A);
  final ProductService _productService = ProductService();

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productService.getMyProducts();
      if (!mounted) return;
      setState(() {
        _products = products.map((p) => Map<String, dynamic>.from(p as Map)).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5D1A1A)),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Belum ada produk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap tombol + di navbar untuk menambah produk pertama.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final added = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TambahProdukPage(),
                    ),
                  );
                  if (added == true) loadProducts();
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Produk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D1A1A),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: redMain,
      onRefresh: loadProducts,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            return _produkCard(context, _products[index]);
          },
        ),
      ),
    );
  }

  String _primaryImageUrl(Map<String, dynamic> product) {
    final images = product['images'];
    if (images is List && images.isNotEmpty) {
      final primary = images.firstWhere(
        (img) => img is Map && img['is_primary'] == true,
        orElse: () => images.first,
      );
      if (primary is Map && primary['image_url'] != null) {
        return primary['image_url'] as String;
      }
    }
    return '';
  }

  Widget _produkCard(BuildContext context, Map<String, dynamic> product) {
    final imageUrl = _primaryImageUrl(product);
    final productName = (product['name'] as String?) ?? 'Produk';
    final price = product['price'];
    final priceInt = price is num ? price.toInt() : int.tryParse('$price') ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailProduk(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(imageUrl),
                ),
              ),
            ),
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rp ${_formatPrice(priceInt)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: redMain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    }

    if (imageUrl.isNotEmpty) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    }

    return _placeholderImage();
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey.shade300),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
