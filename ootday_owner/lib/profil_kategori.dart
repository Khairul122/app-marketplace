import 'package:flutter/material.dart';

import 'profil_produk.dart';
import 'services/api_service.dart';
import 'services/product_service.dart';

class ProfilKategori extends StatefulWidget {
  const ProfilKategori({super.key});

  @override
  State<ProfilKategori> createState() => _ProfilKategoriState();
}

class _ProfilKategoriState extends State<ProfilKategori> {
  static const Color redMain = Color(0xFF5D1A1A);

  final ProductService _productService = ProductService();
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final categories = await _productService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : 'Gagal memuat kategori';
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Kategori'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama kategori',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: redMain),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty || !mounted) return;

    try {
      await _productService.addCategory(name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      _loadCategories();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menambah kategori: ${e is ApiException ? e.message : e}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add, color: redMain),
                label: const Text(
                  'Tambah Kategori',
                  style: TextStyle(color: redMain, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: redMain),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadCategories,
              style: ElevatedButton.styleFrom(backgroundColor: redMain),
              child: const Text('Coba lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Belum ada kategori',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan kategori untuk mengelompokkan produk Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: redMain,
      onRefresh: _loadCategories,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final category = Map<String, dynamic>.from(_categories[index]);
          return _kategoriItem(context, category);
        },
      ),
    );
  }

  Widget _kategoriItem(BuildContext context, Map<String, dynamic> category) {
    final id = category['id'];
    final name = (category['name'] as String?) ?? 'Kategori';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilProduk(
              kategori: name,
              categoryId: id is int ? id : int.tryParse('$id'),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: redMain,
              ),
            ),
            const Icon(Icons.chevron_right, color: redMain, size: 24),
          ],
        ),
      ),
    );
  }
}
