import 'package:flutter/material.dart';
import 'package:ootday_owner/services/api_service.dart';
import 'package:ootday_owner/services/product_service.dart';
import 'package:ootday_owner/edit_produk_page.dart';

class DetailProduk extends StatefulWidget {
  /// Data produk asli dari API (`Map<String, dynamic>` hasil decode JSON),
  /// mengikuti bentuk yang dikembalikan `/my-products` atau `/products/{id}`:
  /// `{id, name, price, stock, description, images:[{image_url,...}], variants:[{size,color,stock}], category:{name}}`.
  final Map<String, dynamic> product;

  const DetailProduk({super.key, required this.product});

  static const Color redMain = Color(0xFF5D1A1A);
  static const Color darkRed = Color(0xFF7A0000);

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  late Map<String, dynamic> _product;
  final ProductService _productService = ProductService();
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  String get _name => (_product['name'] as String?) ?? 'Produk';

  num get _price {
    final price = _product['price'];
    if (price is num) return price;
    return num.tryParse('$price') ?? 0;
  }

  int get _stock {
    final stock = _product['stock'];
    if (stock is num) return stock.toInt();
    return int.tryParse('$stock') ?? 0;
  }

  String get _description =>
      (_product['description'] as String?)?.trim().isNotEmpty == true
          ? _product['description'] as String
          : 'Belum ada deskripsi untuk produk ini.';

  String? get _categoryName {
    final category = _product['category'];
    if (category is Map) return category['name'] as String?;
    return null;
  }

  List<String> get _imageUrls {
    final images = _product['images'];
    if (images is List) {
      return images
          .map((img) => img is Map ? ApiService.resolveImageUrl(img['image_url'] as String?) : null)
          .whereType<String>()
          .toList();
    }
    return [];
  }

  List<Map<String, dynamic>> get _variants {
    final variants = _product['variants'];
    if (variants is List) {
      return variants.map((v) => Map<String, dynamic>.from(v as Map)).toList();
    }
    return [];
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Produk?'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus produk ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await _productService.deleteProduct(_product['id'] as int);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil dihapus'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); // Pop dengan true agar grid disegarkan
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus produk: ${e is ApiException ? e.message : e}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editProduct() async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProdukPage(product: _product),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _product = updated;
      });
    }
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
            child: _isDeleting
                ? const Center(child: CircularProgressIndicator(color: DetailProduk.redMain))
                : SingleChildScrollView(
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
                                  color: DetailProduk.redMain,
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
                                    final variantImg = variant['image_url'] as String?;

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
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (variantImg != null && variantImg.isNotEmpty) ...[
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: Image.network(
                                                ApiService.resolveImageUrl(variantImg),
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 16),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Text(
                                            '$size / $color (stok: $stock)',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
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
          colors: [DetailProduk.darkRed, DetailProduk.redMain],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, _product != widget.product);
                }
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Detail Produk',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!_isDeleting) ...[
              IconButton(
                onPressed: _editProduct,
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'Edit Produk',
              ),
              IconButton(
                onPressed: _deleteProduct,
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                tooltip: 'Hapus Produk',
              ),
            ],
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
