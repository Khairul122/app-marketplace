import 'api_service.dart';

/// Wrapper murni di atas [ApiService] untuk ringkasan dashboard owner.
class DashboardService {
  final ApiService _api = ApiService();

  /// GET /owner/dashboard —
  /// `{total_products, total_orders, orders_by_status, revenue, top_products}`.
  Future<Map<String, dynamic>> getDashboard() async {
    final data = await _api.get('/owner/dashboard');
    if (data is Map && data['data'] != null) {
      return Map<String, dynamic>.from(data['data']);
    }
    return Map<String, dynamic>.from(data as Map);
  }
}
