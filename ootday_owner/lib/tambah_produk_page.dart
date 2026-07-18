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
  static const Color redMain = Color(0xFFB40001);

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
  final Set<String> _selectedSizes = {'S', 'M', 'L', 'XL'};
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

    if (_selectedSizes.isEmpty) {
      _showMessage('Pilih minimal satu ukuran');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final price = num.parse(_priceController.text.trim());
      final stock = int.parse(_stockController.text.trim());

      // Bagi stok rata ke tiap ukuran yang dipilih sebagai variant awal.
      final sizesList = _selectedSizes.toList();
      final variantStock =
          sizesList.isEmpty ? stock : (stock / sizesList.length).ceil();

      await _productService.addProduct(
        name: _nameController.text.trim(),
        price: price,
        stock: stock,
        categoryId: _selectedCategoryId,
        description: _descriptionController.text.trim(),
        imagePaths: _imageFile != null ? [_imageFile!.path] : const [],
        variants: sizesList
            .map((size) => {
                  'size': size,
                  'color': 'Default',
                  'stock': variantStock,
                })
            .toList(),
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
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (v) {
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
                              _sizeSelector(),
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

  Widget _categoryDropdown() {
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

  Widget _sizeSelector() {
    const sizes = ['S', 'M', 'L', 'XL'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ukuran Tersedia',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: maroonColor,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: sizes.map((size) {
            final selected = _selectedSizes.contains(size);
            return FilterChip(
              label: Text(size, style: GoogleFonts.outfit()),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedSizes.add(size);
                  } else {
                    _selectedSizes.remove(size);
                  }
                });
              },
              selectedColor: maroonColor.withValues(alpha: 0.15),
              checkmarkColor: maroonColor,
              labelStyle: GoogleFonts.outfit(
                color: selected ? maroonColor : Colors.grey.shade700,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: selected
                    ? maroonColor.withValues(alpha: 0.4)
                    : Colors.grey.shade300,
              ),
            );
          }).toList(),
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
          style: GoogleFonts.outfit(color: maroonColor),
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
            filled: true,
            fillColor: Colors.white,
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
