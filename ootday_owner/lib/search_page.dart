import 'dart:async';

import 'package:flutter/material.dart';

import 'detail_produk.dart';
import 'services/api_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final Color redMain = const Color(0xFF5D1A1A);
  final Color greyBG = const Color(0xFFF2F2F2);
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _productResults = [];
  List<Map<String, dynamic>> _orderResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _debounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _productResults = [];
        _orderResults = [];
        _isSearching = false;
        _error = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(query));
  }

  Future<void> _runSearch(String query) async {
    setState(() {
      _isSearching = true;
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.get('/products?q=${Uri.encodeQueryComponent(query)}'),
        _api.get('/my-orders'),
      ]);

      final products = (results[0] as List? ?? [])
          .map((p) => Map<String, dynamic>.from(p as Map))
          .toList();

      final lowerQuery = query.toLowerCase();
      final orders = (results[1] as List? ?? [])
          .map((o) => Map<String, dynamic>.from(o as Map))
          .where((o) {
            final code = (o['order_code'] as String? ?? '').toLowerCase();
            final items = o['items'];
            final itemNames = items is List
                ? items
                    .map((it) => it is Map ? (it['name'] ?? it['product_name'] ?? '') : '')
                    .join(' ')
                    .toLowerCase()
                : '';
            return code.contains(lowerQuery) || itemNames.contains(lowerQuery);
          })
          .toList();

      if (!mounted) return;
      setState(() {
        _productResults = products;
        _orderResults = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : 'Gagal memuat hasil pencarian';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyBG,
      body: Column(
        children: [
          _header(),
          _searchBar(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: redMain),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'ootday',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: greyBG,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.black87),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Cari produk atau pesanan...",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () => _searchController.clear(),
                child: const Icon(Icons.clear, color: Colors.black54, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (!_isSearching && _searchController.text.isEmpty) {
      return _buildEmptyState('Mulai ketik untuk mencari produk atau pesanan');
    }

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: redMain));
    }

    if (_error != null) {
      return _buildEmptyState(_error!);
    }

    if (_productResults.isEmpty && _orderResults.isEmpty) {
      return _buildEmptyState('Tidak ada hasil ditemukan');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._productResults.map(_buildProductCard),
        ..._orderResults.map(_buildOrderCard),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    final imageUrl = _primaryImageUrl(product);
    final name = (product['name'] as String?) ?? 'Produk';
    final price = product['price'];
    final priceInt = price is num ? price.toInt() : int.tryParse('$price') ?? 0;
    final categoryName = product['category'] is Map
        ? (product['category']['name'] as String?) ?? ''
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailProduk(product: product)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 30),
                      )
                    : const Icon(Icons.image, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (categoryName.isNotEmpty)
                    Text(
                      categoryName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatPrice(priceInt)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: redMain,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final code = (order['order_code'] as String?) ?? '-';
    final status = (order['status'] as String?) ?? '';
    final items = order['items'];
    final title = items is List && items.isNotEmpty
        ? items
            .map((it) => it is Map ? (it['name'] ?? it['product_name'] ?? '') : '')
            .join(', ')
        : 'Pesanan';
    final quantity = items is List ? '(${items.length})' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: const Icon(Icons.receipt_long, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      quantity,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      code,
                      style: TextStyle(
                        fontSize: 12,
                        color: redMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: redMain.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.isNotEmpty ? status : 'Pesanan',
              style: TextStyle(
                fontSize: 10,
                color: redMain,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
