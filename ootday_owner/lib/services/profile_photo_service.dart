import 'package:image_picker/image_picker.dart';

import 'api_service.dart';
import 'auth_service.dart';
import 'token_store.dart';

/// Upload / hapus foto toko lewat backend Laravel (`PUT /my-store`).
///
/// Endpoint `/my-store` menerima JSON biasa untuk update field teks, dan
/// juga multipart (field `photo`) untuk upload file. Karena Laravel tidak
/// bisa mem-parsing body multipart untuk method PUT langsung, request
/// dikirim sebagai POST dengan method-spoofing `?_method=PUT` (konvensi
/// Laravel), yang tetap diproses oleh `StoreController::updateMyStore`.
class ProfilePhotoService {
  ProfilePhotoService._();

  static final ImagePicker _picker = ImagePicker();
  static final ApiService _api = ApiService();

  /// Pilih foto dari galeri lalu upload sebagai foto toko. Mengembalikan
  /// `photo_url` baru, atau null kalau user membatalkan pemilihan foto.
  static Future<String?> pickAndUpdatePhoto() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return null;

    return uploadStorePhoto(picked.path);
  }

  /// Upload file foto toko di [filePath] lewat `POST /my-store?_method=PUT`.
  static Future<String> uploadStorePhoto(String filePath) async {
    final data = await _api.multipart(
      'POST',
      '/my-store?_method=PUT',
      filePaths: {
        'photo': [filePath],
      },
    );

    final store = data is Map && data['store'] != null
        ? Map<String, dynamic>.from(data['store'])
        : Map<String, dynamic>.from(data as Map);

    await _refreshUserStore(store);

    return store['photo_url'] as String? ?? '';
  }

  /// Hapus foto toko (set `photo_url` jadi null lewat update JSON biasa).
  static Future<void> removePhoto() async {
    final data = await _api.put('/my-store', {'photo_url': null});

    final store = data is Map && data['store'] != null
        ? Map<String, dynamic>.from(data['store'])
        : Map<String, dynamic>.from(data as Map);

    await _refreshUserStore(store);
  }

  /// Sinkronkan `AuthState.instance.user['store']` & TokenStore dengan data
  /// toko terbaru dari server, supaya UI langsung terupdate tanpa perlu
  /// login ulang.
  static Future<void> _refreshUserStore(Map<String, dynamic> store) async {
    final currentUser = AuthState.instance.user;
    if (currentUser == null) return;

    final updatedUser = Map<String, dynamic>.from(currentUser);
    updatedUser['store'] = store;

    await TokenStore.instance.saveUser(updatedUser);
    AuthState.instance.setLoggedIn(updatedUser);
  }
}
