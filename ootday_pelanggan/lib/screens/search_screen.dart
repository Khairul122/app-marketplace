import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'search_result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color bgColor = Color(0xFFF8F3F3);

    final List<Map<String, String>> searchProducts = [
      {'name': 'Blouse Ribbon Collar Cream Black', 'image': 'assets/images/produk_1.1.png'},
      {'name': 'Rok Satin Midi A-Line Pink', 'image': 'assets/images/produk_1.2.png'},
      {'name': 'Celana Jeans Baggy Hitam', 'image': 'assets/images/produk_1.3.png'},
      {'name': 'Polo Oversize Two Tone Cream Brown', 'image': 'assets/images/produk_1.4.png'},
      {'name': 'Blouse Putih Lengan Serut & Kerah Lebar', 'image': 'assets/images/produk_1.5.png'},
      {'name': 'Checked Midi Skirt with Belt', 'image': 'assets/images/produk_1.6.png'},
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom App Bar
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
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: maroonColor.withOpacity(0.5), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchResultScreen(searchQuery: value),
                                    ),
                                  );
                                }
                              },
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: GoogleFonts.outfit(color: Colors.black12.withOpacity(0.5)),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          Icon(Icons.photo_camera_outlined, color: maroonColor.withOpacity(0.5), size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pencarian Pilihan',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: maroonColor,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Search Results Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: searchProducts.length,
                itemBuilder: (context, index) {
                  return _buildSearchCard(searchProducts[index], maroonColor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard(Map<String, String> product, Color maroonColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: maroonColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              child: Image.asset(
                product['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              product['name']!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
