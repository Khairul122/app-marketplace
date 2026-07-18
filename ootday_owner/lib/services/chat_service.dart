import 'api_service.dart';

/// Wrapper murni di atas [ApiService] untuk chat toko dengan pelanggan.
/// Backend otomatis memfilter thread milik toko owner yang sedang login.
/// Ini polling biasa (refresh manual), bukan realtime socket.
class ChatService {
  final ApiService _api = ApiService();

  /// GET /chat/threads — daftar thread chat milik toko login.
  Future<List<dynamic>> getThreads() async {
    final data = await _api.get('/chat/threads');
    if (data is List) return data;
    if (data is Map && data['data'] is List) return List<dynamic>.from(data['data']);
    return <dynamic>[];
  }

  /// GET /chat/threads/{id}/messages — riwayat pesan satu thread.
  Future<List<dynamic>> getMessages(int threadId) async {
    final data = await _api.get('/chat/threads/$threadId/messages');
    if (data is List) return data;
    if (data is Map && data['data'] is List) return List<dynamic>.from(data['data']);
    return <dynamic>[];
  }

  /// POST /chat/threads/{id}/messages — kirim pesan baru.
  Future<Map<String, dynamic>> sendMessage(int threadId, String message) async {
    final data = await _api.post('/chat/threads/$threadId/messages', {
      'message': message,
    });
    if (data is Map && data['message'] is Map) {
      return Map<String, dynamic>.from(data['message']);
    }
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
