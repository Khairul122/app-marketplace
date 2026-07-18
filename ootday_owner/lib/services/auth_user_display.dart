/// Nama & foto untuk tampilan profil dari data user Laravel (`Map<String, dynamic>`).
class AuthUserDisplay {
  AuthUserDisplay._();

  static String name(Map<String, dynamic>? user) {
    if (user == null) return 'Tamu';

    final name = (user['name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = (user['email'] as String?)?.trim();
    if (email != null && email.contains('@')) {
      final local = email.split('@').first.trim();
      if (local.isNotEmpty) {
        return local[0].toUpperCase() + local.substring(1);
      }
    }

    return 'Pengguna';
  }

  static String? photoUrl(Map<String, dynamic>? user) {
    final store = user?['store'] as Map<String, dynamic>?;
    final url = (store?['photo_url'] as String?)?.trim();
    if (url == null || url.isEmpty) return null;
    return url;
  }
}
