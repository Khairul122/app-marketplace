import '../services/api_service.dart';
import '../services/auth_service.dart';

/// Layer data keranjang, bicara langsung ke Laravel Sanctum API (`/cart`).
///
/// Skema baru berbasis *variant* (bukan produk+atribut lepas seperti versi
/// lama): setiap item keranjang menunjuk ke satu `ProductVariant` yang sudah
/// menentukan size/color/stock/price sendiri.
class CartData {
  static final ApiService _api = ApiService();

  static bool get _hasUser => AuthState.instance.userId != null;

  /// Ubah path gambar relatif dari backend (`/storage/...`) jadi URL penuh.
  /// Kalau sudah URL lengkap atau asset lokal, dikembalikan apa adanya.
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return 'assets/images/Produk_1.png';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('assets/')) return path;
    final host = ApiService.baseUrl.replaceAll('/api', '');
    return path.startsWith('/') ? '$host$path' : '$host/$path';
  }

  static double _effectivePrice(Map<String, dynamic> variant, Map<String, dynamic> product) {
    if (variant['price'] != null) {
      return double.tryParse(variant['price'].toString()) ?? 0;
    }
    final basePrice = double.tryParse(product['price']?.toString() ?? '0') ?? 0;
    final adj = double.tryParse(variant['price_adjustment']?.toString() ?? '0') ?? 0;
    return basePrice + adj;
  }

  static String _primaryImage(Map<String, dynamic> product) {
    final images = product['images'] as List? ?? [];
    if (images.isEmpty) return resolveImageUrl(null);
    final primary = images.firstWhere(
      (img) => img['is_primary'] == true,
      orElse: () => images.first,
    );
    return resolveImageUrl(primary['image_url'] as String?);
  }

  static Map<String, dynamic> _parseItem(Map<String, dynamic> item) {
    final variant = Map<String, dynamic>.from(item['variant'] as Map? ?? {});
    final product = Map<String, dynamic>.from(variant['product'] as Map? ?? {});
    final store = Map<String, dynamic>.from(product['store'] as Map? ?? {});
    final price = _effectivePrice(variant, product);

    final descParts = <String>[
      if (variant['attribute1_value'] != null && variant['attribute1_value'].toString().isNotEmpty)
        '${variant['attribute1_name'] ?? 'Varian'}: ${variant['attribute1_value']}',
      if (variant['attribute2_value'] != null && variant['attribute2_value'].toString().isNotEmpty)
        '${variant['attribute2_name'] ?? 'Varian'}: ${variant['attribute2_value']}',
    ];

    return {
      'id': item['id'],
      'variant_id': variant['id'],
      'product_id': product['id'],
      'name': product['name'] ?? '',
      'desc': descParts.isEmpty ? '-' : descParts.join(', '),
      'size': variant['attribute1_value'],
      'color': variant['attribute2_value'],
      'price': price.toInt(),
      'quantity': item['quantity'] ?? 1,
      'selected': item['is_selected'] == true || item['is_selected'] == 1,
      'image': _primaryImage(product),
      'store_name': store['store_name'] ?? '',
      'stock': variant['stock'] ?? 0,
    };
  }

  /// Ambil semua item keranjang milik user login.
  /// Kalau belum login, langsung kembalikan list kosong (tidak ada user dummy).
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    if (!_hasUser) return [];
    try {
      final result = await _api.get('/cart');
      final List rawItems = result is List ? result : [];
      return rawItems
          .map((item) => _parseItem(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on ApiException catch (e) {
      print('Error getting cart items: ${e.message}');
      return [];
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

  /// Tambah variant ke keranjang. `item` wajib berisi `variant_id` (dan
  /// opsional `quantity`, default 1). Mengembalikan representasi item
  /// keranjang hasil parse (berguna untuk alur "Beli Sekarang" yang butuh
  /// tahu id cart item yang baru dibuat/diupdate).
  static Future<Map<String, dynamic>> addItem(Map<String, dynamic> item) async {
    if (!_hasUser) {
      throw ApiException('Silakan login terlebih dahulu.', 401);
    }
    final rawVariantId = item['variant_id'] ?? item['variantId'];
    if (rawVariantId == null) {
      throw ApiException('Varian produk belum dipilih.', 422);
    }
    final variantId = rawVariantId is int ? rawVariantId : int.tryParse(rawVariantId.toString());
    if (variantId == null) {
      throw ApiException('Varian produk tidak valid.', 422);
    }

    final result = await _api.post('/cart', {
      'variant_id': variantId,
      'quantity': item['quantity'] ?? 1,
    });
    final rawItem = result['item'] as Map? ?? {};
    return _parseItem(Map<String, dynamic>.from(rawItem));
  }

  /// Update quantity sebuah item keranjang.
  static Future<void> updateQuantity(String cartItemId, int quantity) async {
    await _api.put('/cart/$cartItemId', {'quantity': quantity});
  }

  /// Update status pilih/tidak sebuah item keranjang.
  static Future<void> updateSelection(String cartItemId, bool isSelected) async {
    await _api.put('/cart/$cartItemId', {'is_selected': isSelected});
  }

  /// Update status pilih/tidak SEMUA item keranjang user login.
  static Future<void> updateSelectAll(bool isSelected) async {
    await _api.put('/cart/select-all', {'is_selected': isSelected});
  }

  /// Hapus satu item keranjang.
  static Future<void> deleteItem(String cartItemId) async {
    await _api.delete('/cart/$cartItemId');
  }
}
