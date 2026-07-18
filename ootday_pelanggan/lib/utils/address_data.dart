import '../services/api_service.dart';
import '../services/auth_service.dart';

/// Layer data alamat, bicara langsung ke Laravel Sanctum API (`/addresses`).
///
/// Keputusan desain: backend pakai snake_case (`receiver_name`,
/// `full_address`, `is_main`), tapi layer util ini tetap mengekspos
/// camelCase (`name`, `fullAddress`, `isMain`) seperti versi lama supaya
/// `address_screen.dart` & `add_address_screen.dart` tidak perlu diubah
/// banyak (lebih sedikit titik yang bisa menimbulkan bug daripada mengganti
/// semua pemanggil ke snake_case).
class AddressData {
  static final ApiService _api = ApiService();

  static bool get _hasUser => AuthState.instance.userId != null;

  static Map<String, dynamic> _toCamelCase(Map<String, dynamic> addr) {
    return {
      'id': addr['id'],
      'name': addr['receiver_name'] ?? '',
      'phone': addr['phone'] ?? '',
      'fullAddress': addr['full_address'] ?? '',
      'isMain': addr['is_main'] == true || addr['is_main'] == 1,
    };
  }

  /// Ambil semua alamat milik user login.
  static Future<List<Map<String, dynamic>>> getAddresses() async {
    if (!_hasUser) return [];
    try {
      final result = await _api.get('/addresses');
      final List rawList = result is List ? result : [];
      return rawList
          .map((addr) => _toCamelCase(Map<String, dynamic>.from(addr as Map)))
          .toList();
    } on ApiException catch (e) {
      print('Error loading addresses: ${e.message}');
      return [];
    } catch (e) {
      print('Error loading addresses: $e');
      return [];
    }
  }

  /// Tambah alamat baru. `newAddress` pakai key camelCase (`name`, `phone`,
  /// `fullAddress`, `isMain`).
  static Future<void> addAddress(Map<String, dynamic> newAddress) async {
    if (!_hasUser) {
      throw ApiException('Silakan login terlebih dahulu.', 401);
    }
    await _api.post('/addresses', {
      'receiver_name': newAddress['name'],
      'phone': newAddress['phone'],
      'full_address': newAddress['fullAddress'],
      'is_main': newAddress['isMain'] == true,
    });
  }

  /// Update alamat yang sudah ada (partial update didukung backend, tapi
  /// di sini kita selalu kirim semua field yang ada di `updatedAddress`).
  static Future<void> updateAddress(String addressId, Map<String, dynamic> updatedAddress) async {
    if (!_hasUser) {
      throw ApiException('Silakan login terlebih dahulu.', 401);
    }
    await _api.put('/addresses/$addressId', {
      if (updatedAddress['name'] != null) 'receiver_name': updatedAddress['name'],
      if (updatedAddress['phone'] != null) 'phone': updatedAddress['phone'],
      if (updatedAddress['fullAddress'] != null) 'full_address': updatedAddress['fullAddress'],
      if (updatedAddress['isMain'] != null) 'is_main': updatedAddress['isMain'] == true,
    });
  }

  /// Hapus alamat.
  static Future<void> deleteAddress(String addressId) async {
    await _api.delete('/addresses/$addressId');
  }
}
