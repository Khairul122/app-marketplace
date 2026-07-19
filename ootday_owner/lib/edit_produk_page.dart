import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ootday_owner/services/api_service.dart';
import 'package:ootday_owner/services/product_service.dart';

class EditProdukPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditProdukPage({super.key, required this.product});

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  static const Color maroonColor = Color(0xFF5D1A1A);
  static const Color redMain = Color(0xFF5D1A1A);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;
  final ProductService _productService = ProductService();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String? _existingImageUrl;
  int? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _variantsList = [];
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']?.toString() ?? '');
    _priceController = TextEditingController(text: widget.product['price']?.toString() ?? '');
    _stockController = TextEditingController(text: widget.product['stock']?.toString() ?? '0');
    _descriptionController = TextEditingController(text: widget.product['description']?.toString() ?? '');

    // Existing primary image
    final images = widget.product['images'] as List?;
    if (images != null && images.isNotEmpty) {
      final primary = images.firstWhere(
        (img) => img is Map && img['is_primary'] == true,
        orElse: () => images.first,
      );
      if (primary is Map) {
        _existingImageUrl = primary['image_url'] as String?;
      }
    }

    // Existing category
    final cat = widget.product['category'];
    if (cat is Map) {
      _selectedCategoryId = cat['id'] as int?;
    } else if (widget.product['category_id'] != null) {
      _selectedCategoryId = widget.product['category_id'] as int?;
    }

    // Existing variants
    final rawVariants = widget.product['variants'] as List?;
    if (rawVariants != null) {
      _variantsList = rawVariants.map((v) => {
        'attribute1_name': v['attribute1_name']?.toString() ?? 'Varian',
        'attribute1_value': v['attribute1_value']?.toString() ?? '-',
        'attribute2_name': (v['attribute2_name']?.toString().isNotEmpty ?? false) ? v['attribute2_name'].toString() : null,
        'attribute2_value': (v['attribute2_value']?.toString().isNotEmpty ?? false) ? v['attribute2_value'].toString() : null,
        'stock': v['stock'] is num ? (v['stock'] as num).toInt() : (int.tryParse('${v['stock']}') ?? 0),
        'image_url': v['image_url']?.toString(),
        'imagePath': null,
      }).toList();
    }

    _syncStockController();
    _loadCategories();
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

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await _productService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = list.map((c) => Map<String, dynamic>.from(c as Map)).toList();
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initError = e is ApiException ? e.message : e.toString();
        _isInitializing = false;
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

  Future<void> _pickMainImage() async {
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
            'image_url': v['image_url'], // pertahankan URL lama jika tidak diganti
            'imagePath': v['imagePath'], // kirim path lokal jika baru diunggah
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

      final updatedProduct = await _productService.updateProduct(
        id: widget.product['id'] as int,
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
      _showMessage('Produk berhasil diperbarui!', isError: false);
      Navigator.pop(context, updatedProduct);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Gagal memperbarui produk: ${e is ApiException ? e.message : e}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text('Edit Produk', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: maroonColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator(color: redMain))
          : _initError != null
              ? Center(child: Text('Gagal inisialisasi: $_initError', style: GoogleFonts.outfit(color: maroonColor)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _imagePickerSection(),
                        const SizedBox(height: 24),
                        _buildField(
                          label: 'Nama Produk',
                          hint: 'Contoh: Kemeja Oversize Coklat',
                          icon: Iconsax.box,
                          controller: _nameController,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nama produk wajib diisi' : null,
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
                                icon: Iconsax.money_send,
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                                  if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Harga tidak valid';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildField(
                                label: 'Stok',
                                hint: '20',
                                icon: Iconsax.archive,
                                controller: _stockController,
                                readOnly: _variantsList.isNotEmpty,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (v) {
                                  if (_variantsList.isNotEmpty) return null;
                                  if (v == null || v.trim().isEmpty) return 'Stok wajib diisi';
                                  if (int.tryParse(v) == null || int.parse(v) < 0) return 'Stok tidak valid';
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
                          validator: (v) => v == null || v.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
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
                              disabledBackgroundColor: maroonColor.withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Text('Simpan Perubahan', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _imagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto Produk', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: maroonColor)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickMainImage,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: maroonColor.withValues(alpha: 0.15)),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  )
                : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                      ApiService.resolveImageUrl(_existingImageUrl),
                      headers: const {'localtonet-skip-warning': 'true'},
                      fit: BoxFit.cover,
                    ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.image, size: 48, color: maroonColor),
                          const SizedBox(height: 10),
                          Text('Pilih Foto Utama Baru', style: GoogleFonts.outfit(color: maroonColor.withValues(alpha: 0.6))),
                        ],
                      )),
          ),
        ),
      ],
    );
  }

  Widget _categoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kategori', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: maroonColor)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              hint: Text('Pilih Kategori', style: GoogleFonts.outfit(color: Colors.grey)),
              validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
              decoration: const InputDecoration(border: InputBorder.none),
              items: _categories
                  .map((c) => DropdownMenuItem<int>(value: c['id'] as int, child: Text(c['name'] as String, style: GoogleFonts.outfit())))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
          ),
        ),
      ],
    );
  }

  void _addVariantRow() {
    setState(() {
      _variantsList.add({
        'attribute1_name': 'Ukuran',
        'attribute1_value': 'M',
        'attribute2_name': null,
        'attribute2_value': null,
        'stock': 10,
        'image_url': null,
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
            Text('Varian Produk (Opsional)', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: maroonColor)),
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
                                    child: Image.file(File(variant['imagePath'] as String), fit: BoxFit.cover),
                                  )
                                : (variant['image_url'] != null && (variant['image_url'] as String).isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: Image.network(
                                          ApiService.resolveImageUrl(variant['image_url'] as String),
                                          headers: const {'localtonet-skip-warning': 'true'},
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(Iconsax.camera, size: 18, color: maroonColor.withValues(alpha: 0.5))),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: variant['attribute1_name'],
                            decoration: InputDecoration(labelText: 'Nama Atribut', labelStyle: GoogleFonts.outfit(fontSize: 12), hintText: 'Ukuran, Kapasitas...', isDense: true),
                            style: GoogleFonts.outfit(fontSize: 13, color: maroonColor),
                            onChanged: (val) => variant['attribute1_name'] = val.trim(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: variant['attribute1_value'],
                            decoration: InputDecoration(labelText: 'Nilai', labelStyle: GoogleFonts.outfit(fontSize: 12), hintText: 'M, 500ml...', isDense: true),
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
                              decoration: InputDecoration(labelText: 'Nama Atribut 2', labelStyle: GoogleFonts.outfit(fontSize: 12), hintText: 'Warna, Rasa...', isDense: true),
                              style: GoogleFonts.outfit(fontSize: 13, color: maroonColor),
                              onChanged: (val) => variant['attribute2_name'] = val.trim(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: variant['attribute2_value'],
                              decoration: InputDecoration(labelText: 'Nilai', labelStyle: GoogleFonts.outfit(fontSize: 12), hintText: 'Hitam, Coklat...', isDense: true),
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
                            decoration: InputDecoration(labelText: 'Stok', labelStyle: GoogleFonts.outfit(fontSize: 12), isDense: true),
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
        Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: maroonColor)),
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
            hintStyle: GoogleFonts.outfit(color: maroonColor.withValues(alpha: 0.3)),
            prefixIcon: Icon(icon, color: maroonColor.withValues(alpha: 0.5), size: 20),
            suffixText: readOnly ? 'Otomatis' : null,
            suffixStyle: GoogleFonts.outfit(fontSize: 11, color: maroonColor.withValues(alpha: 0.4)),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF0EDED) : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: maroonColor.withValues(alpha: 0.25))),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}
