import 'package:flutter/material.dart';
import 'package:ootday_owner/services/api_service.dart';
import 'package:ootday_owner/services/product_service.dart';
import 'package:ootday_owner/edit_produk_page.dart';

class DetailProduk extends StatefulWidget {
  /// Data produk asli dari API (`Map<String, dynamic>` hasil decode JSON),
  /// mengikuti bentuk yang dikembalikan `/my-products` atau `/products/{id}`:
  /// `{id, name, price, stock, description, images:[{image_url,...}], variants:[{size,color,stock}], category:{name}}`.
  final Map<String, dynamic> product;
  final bool enableEditDelete;

  const DetailProduk({
    super.key,
    required this.product,
    this.enableEditDelete = true,
  });

  static const Color redMain = Color(0xFF5D1A1A);
  static const Color darkRed = Color(0xFF7A0000);

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  late Map<String, dynamic> _product;
  final ProductService _productService = ProductService();
  final PageController _imageController = PageController();
  
  List<String> _allImages = [];
  Map<String, dynamic>? _selectedVariant;
  int _currentImage = 0;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _initializeImages();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  void _initializeImages() {
    final List<String> list = [];
    
    // 1. Tambahkan semua gambar produk utama
    final images = _product['images'] as List?;
    if (images != null) {
      for (final img in images) {
        if (img is Map && img['image_url'] != null) {
          final url = ApiService.resolveImageUrl(img['image_url'] as String?);
          if (url.isNotEmpty && !list.contains(url)) {
            list.add(url);
          }
        }
      }
    }
    
    // 2. Tambahkan gambar dari varian-varian produk agar bisa di-scroll di galeri utama
    final variants = _product['variants'] as List?;
    if (variants != null) {
      for (final v in variants) {
        if (v is Map && v['image_url'] != null) {
          final url = ApiService.resolveImageUrl(v['image_url'] as String?);
          if (url.isNotEmpty && !list.contains(url)) {
            list.add(url);
          }
        }
      }
    }
    
    setState(() {
      _allImages = list;
    });
  }

  String get _name => (_product['name'] as String?) ?? 'Produk';

  num get _price {
    final price = _product['price'];
    if (price is num) return price;
    return double.tryParse('$price') ?? 0;
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
      _initializeImages();
    }
  }

  void _onVariantTapped(Map<String, dynamic> variant) {
    setState(() {
      _selectedVariant = variant;
    });

    final variantImg = variant['image_url'] as String?;
    if (variantImg != null && variantImg.isNotEmpty) {
      final url = ApiService.resolveImageUrl(variantImg);
      final index = _allImages.indexOf(url);
      if (index != -1) {
        _imageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Shopee grey background
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
                        _buildImageCarousel(),
                        _buildInfoSection(),
                        if (_variants.isNotEmpty) _buildVariantSection(),
                        _buildDescriptionSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: double.infinity,
          height: 360,
          color: const Color(0xFFF9F9F9),
          child: _allImages.isNotEmpty
              ? PageView.builder(
                  controller: _imageController,
                  onPageChanged: (index) => setState(() => _currentImage = index),
                  itemCount: _allImages.length,
                  itemBuilder: (context, index) => Image.network(
                    _allImages[index],
                    headers: const {'localtonet-skip-warning': 'true'},
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  ),
                )
              : _imagePlaceholder(),
        ),
        if (_allImages.isNotEmpty)
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentImage + 1}/${_allImages.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price formatted with bigger fonts like Shopee
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Rp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: DetailProduk.redMain,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                _formatPrice(_price),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: DetailProduk.redMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Product Name
          Text(
            _name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          // Category and Stock Row
          Row(
            children: [
              if (_categoryName != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DetailProduk.redMain.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _categoryName!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: DetailProduk.redMain,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'Total Stok: $_stock',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariantSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilihan Varian (Ketuk varian untuk melihat gambar)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _variants.length,
            separatorBuilder: (_, __) => Divider(color: Colors.grey.shade100, height: 16),
            itemBuilder: (context, index) {
              final variant = _variants[index];
              final isSelected = _selectedVariant != null &&
                  _selectedVariant!['attribute1_value'] == variant['attribute1_value'] &&
                  _selectedVariant!['attribute2_value'] == variant['attribute2_value'];

              final attribute1Name = variant['attribute1_name'] ?? 'Varian';
              final attribute1Value = variant['attribute1_value'] ?? '-';
              final attribute2Name = variant['attribute2_name'];
              final attribute2Value = variant['attribute2_value'];
              final stock = variant['stock'] ?? 0;
              final variantImg = variant['image_url'] as String?;
              final priceAdjustment = variant['price_adjustment'];
              final priceAdjustmentNum = priceAdjustment is num 
                  ? priceAdjustment 
                  : (double.tryParse('$priceAdjustment') ?? 0);

              final nameText = (attribute2Value != null && '$attribute2Value'.isNotEmpty)
                  ? '$attribute1Name: $attribute1Value / $attribute2Name: $attribute2Value'
                  : '$attribute1Name: $attribute1Value';

              return GestureDetector(
                onTap: () => _onVariantTapped(variant),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? DetailProduk.redMain.withOpacity(0.04) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? DetailProduk.redMain : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Variant Image with bigger display
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: variantImg != null && variantImg.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(
                                  ApiService.resolveImageUrl(variantImg),
                                  headers: const {'localtonet-skip-warning': 'true'},
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 24, color: Colors.grey),
                                ),
                              )
                            : const Icon(Icons.image, size: 24, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      // Variant Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameText,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? DetailProduk.redMain : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stok: $stock pcs',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Price Adjustment
                      if (priceAdjustmentNum != 0)
                        Text(
                          priceAdjustmentNum > 0 
                              ? '+Rp ${_formatPrice(priceAdjustmentNum)}' 
                              : '-Rp ${_formatPrice(priceAdjustmentNum.abs())}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: priceAdjustmentNum > 0 ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi Produk',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _description,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade700,
              height: 1.5,
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
            if (!_isDeleting && widget.enableEditDelete) ...[
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
