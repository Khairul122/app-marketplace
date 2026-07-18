import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'services/auth_service.dart';

class InformasiToko extends StatefulWidget {
  const InformasiToko({super.key});

  @override
  State<InformasiToko> createState() => _InformasiTokoState();
}

class _InformasiTokoState extends State<InformasiToko> {
  final Color redMain = const Color(0xFFB40001);
  final Color darkRed = const Color(0xFF7A0000);

  final ApiService _api = ApiService();

  late final TextEditingController _namaTokoController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _alamatController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final store = AuthState.instance.user?['store'] as Map<String, dynamic>?;
    _namaTokoController =
        TextEditingController(text: (store?['store_name'] as String?) ?? '');
    _deskripsiController =
        TextEditingController(text: (store?['description'] as String?) ?? '');
    _alamatController =
        TextEditingController(text: (store?['address'] as String?) ?? '');
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _deskripsiController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final data = await _api.put('/my-store', {
        'store_name': _namaTokoController.text.trim(),
        'description': _deskripsiController.text.trim(),
        'address': _alamatController.text.trim(),
      });

      final updatedStore = data is Map && data['store'] != null
          ? Map<String, dynamic>.from(data['store'])
          : null;

      if (updatedStore != null) {
        final currentUser = AuthState.instance.user;
        if (currentUser != null) {
          final updatedUser = Map<String, dynamic>.from(currentUser);
          updatedUser['store'] = updatedStore;
          AuthState.instance.setLoggedIn(updatedUser);
        }
      } else {
        await AuthService().restoreSession();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informasi toko berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _inputField(
                      label: 'Nama toko',
                      controller: _namaTokoController,
                    ),
                    const SizedBox(height: 16),
                    _inputField(
                      label: 'Deskripsi Toko',
                      controller: _deskripsiController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _inputField(
                      label: 'Alamat',
                      controller: _alamatController,
                    ),
                    const SizedBox(height: 40),
                    _saveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [redMain, darkRed],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
            const Expanded(
              child: Text(
                'Informasi Toko',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 40), // Balance untuk centering
          ],
        ),
      ),
    );
  }

  // ================= INPUT FIELD =================
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: redMain,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // ================= SAVE BUTTON =================
  Widget _saveButton() {
    return Center(
      child: SizedBox(
        width: 180,
        height: 50,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: redMain,
            disabledBackgroundColor: redMain.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Simpan Perubahan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

