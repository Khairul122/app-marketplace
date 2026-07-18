import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'cart_data.dart';

/// Layer data pesanan, bicara langsung ke Laravel Sanctum API (`/orders`).
class OrderData {
  static final ApiService _api = ApiService();

  static bool get _hasUser => AuthState.instance.userId != null;

  static Map<String, dynamic> _parseOrder(Map<String, dynamic> order) {
    final rawItems = order['items'] as List? ?? [];
    final items = rawItems.map((raw) {
      final item = Map<String, dynamic>.from(raw as Map);
      return {
        'id': item['id'],
        'product_id': item['product_id'],
        'variant_id': item['variant_id'],
        'name': item['product_name'] ?? '',
        'variant': item['variant_label'] ?? '',
        'image': CartData.resolveImageUrl(item['image_url'] as String?),
        'price': double.tryParse(item['price']?.toString() ?? '0')?.toInt() ?? 0,
        'quantity': item['quantity'] ?? 1,
      };
    }).toList();

    final store = Map<String, dynamic>.from(order['store'] as Map? ?? {});
    final paymentMethod = order['payment_method'] as Map?;
    final shippingMethod = order['shipping_method'] as Map?;

    return {
      'id': order['id'],
      'order_code': order['order_code'] ?? '',
      'status': order['status'] ?? '',
      'subtotal': double.tryParse(order['subtotal']?.toString() ?? '0')?.toInt() ?? 0,
      'shipping_cost': double.tryParse(order['shipping_cost']?.toString() ?? '0')?.toInt() ?? 0,
      'totalPrice': double.tryParse(order['total_price']?.toString() ?? '0')?.toInt() ?? 0,
      'ordered_at': order['ordered_at'],
      'items': items,
      'store_name': store['store_name'] ?? 'Ootday Fashion Store',
      'payment_method_name': paymentMethod?['name'],
      'shipping_method_name': shippingMethod?['name'],
    };
  }

  /// Ambil semua pesanan milik pelanggan login (semua status). Nama method
  /// dipertahankan dari versi lama supaya caller (my_orders_screen.dart)
  /// tidak berubah banyak; filtering per-tab/status dilakukan di UI.
  static Future<List<Map<String, dynamic>>> getActiveOrders() async {
    if (!_hasUser) return [];
    try {
      final result = await _api.get('/orders');
      final List rawList = result is List ? result : [];
      return rawList
          .map((o) => _parseOrder(Map<String, dynamic>.from(o as Map)))
          .toList();
    } on ApiException catch (e) {
      print('Error getting orders: ${e.message}');
      return [];
    } catch (e) {
      print('Error getting orders: $e');
      return [];
    }
  }

  /// Ambil detail 1 pesanan (dipakai order_details_screen.dart &
  /// cancellation_details_screen.dart oleh agent lain).
  static Future<Map<String, dynamic>?> getOrderDetail(int id) async {
    try {
      final result = await _api.get('/orders/$id');
      return _parseOrder(Map<String, dynamic>.from(result as Map));
    } on ApiException catch (e) {
      print('Error getting order detail: ${e.message}');
      return null;
    } catch (e) {
      print('Error getting order detail: $e');
      return null;
    }
  }

  /// Buat pesanan baru dari item keranjang yang sudah dipilih (`cart_item_ids`).
  /// Backend otomatis menghapus cart item terkait setelah order dibuat, jadi
  /// caller TIDAK perlu memanggil CartData.deleteItem lagi setelah ini sukses.
  ///
  /// Mengembalikan order MENTAH (shape asli backend: `id`, `order_code`,
  /// `total_price`, `payment_method: {name, type}`, dst) karena inilah yang
  /// dibutuhkan `PaymentInstructionScreen`/`OrderSuccessScreen` (dibangun
  /// agent lain). Untuk tampilan list pesanan sendiri pakai
  /// `getActiveOrders()`/`getOrderDetail()` yang sudah diformat lebih ramah.
  static Future<Map<String, dynamic>> addOrder({
    required List<int> cartItemIds,
    int? paymentMethodId,
    int? shippingMethodId,
  }) async {
    if (!_hasUser) {
      throw ApiException('Silakan login terlebih dahulu.', 401);
    }
    if (cartItemIds.isEmpty) {
      throw ApiException('Tidak ada item yang dipilih untuk checkout.', 422);
    }

    final result = await _api.post('/orders', {
      'cart_item_ids': cartItemIds,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (shippingMethodId != null) 'shipping_method_id': shippingMethodId,
    });

    final rawOrder = result['order'] as Map? ?? {};
    return Map<String, dynamic>.from(rawOrder);
  }
}
