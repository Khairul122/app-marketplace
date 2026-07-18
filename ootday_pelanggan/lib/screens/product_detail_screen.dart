import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';
import '../utils/cart_data.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, String> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'M';
  String _selectedColor = 'Default';
  int _selectedColorIndex = 0;
  int _currentPage = 0;
  int _quantity = 1;
  int _cartCount = 0;
  bool _isSubmitting = false;
  final PageController _pageController = PageController();

  List<String> _images = [];
  List<String> _sizes = [];
  List<String> _colors = [];
  List<Map<String, dynamic>> _variants = [];
  bool _isLoading = true;

  /// Cari variant yang cocok dengan size & color yang dipilih. Kalau kombinasi
  /// persis tidak ada (mis. data variant tidak lengkap cross-product), jatuh
  /// ke variant dengan color yang sama, lalu size yang sama, lalu apa saja.
  Map<String, dynamic>? get _selectedVariant {
    if (_variants.isEmpty) return null;
    for (final v in _variants) {
      if ((v['size'] ?? '') == _selectedSize && (v['color'] ?? '') == _selectedColor) {
        return v;
      }
    }
    for (final v in _variants) {
      if ((v['color'] ?? '') == _selectedColor) return v;
    }
    for (final v in _variants) {
      if ((v['size'] ?? '') == _selectedSize) return v;
    }
    return _variants.first;
  }

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
    _refreshCartCount();
  }

  Future<void> _refreshCartCount() async {
    try {
      final cartItems = await CartData.getCartItems();
      final count = cartItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
      if (mounted) {
        setState(() {
          _cartCount = count;
        });
      }
    } catch (e) {
      print('Error fetching cart count: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetails() async {
    try {
      final String? productId = widget.product['id'];
      if (productId == null) {
        setState(() {
          _images = [widget.product['image'] ?? 'assets/images/Produk_1.png'];
          _sizes = ['S', 'M', 'L', 'XL'];
          _colors = ['Default'];
          _isLoading = false;
        });
        return;
      }

      final detail = await ApiService().get('/products/$productId');

      final List rawImages = detail['images'] as List? ?? [];
      final List<String> loadedImages = rawImages
          .map((img) => CartData.resolveImageUrl(img['image_url'] as String?))
          .toList();
      if (loadedImages.isEmpty) {
        loadedImages.add(widget.product['image'] ?? 'assets/images/Produk_1.png');
      }

      final List rawVariants = detail['variants'] as List? ?? [];
      final List<Map<String, dynamic>> loadedVariants =
          rawVariants.map((v) => Map<String, dynamic>.from(v as Map)).toList();

      final Set<String> loadedSizes = {};
      final Set<String> loadedColors = {};
      for (var row in loadedVariants) {
        if (row['size'] != null && row['size'].toString().isNotEmpty) {
          loadedSizes.add(row['size'].toString());
        }
        if (row['color'] != null && row['color'].toString().isNotEmpty) {
          loadedColors.add(row['color'].toString());
        }
      }

      if (mounted) {
        setState(() {
          _images = loadedImages;
          _sizes = loadedSizes.isNotEmpty ? loadedSizes.toList() : ['S', 'M', 'L', 'XL'];
          _colors = loadedColors.isNotEmpty ? loadedColors.toList() : ['Default'];
          _variants = loadedVariants;

          if (_sizes.isNotEmpty) {
            _selectedSize = _sizes.contains('M') ? 'M' : _sizes.first;
          }
          if (_colors.isNotEmpty) {
            _selectedColor = _colors.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading product details: $e');
      if (mounted) {
        setState(() {
          _images = [widget.product['image'] ?? 'assets/images/Produk_1.png'];
          _sizes = ['S', 'M', 'L', 'XL'];
          _colors = ['Default'];
          _isLoading = false;
        });
      }
    }
  }

  /// Skema keranjang backend berbasis variant, jadi kita perlu tahu
  /// `variant_id` dari kombinasi size/color yang dipilih user sebelum
  /// menambahkan ke keranjang atau checkout (bukan product_id langsung
  /// seperti versi lama).
  Future<void> _confirmVariantSelection(String buttonText) async {
    final variant = _selectedVariant;
    if (variant == null || variant['id'] == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Varian produk tidak tersedia.')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Baik "Beli Sekarang" maupun "Masukkan Keranjang" sama-sama harus
      // lewat cart terlebih dahulu, karena backend POST /orders butuh
      // cart_item_ids (bukan payload item manual).
      final cartItem = await CartData.addItem({
        'variant_id': variant['id'],
        'quantity': _quantity,
      });
      await _refreshCartCount();

      if (!mounted) return;

      if (buttonText == 'Beli Sekarang') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutScreen(items: [cartItem]),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil ditambahkan ke keranjang')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan ke keranjang. Periksa koneksi jaringan.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showVariantSheet({required String buttonText}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            const Color maroonColor = Color(0xFFB01D1D);
            const Color lightBg = Color(0xFFF8F3F3);

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: lightBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  // 1. Header Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: _imageProviderFor(widget.product['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Rp ${widget.product['price']}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.close, color: Colors.black),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                              Text(
                                'Stok: ${widget.product['stock'] ?? '100'}',
                                style: GoogleFonts.outfit(
                                  color: Colors.black54, 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // 2. Content Sections
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          Text(
                            'Warna', 
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _colors.map((c) {
                              Color colorValue = Colors.grey;
                              if (c.toLowerCase() == 'hitam') colorValue = Colors.black;
                              else if (c.toLowerCase() == 'putih') colorValue = Colors.white;
                              else if (c.toLowerCase() == 'denim') colorValue = const Color(0xFF4B6584);
                              else if (c.toLowerCase() == 'coksu') colorValue = const Color(0xFFD2B48C);
                              
                              bool isSel = _selectedColor == c;
                              return GestureDetector(
                                onTap: () => setModalState(() {
                                  _selectedColor = c;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isSel ? maroonColor : Colors.grey[400]!, width: 1.5),
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSel ? Colors.white : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 15,
                                        height: 15,
                                        decoration: BoxDecoration(
                                          color: colorValue,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        c, 
                                        style: GoogleFonts.outfit(
                                          color: isSel ? maroonColor : Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 25),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ukuran', 
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Tabel Ukuran >', 
                                style: GoogleFonts.outfit(
                                  color: Colors.black54, 
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: _sizes.map((s) {
                              bool isSel = _selectedSize == s;
                              return GestureDetector(
                                onTap: () => setModalState(() => _selectedSize = s),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isSel ? maroonColor : Colors.grey[400]!, width: 1.5),
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSel ? Colors.white : Colors.transparent,
                                  ),
                                  child: Text(
                                    s, 
                                    style: GoogleFonts.outfit(
                                      color: isSel ? maroonColor : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 25),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Jumlah', 
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!, width: 1.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 18, color: Colors.black),
                                      onPressed: () {
                                        if (_quantity > 1) {
                                          setModalState(() {
                                            _quantity--;
                                          });
                                        }
                                      },
                                    ),
                                    Text(
                                      '$_quantity', 
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18, color: Colors.black),
                                      onPressed: () {
                                        setModalState(() {
                                          _quantity++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // 3. Confirm Button (Dynamic Text)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmVariantSelection(buttonText);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroonColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        buttonText == 'Beli Sekarang' ? 'Beli Sekarang' : 'Konfirmasi',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Gambar produk sekarang bisa berupa URL network (dari backend) atau
  /// asset lokal (fallback lama), jadi butuh provider/widget yang adaptif.
  ImageProvider _imageProviderFor(String? path) {
    final resolved = path ?? 'assets/images/Produk_1.png';
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return NetworkImage(resolved);
    }
    return AssetImage(resolved);
  }

  Widget _productImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.image, color: Colors.grey),
        ),
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image, color: Colors.grey),
      ),
    );
  }

  Widget _buildStoreTile(String label, {bool isSelected = false}) {
    const Color maroonColor = Color(0xFF5D1A1A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: isSelected ? maroonColor : Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: _imageProviderFor(widget.product['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13, 
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color lightBg = Color(0xFFF3F3F3);

    String priceString = widget.product['price'] ?? '0';
    String formattedPrice = 'Rp ${priceString.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Carousel Section
                  Stack(
                    children: [
                      SizedBox(
                        height: 450,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Hero(
                              tag: index == 0 ? (widget.product['id'] ?? 'product_${widget.product['name']}') : 'img_$index',
                              child: _productImage(_images[index], width: double.infinity, height: 450),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(15)),
                          child: Text('${_currentPage + 1}/${_images.length}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildCircleButton(Icons.arrow_back, () => Navigator.pop(context)),
                              Row(
                                children: [
                                  _buildCircleButton(Icons.share_outlined, () {}),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CartScreen()),
                                    ).then((_) => _refreshCartCount()),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                                          child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                                        ),
                                        if (_cartCount > 0)
                                          Positioned(
                                            right: -2,
                                            top: -2,
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: const BoxDecoration(color: Color(0xFFB01D1D), shape: BoxShape.circle),
                                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                              child: Text(
                                                '$_cartCount',
                                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildCircleButton(Icons.more_vert, () {}),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Pricing & Title
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(formattedPrice, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                            Row(
                              children: [
                                Text('${widget.product['sold'] ?? '120'} Terjual', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14)),
                                const SizedBox(width: 10),
                                const Icon(Icons.favorite_border, color: Colors.black, size: 24),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(widget.product['name'] ?? 'Produk Ootday', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black, height: 1.3)),
                      ],
                    ),
                  ),

                  // Variant - Warna
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Warna', style: GoogleFonts.outfit(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _colors.length,
                            itemBuilder: (context, index) {
                              final color = _colors[index];
                              final bool isSel = _selectedColor == color;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColor = color;
                                    _selectedColorIndex = index;
                                    if (index < _images.length) {
                                      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isSel ? maroonColor : Colors.grey.withOpacity(0.3), width: 2),
                                    image: DecorationImage(image: _imageProviderFor(widget.product['image']), fit: BoxFit.cover),
                                  ),
                                  alignment: Alignment.center,
                                  child: Container(
                                    color: Colors.black45,
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Text(
                                      color, 
                                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Variant - Ukuran
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ukuran', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black)),
                        const SizedBox(height: 12),
                        Row(
                          children: _sizes.map((size) {
                            bool isSelected = _selectedSize == size;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSize = size),
                              child: Container(
                                margin: const EdgeInsets.only(right: 15),
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? maroonColor.withOpacity(0.1) : lightBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isSelected ? maroonColor : Colors.transparent),
                                ),
                                child: Text(size, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isSelected ? maroonColor : Colors.black87)),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Description Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: lightBg.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Deskripsi Produk', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black)),
                          const SizedBox(height: 8),
                          Text(
                            widget.product['description'] ?? 'Koleksi fashion berkualitas tinggi dan nyaman dipakai sehari-hari.',
                            style: GoogleFonts.outfit(fontSize: 13, color: Colors.black, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
        bottomSheet: _isLoading ? null : Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(color: lightBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/icons msg.png',
                  width: 28,
                  height: 28,
                  color: const Color(0xFF5D1A1A),
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showVariantSheet(buttonText: 'masukkan keranjang'),
                child: _buildActionIcon(Icons.add_shopping_cart),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showVariantSheet(buttonText: 'Beli Sekarang'),
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Beli Dengan Harga', style: GoogleFonts.outfit(fontSize: 12, color: Colors.black)),
                          Text(formattedPrice, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 20)));
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(padding: const EdgeInsets.all(12), child: Icon(icon, color: const Color(0xFF5D1A1A), size: 28));
  }
}
