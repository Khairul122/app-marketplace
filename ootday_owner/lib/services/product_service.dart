import 'api_service.dart';

/// Wrapper murni di atas [ApiService] untuk semua operasi kategori & produk
/// milik toko owner yang sedang login. Backend Laravel sudah men-scope data
/// berdasarkan token (Sanctum), jadi tidak perlu lagi resolve store id/UID
/// secara manual seperti pada implementasi Firebase+MySQL sebelumnya.
class ProductService {
  final ApiService _api = ApiService();

  /// GET /my-categories — daftar kategori milik toko owner login.
  Future<List<dynamic>> getCategories() async {
    final data = await _api.get('/my-categories');
    return data is List ? data : <dynamic>[];
  }

  /// POST /my-categories — tambah kategori baru.
  Future<Map<String, dynamic>> addCategory(String name, {String? iconUrl}) async {
    final data = await _api.post('/my-categories', {
      'name': name,
      if (iconUrl != null) 'icon_url': iconUrl,
    });
    if (data is Map && data['category'] != null) {
      return Map<String, dynamic>.from(data['category']);
    }
    return Map<String, dynamic>.from(data as Map);
  }

  /// GET /my-products — produk toko login (sudah include images/variants/category).
  Future<List<dynamic>> getMyProducts() async {
    final data = await _api.get('/my-products');
    return data is List ? data : <dynamic>[];
  }

  /// GET /products/{id} — detail satu produk.
  Future<Map<String, dynamic>> getProductDetail(int id) async {
    final data = await _api.get('/products/$id');
    return Map<String, dynamic>.from(data as Map);
  }

  /// POST /my-products (multipart) — tambah produk baru, sekaligus upload
  /// gambar & variant sekali jalan.
  ///
  /// [variants] tiap item berbentuk `{size, color, stock}` (stock opsional).
  Future<Map<String, dynamic>> addProduct({
    required String name,
    required num price,
    int stock = 0,
    int? categoryId,
    String? description,
    List<String> imagePaths = const [],
    List<Map<String, dynamic>> variants = const [],
  }) async {
    final fields = <String, String>{
      'name': name,
      'price': price.toString(),
      'stock': stock.toString(),
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (description != null) 'description': description,
    };

    final Map<String, List<String>> filePathsMap = {};
    if (imagePaths.isNotEmpty) {
      filePathsMap['images'] = imagePaths;
    }

    for (var i = 0; i < variants.length; i++) {
      final variant = variants[i];
      if (variant['size'] != null) {
        fields['variants[$i][size]'] = variant['size'].toString();
      }
      if (variant['color'] != null) {
        fields['variants[$i][color]'] = variant['color'].toString();
      }
      if (variant['stock'] != null) {
        fields['variants[$i][stock]'] = variant['stock'].toString();
      }
      if (variant['imagePath'] != null && (variant['imagePath'] as String).isNotEmpty) {
        filePathsMap['variant_images[$i]'] = [variant['imagePath'] as String];
      }
    }

    final data = await _api.multipart(
      'POST',
      '/my-products',
      fields: fields,
      filePaths: filePathsMap.isNotEmpty ? filePathsMap : null,
    );

    if (data is Map && data['product'] != null) {
      return Map<String, dynamic>.from(data['product']);
    }
    return Map<String, dynamic>.from(data as Map);
  }

  /// DELETE /my-products/{id}
  Future<void> deleteProduct(int id) async {
    await _api.delete('/my-products/$id');
  }

  /// PUT /my-products/{id} (via POST spoofing)
  Future<Map<String, dynamic>> updateProduct({
    required int id,
    required String name,
    required num price,
    int stock = 0,
    int? categoryId,
    String? description,
    List<String> imagePaths = const [],
    List<Map<String, dynamic>> variants = const [],
  }) async {
    final fields = <String, String>{
      'name': name,
      'price': price.toString(),
      'stock': stock.toString(),
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (description != null) 'description': description,
    };

    final Map<String, List<String>> filePathsMap = {};
    if (imagePaths.isNotEmpty) {
      filePathsMap['images'] = imagePaths;
    }

    for (var i = 0; i < variants.length; i++) {
      final variant = variants[i];
      if (variant['size'] != null) {
        fields['variants[$i][size]'] = variant['size'].toString();
      }
      if (variant['color'] != null) {
        fields['variants[$i][color]'] = variant['color'].toString();
      }
      if (variant['stock'] != null) {
        fields['variants[$i][stock]'] = variant['stock'].toString();
      }
      if (variant['image_url'] != null) {
        fields['variants[$i][image_url]'] = variant['image_url'].toString();
      }
      if (variant['imagePath'] != null && (variant['imagePath'] as String).isNotEmpty) {
        filePathsMap['variant_images[$i]'] = [variant['imagePath'] as String];
      }
    }

    final data = await _api.multipart(
      'POST',
      '/my-products/$id?_method=PUT',
      fields: fields,
      filePaths: filePathsMap.isNotEmpty ? filePathsMap : null,
    );

    if (data is Map && data['product'] != null) {
      return Map<String, dynamic>.from(data['product']);
    }
    return Map<String, dynamic>.from(data as Map);
  }
}
