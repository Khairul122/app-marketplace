import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_address_screen.dart';
import '../utils/address_data.dart';
import '../services/api_service.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final addrs = await AddressData.getAddresses();
    if (mounted) {
      setState(() {
        _addresses = addrs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color lightBg = Color(0xFFE8E4E4);

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: maroonColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Alamat',
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _addresses.isEmpty
                      ? Center(
                          child: Text('Belum ada alamat tersimpan', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey)),
                        )
                      : ListView.builder(
                          itemCount: _addresses.length,
                          itemBuilder: (context, index) {
                            final addr = _addresses[index];
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: maroonColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${addr['name']} ${addr['phone']}',
                                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      if (addr['isMain'] == true)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Utama',
                                            style: GoogleFonts.outfit(color: maroonColor, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    addr['fullAddress'],
                                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.4),
                                  ),
                                  const SizedBox(height: 15),
                                  const Divider(color: Colors.white30),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await Navigator.push(
                                            context, 
                                            MaterialPageRoute(
                                              builder: (context) => AddAddressScreen(address: addr)
                                            )
                                          );
                                          _loadAddresses();
                                        },
                                        child: _buildActionText('Edit'),
                                      ),
                                      const SizedBox(width: 30),
                                      GestureDetector(
                                        onTap: () async {
                                          try {
                                            await AddressData.deleteAddress(addr['id'].toString());
                                            _loadAddresses();
                                          } on ApiException catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.message)),
                                              );
                                            }
                                          }
                                        },
                                        child: _buildActionText('Hapus'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                
                // 2. Bottom Button
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAddressScreen()));
                      _loadAddresses();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB01D1D),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Tambah Alamat',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionText(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }
}
