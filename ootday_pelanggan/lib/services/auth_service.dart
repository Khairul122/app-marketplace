import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'token_store.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// Notifier sederhana untuk status login (dipakai bootstrap di main.dart).
/// Tidak menambah package state-management baru, sesuai gaya app ini.
class AuthState extends ChangeNotifier {
  AuthState._();
  static final AuthState instance = AuthState._();

  bool isLoggedIn = false;
  Map<String, dynamic>? user;

  void setLoggedIn(Map<String, dynamic> user) {
    this.user = user;
    isLoggedIn = true;
    notifyListeners();
  }

  void setLoggedOut() {
    user = null;
    isLoggedIn = false;
    notifyListeners();
  }

  /// id user login, dipakai titik-titik yang dulu mengandalkan Firebase uid.
  int? get userId => user?['id'] as int?;
}

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final data = await _api.post('/register', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'role': 'pelanggan',
      });

      await TokenStore.instance.saveSession(data['token'], data['user']);
      AuthState.instance.setLoggedIn(data['user']);
      return data['user'];
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final data = await _api.post('/login', {
        'email': email,
        'password': password,
      });

      final user = data['user'] as Map<String, dynamic>;
      if (user['role'] != 'pelanggan') {
        throw AuthException('Akun ini bukan akun pelanggan. Gunakan aplikasi owner.');
      }

      await TokenStore.instance.saveSession(data['token'], user);
      AuthState.instance.setLoggedIn(user);
      return user;
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<Map<String, dynamic>?> restoreSession() async {
    final token = await TokenStore.instance.getToken();
    if (token == null) return null;

    try {
      final user = await _api.get('/me');
      await TokenStore.instance.saveUser(user);
      AuthState.instance.setLoggedIn(user);
      return user;
    } catch (e) {
      await TokenStore.instance.clear();
      return null;
    }
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    try {
      final data = await _api.put('/profile', {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      });
      await TokenStore.instance.saveUser(data['user']);
      AuthState.instance.setLoggedIn(data['user']);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _api.put('/password', {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      });
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _api.delete('/account');
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } finally {
      await TokenStore.instance.clear();
      AuthState.instance.setLoggedOut();
    }
  }

  Future<void> signOut() async {
    try {
      await _api.post('/logout');
    } catch (_) {
      // Token mungkin sudah invalid di server; tetap bersihkan sesi lokal.
    }
    await TokenStore.instance.clear();
    AuthState.instance.setLoggedOut();
  }

  Map<String, dynamic>? get currentUser => AuthState.instance.user;
  bool get isLoggedIn => AuthState.instance.isLoggedIn;
}
