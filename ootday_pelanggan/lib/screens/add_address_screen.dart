import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/address_data.dart';
import '../services/api_service.dart';

class AddAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? address;
  const AddAddressScreen({super.key, this.address});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _provinceController;
  late TextEditingController _zipController;
  late TextEditingController _streetController;
  late TextEditingController _detailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?['name'] ?? '');
    _phoneController = TextEditingController(text: widget.address?['phone'] ?? '');
    
    // Parsing fullAddress jika ada untuk mengembalikan ke field masing-masing (sederhana)
    String full = widget.address?['fullAddress'] ?? '';
    List<String> lines = full.split('\n');
    _streetController = TextEditingController(text: lines.isNotEmpty ? lines[0] : '');
    
    _provinceController = TextEditingController(text: '');
    _zipController = TextEditingController(text: '');
    _detailController = TextEditingController(text: '');
  }

  Future<void> _saveAddress(bool isMain) async {
    String fullAddr = '${_streetController.text}\n${_provinceController.text} ${_zipController.text}';
    final newAddr = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'fullAddress': fullAddr,
      'isMain': isMain,
    };

    try {
      if (widget.address != null && widget.address!['id'] != null) {
        // Update existing
        await AddressData.updateAddress(widget.address!['id'].toString(), newAddr);
      } else {
        // Add new
        await AddressData.addAddress(newAddr);
      }
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan alamat. Periksa koneksi jaringan.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color accentMaroon = Color(0xFFB01D1D);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: maroonColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.address != null ? 'Edit Alamat' : 'Tambah alamat',
          style: GoogleFonts.outfit(color: maroonColor, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade300),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION: INFORMASI PENERIMA
            _buildSectionTitle('Informasi Penerima', maroonColor),
            _buildInputField('*Nama', _nameController, maroonColor),
            _buildInputField('*No.Handphone', _phoneController, maroonColor),
            
            const SizedBox(height: 10),
            
            // SECTION: ALAMAT PENERIMA
            _buildSectionTitle('Alamat Penerima', maroonColor),
            _buildInputField('*Provinsi, Kota/Kabupaten & Kecamatan', _provinceController, maroonColor),
            _buildInputField('*Kode Pos', _zipController, maroonColor),
            _buildInputField('*Nama jalan', _streetController, maroonColor),
            _buildInputField('*Detail', _detailController, maroonColor),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _buildBottomButton('Simpan', accentMaroon, () => _saveAddress(false)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildBottomButton('Simpan sebagai alamat utama', accentMaroon, () => _saveAddress(true)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        title,
        style: GoogleFonts.outfit(color: color, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(color: color, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          TextField(
            controller: controller,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: color)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
