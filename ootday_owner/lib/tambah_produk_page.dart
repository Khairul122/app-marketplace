import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import 'services/api_service.dart';
import 'services/product_service.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  static const Color maroonColor = Color(0xFF5D1A1A);
  static const Color redMain = Color(0xFF5D1A1A);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ProductService _productService = ProductService();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  int? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  final List<Map<String, dynamic>> _variantsList = [];
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final categories = await _productService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories.map((c) => Map<String, dynamic>.from(c as Map)).toList();
        if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories.first['id'] as int;
        }
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _initError = e is ApiException ? e.message : 'Gagal memuat data toko';
      });
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit()),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final price = num.parse(_priceController.text.trim());
      int stock = 0;
      final List<Map<String, dynamic>> finalVariants = [];

      if (_variantsList.isNotEmpty) {
        for (final v in _variantsList) {
          final attribute1Name = (v['attribute1_name'] as String?)?.trim() ?? 'Varian';
          final attribute1Value = (v['attribute1_value'] as String?)?.trim() ?? '-';
          final attribute2Name = (v['attribute2_name'] as String?)?.trim();
          final attribute2Value = (v['attribute2_value'] as String?)?.trim();
          final vStock = (v['stock'] as num?)?.toInt() ?? 0;
          stock += vStock;

          finalVariants.add({
            'attribute1_name': attribute1Name,
            'attribute1_value': attribute1Value,
            if (attribute2Name != null && attribute2Name.isNotEmpty) 'attribute2_name': attribute2Name,
            if (attribute2Value != null && attribute2Value.isNotEmpty) 'attribute2_value': attribute2Value,
            'stock': vStock,
            'imagePath': v['imagePath'],
          });
        }
      } else {
        final generalStock = int.tryParse(_stockController.text.trim()) ?? 0;
        stock = generalStock;
        finalVariants.add({
          'attribute1_name': 'Stok',
          'attribute1_value': 'Umum',
          'stock': generalStock,
        });
      }

      await _productService.addProduct(
        name: _nameController.text.trim(),
        price: price,
        stock: stock,
        categoryId: _selectedCategoryId,
        description: _descriptionController.text.trim(),
        imagePaths: _imageFile != null ? [_imageFile!.path] : const [],
        variants: finalVariants,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      await _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(
        'Gagal menyimpan produk: ${e is ApiException ? e.message : e}',
      );
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: maroonColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.tick_circle,
                  size: 48,
                  color: maroonColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Produk Berhasil Ditambahkan!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: maroonColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Produk sudah tersimpan dan siap ditampilkan di toko Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: maroonColor.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Selesai',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: _isInitializing
                ? const Center(child: CircularProgressIndicator(color: redMain))
                : _initError != null
                    ? _emptyStoreState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _imagePicker(),
                              const SizedBox(height: 24),
                              _buildField(
                                label: 'Nama Produk',
                                hint: 'Contoh: Kemeja Oversize Coklat',
                                icon: Iconsax.box,
                                controller: _nameController,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Nama produk wajib diisi'
                                        : null,
                              ),
                              const SizedBox(height: 18),
                              _categoryDropdown(),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      label: 'Harga (Rp)',
                                      hint: '150000',
                                      icon: Iconsax.money,
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Harga wajib diisi';
                                        }
                                        if (int.tryParse(v) == null ||
                                            int.parse(v) <= 0) {
                                          return 'Harga tidak valid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildField(
                                      label: 'Stok',
                                      hint: '100',
                                      icon: Iconsax.box_1,
                                      controller: _stockController,
                                      readOnly: _variantsList.isNotEmpty,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (v) {
                                        if (_variantsList.isNotEmpty) return null;
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Stok wajib diisi';
                                        }
                                        if (int.tryParse(v) == null ||
                                            int.parse(v) < 0) {
                                          return 'Stok tidak valid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              _buildField(
                                label: 'Deskripsi',
                                hint: 'Jelaskan detail produk...',
                                icon: Iconsax.document_text,
                                controller: _descriptionController,
                                maxLines: 4,
                                validator: (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Deskripsi wajib diisi'
                                        : null,
                              ),
                              const SizedBox(height: 18),
                              _variantsSection(),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: maroonColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        maroonColor.withValues(alpha: 0.6),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Simpan Produk',
                                          style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [redMain, Color(0xFF7A0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Iconsax.arrow_left, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tambah Produk',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lengkapi informasi produk baru',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.box_add, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyStoreState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.shop, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Toko belum terhubung',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: maroonColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _initError ??
                  'Login ulang sebagai owner atau pastikan data toko sudah tersinkron.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: maroonColor.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.gallery_add,
                    size: 48,
                    color: maroonColor.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap untuk upload foto produk',
                    style: GoogleFonts.outfit(
                      color: maroonColor.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Format JPG/PNG, maks. 1200px',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _quickAddCategory() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tambah Kategori Baru', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: maroonColor)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.outfit(color: maroonColor),
          decoration: InputDecoration(
            hintText: 'Nama kategori (contoh: Kaos, Celana)',
            hintStyle: GoogleFonts.outfit(color: Colors.grey),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: maroonColor),
            child: Text('Simpan', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty || !mounted) return;

    try {
      setState(() => _isLoading = true);
      final newCategory = await _productService.addCategory(name);
      
      // Reload list kategori
      final categories = await _productService.getCategories();
      
      if (!mounted) return;
      setState(() {
        _categories = categories.map((c) => Map<String, dynamic>.from(c as Map)).toList();
        _selectedCategoryId = newCategory['id'] as int?;
        _isLoading = false;
      });
      _showMessage('Kategori "$name" berhasil dibuat!', isError: false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Gagal membuat kategori: ${e is ApiException ? e.message : e}');
    }
  }

  Widget _categoryDropdown() {
    if (_categories.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: maroonColor,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _quickAddCategory,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: maroonColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.add_circle, color: maroonColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Belum ada kategori. Tap untuk membuat baru.',
                      style: GoogleFonts.outfit(
                        color: maroonColor.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kategori',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: maroonColor,
              ),
            ),
            GestureDetector(
              onTap: _quickAddCategory,
              child: Text(
                '+ Tambah Baru',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: maroonColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedCategoryId,
              isExpanded: true,
              icon: Icon(Iconsax.arrow_down_1,
                  color: maroonColor.withValues(alpha: 0.5), size: 18),
              style: GoogleFonts.outfit(color: maroonColor),
              items: _categories
                  .map(
                    (c) => DropdownMenuItem<int>(
                      value: c['id'] as int,
                      child: Text(c['name'] as String),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
          ),
        ),
      ],
    );
  }

  /// Total stok field utama otomatis mengikuti jumlah stok semua varian
  /// begitu ada minimal 1 varian (lihat `readOnly` di field "Stok" utama) —
  /// dipanggil tiap kali daftar varian atau salah satu stok varian berubah.
  void _syncStockController() {
    if (_variantsList.isEmpty) return;
    final total = _variantsList.fold<int>(
      0,
      (sum, v) => sum + ((v['stock'] as num?)?.toInt() ?? 0),
    );
    _stockController.text = total.toString();
  }

  void _addVariantRow() {
    setState(() {
      _variantsList.add({
        'attribute1_name': 'Ukuran',
        'attribute1_value': 'M',
        'attribute2_name': null,
        'attribute2_value': null,
        'stock': 10,
        'imagePath': null,
      });
      _syncStockController();
    });
  }

  void _removeVariantRow(int index) {
    setState(() {
      _variantsList.removeAt(index);
      _syncStockController();
    });
  }

  Future<void> _pickVariantImage(int index) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _variantsList[index]['imagePath'] = picked.path;
    });
  }

  Widget _variantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Varian Produk (Opsional)',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: maroonColor,
              ),
            ),
            TextButton.icon(
              onPressed: _addVariantRow,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text('Tambah Varian', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(foregroundColor: maroonColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_variantsList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Belum ada varian khusus. Isi "Stok" di atas jika produk tidak memiliki varian.',
                style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _variantsList.length,
            itemBuilder: (context, index) {
              final variant = _variantsList[index];
              final hasAttribute2 = variant['attribute2_name'] != null;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _pickVariantImage(index),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: variant['imagePath'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: Image.file(
                                      File(variant['imagePath'] as String),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Iconsax.camera,
                                    size: 18,
                                    color: maroonColor.withValues(alpha: 0.5),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: variant['attribute1_name'],
                            decoration: InputDecoration(
                              labelText: 'Nama Atribut',
                              labelStyle: GoogleFonts.outfit(fontSize: 12),
                              hintText: 'Ukuran, Kapasitas, Model...',
                              isDense: true,
                            ),
                            style: GoogleFonts.outfit(fontSize: 13, color: maroonColor),
                            onChanged: (val) => variant['attribute1_name'] = val.trim(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: variant['attribute1_value'],
                            decoration: InputDecoration(
                              labelText: 'Nilai',
                              labelStyle: GoogleFonts.outfit(fontSize: 12),
                              hintText: 'M, 500ml, 128GB...',
                              isDense: true,
                            ),
                            style: GoogleFonts.outfit(fontSize: 13, color: maroonColor),
                            onChanged: (val) => variant['attribute1_value'] = val.trim(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => _removeVariantRow(index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (hasAttribute2)
                      Row(
                        children: [
                          const SizedBox(width: 52),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: variant['attribute2_name'],
                              decoration: InputDecoration(
                                labelText: 'Nama Atribut 2',
                                labelStyle: GoogleFonts.outfit(fontSize: 12),
                                hintText: 'Warna, Rasa...',
                                isDense: true,
                              ),
                              style: GoogleFonts.outfit(fontSize: 13, color: maroonColor),
                              onChanged: (val) => variant['attribute2_name'] = val.trim(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: variant['attribute2_value'],
                              decoration: InputDecoration(
                                labelText: 'Nilai',
                                labelStyle: GoogleFonts.outfit(fontSize: 12),
                                hintText: 'Hitam, Coklat...',
                                isDense: true,
                              ),
                              style: GoogleFonts.outfit(fontSize: 13, color: maroonColor),
                              onChanged: (val) => variant['attribute2_value'] = val.trim(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                            tooltip: 'Hapus atribut kedua',
                            onPressed: () => setState(() {
                              variant['attribute2_name'] = null;
                              variant['attribute2_value'] = null;
                            }),
                          ),
                        ],
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(left: 52),
                        child: TextButton.icon(
                          onPressed: () => setState(() {
                            variant['attribute2_name'] = 'Warna';
                            variant['attribute2_value'] = '';
                          }),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text('Tambah atribut kedua', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(foregroundColor: maroonColor, padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 52),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            initialValue: variant['stock']?.toString(),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              labelText: 'Stok',
                              labelStyle: GoogleFonts.outfit(fontSize: 12),
                              isDense: true,
                            ),
                            style: GoogleFonts.outfit(fontSize: 13, color: maroonColor),
                            onChanged: (val) => setState(() {
                              variant['stock'] = int.tryParse(val) ?? 0;
                              _syncStockController();
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: maroonColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          readOnly: readOnly,
          style: GoogleFonts.outfit(color: readOnly ? maroonColor.withValues(alpha: 0.6) : maroonColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
              color: maroonColor.withValues(alpha: 0.3),
            ),
            prefixIcon: Icon(
              icon,
              color: maroonColor.withValues(alpha: 0.5),
              size: 20,
            ),
            suffixText: readOnly ? 'Otomatis' : null,
            suffixStyle: GoogleFonts.outfit(fontSize: 11, color: maroonColor.withValues(alpha: 0.4)),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF0EDED) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: maroonColor.withValues(alpha: 0.25),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
