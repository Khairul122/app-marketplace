import 'api_service.dart';

/// Wrapper murni di atas [ApiService] untuk operasi pesanan toko owner login.
class OrderService {
  final ApiService _api = ApiService();

  /// GET /my-orders — semua pesanan milik toko owner yang sedang login.
  Future<List<dynamic>> getMyOrders() async {
    final data = await _api.get('/my-orders');
    if (data is List) return data;
    if (data is Map && data['data'] is List) return List<dynamic>.from(data['data']);
    if (data is Map && data['orders'] is List) return List<dynamic>.from(data['orders']);
    return <dynamic>[];
  }

  /// GET /orders/{id} — detail satu pesanan (owner maupun pelanggan pemilik).
  Future<Map<String, dynamic>> getOrderDetail(int id) async {
    final data = await _api.get('/orders/$id');
    if (data is Map && data['order'] != null) {
      return Map<String, dynamic>.from(data['order']);
    }
    return Map<String, dynamic>.from(data as Map);
  }

  /// PUT /my-orders/{id}/status — ubah status pesanan.
  Future<void> updateStatus(int id, String status) async {
    await _api.put('/my-orders/$id/status', {'status': status});
  }
}
