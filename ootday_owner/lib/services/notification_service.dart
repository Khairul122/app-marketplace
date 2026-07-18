import 'api_service.dart';

/// Wrapper murni di atas [ApiService] untuk notifikasi milik user login.
/// Ini polling biasa (fetch saat screen dibuka / pull-to-refresh), bukan
/// realtime stream.
class NotificationService {
  final ApiService _api = ApiService();

  /// GET /notifications — `[{id, title, body, type, is_read, created_at}]`.
  Future<List<dynamic>> getNotifications() async {
    final data = await _api.get('/notifications');
    if (data is List) return data;
    if (data is Map && data['data'] is List) return List<dynamic>.from(data['data']);
    return <dynamic>[];
  }

  /// PUT /notifications/{id}/read
  Future<void> markRead(int id) async {
    await _api.put('/notifications/$id/read');
  }

  /// PUT /notifications/read-all
  Future<void> markAllRead() async {
    await _api.put('/notifications/read-all');
  }
}
