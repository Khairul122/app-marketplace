import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_detail_screen.dart';
import '../services/api_service.dart';
import '../utils/cart_data.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchQuery;
  const SearchResultScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  String _selectedCategory = 'Terkait';
  String _priceSort = 'none'; // 'none', 'asc', 'desc'
  late TextEditingController _searchController;
  late String _currentQuery;
  
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.searchQuery;
    _searchController = TextEditingController(text: _currentQuery);
    _searchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Backend belum dukung sorting server-side (by harga/populer/terbaru),
      // jadi kita hanya kirim query pencarian lalu urutkan hasilnya di client.
      final result = await ApiService().get(
        '/products?q=${Uri.encodeComponent(_currentQuery)}',
      );

      List<Map<String, dynamic>> results =
          List<Map<String, dynamic>>.from(result is List ? result : []);
      results = _applyClientSort(results);

      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      print('Error searching products: ${e.message}');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      print('Error searching products: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _applyClientSort(List<Map<String, dynamic>> results) {
    final sorted = List<Map<String, dynamic>>.from(results);
    if (_selectedCategory == 'Terbaru') {
      sorted.sort((a, b) => (b['id'] as num? ?? 0).compareTo(a['id'] as num? ?? 0));
    } else if (_selectedCategory == 'Terlaris') {
      sorted.sort((a, b) => (b['sold_count'] as num? ?? 0).compareTo(a['sold_count'] as num? ?? 0));
    } else if (_selectedCategory == 'Harga' && _priceSort == 'asc') {
      sorted.sort((a, b) =>
          (double.tryParse(a['price'].toString()) ?? 0).compareTo(double.tryParse(b['price'].toString()) ?? 0));
    } else if (_selectedCategory == 'Harga' && _priceSort == 'desc') {
      sorted.sort((a, b) =>
          (double.tryParse(b['price'].toString()) ?? 0).compareTo(double.tryParse(a['price'].toString()) ?? 0));
    }
    return sorted;
  }

  void _togglePriceSort() {
    setState(() {
      if (_priceSort == 'none') {
        _priceSort = 'asc';
      } else if (_priceSort == 'asc') {
        _priceSort = 'desc';
      } else {
        _priceSort = 'none';
      }
    });
    _searchProducts();
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color bgColor = Color(0xFFF8F3F3);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: maroonColor, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: maroonColor.withOpacity(0.5), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    _currentQuery = value;
                                  });
                                  _searchProducts();
                                }
                              },
                              style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 13),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          Icon(Icons.photo_camera_outlined, color: maroonColor.withOpacity(0.5), size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: maroonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, size: 20, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFilterTab('Terkait', maroonColor),
                  _buildFilterTab('Terbaru', maroonColor),
                  _buildFilterTab('Terlaris', maroonColor),
                  _buildFilterTab('Harga', maroonColor),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Results Grid atau Empty State
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isNotEmpty
                      ? GridView.builder(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 30),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            return _buildResultCard(_results[index], maroonColor);
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 80,
                                color: maroonColor.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Produk Tidak Ditemukan',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: maroonColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Maaf, "$_currentQuery" saat ini belum tersedia.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, Color maroonColor) {
    bool isActive = _selectedCategory == label;
    bool isPrice = label == 'Harga';
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          if (isPrice) {
            _togglePriceSort();
          } else {
            _priceSort = 'none';
            _searchProducts();
          }
        });
      },
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                  color: isActive ? maroonColor : Colors.grey,
                ),
              ),
              if (isPrice) ...[
                const SizedBox(width: 4),
                Column(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up,
                      size: 12,
                      color: _priceSort == 'asc' ? maroonColor : Colors.grey,
                    ),
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 12,
                        color: _priceSort == 'desc' ? maroonColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            width: isActive ? 20 : 0,
            color: maroonColor,
          ),
        ],
      ),
    );
  }

  String _primaryImage(Map<String, dynamic> product) {
    final images = product['images'] as List? ?? [];
    if (images.isEmpty) return CartData.resolveImageUrl(null);
    final primary = images.firstWhere(
      (img) => img['is_primary'] == true,
      orElse: () => images.first,
    );
    return CartData.resolveImageUrl(primary['image_url'] as String?);
  }

  Widget _buildResultCard(Map<String, dynamic> product, Color maroonColor) {
    final String name = product['name'] ?? '';
    final String imageUrl = _primaryImage(product);

    // Rating mock/generated or random between 4.5 and 5.0
    final int idNum = product['id'] ?? 0;
    final String rating = (4.5 + (idNum % 6) * 0.1).toStringAsFixed(1);
    final String sold = (30 + ((idNum * 23) % 150)).toString();

    final String priceStr = product['price'].toString().replaceAll(RegExp(r'\.0+$'), '');
    String formattedPrice = 'Rp ${priceStr.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: {
              'id': product['id'].toString(),
              'name': name,
              'price': priceStr,
              'image': imageUrl,
              'description': product['description'] ?? '',
              'stock': product['stock']?.toString() ?? '0',
            }),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        headers: const {'localtonet-skip-warning': 'true'},
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: GoogleFonts.outfit(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedPrice,
                    style: GoogleFonts.outfit(fontSize: 14, color: maroonColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 10,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$sold Terjual',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
