import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _threads = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _api.get('/chat/threads');
      final List rawList = (result is Map && result['data'] is List) ? result['data'] : result;
      setState(() {
        _threads = List<Map<String, dynamic>>.from(rawList);
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat daftar chat';
      });
    }
  }

  String _formatTime(dynamic value) {
    if (value == null) return '';
    try {
      final date = DateTime.parse(value.toString()).toLocal();
      final now = DateTime.now();
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      String two(int n) => n.toString().padLeft(2, '0');
      if (isToday) return '${two(date.hour)}:${two(date.minute)}';
      return '${two(date.day)}-${two(date.month)}-${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color bgColor = Color(0xFFF8F3F3);

    final filteredThreads = _searchQuery.isEmpty
        ? _threads
        : _threads.where((t) {
            final store = t['store'] is Map ? t['store'] as Map : {};
            final name = (store['store_name'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: maroonColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chat',
          style: GoogleFonts.outfit(
            color: maroonColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: maroonColor),
            onPressed: _loadThreads,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar di Chat
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  hintText: 'Cari percakapan...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // List Chat
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_errorMessage!, style: GoogleFonts.outfit(color: Colors.black54)),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadThreads,
                              style: ElevatedButton.styleFrom(backgroundColor: maroonColor),
                              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : filteredThreads.isEmpty
                        ? Center(child: Text('Belum ada percakapan', style: GoogleFonts.outfit(color: Colors.black54)))
                        : RefreshIndicator(
                            onRefresh: _loadThreads,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: filteredThreads.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
                              itemBuilder: (context, index) {
                                final thread = filteredThreads[index];
                                final store = thread['store'] is Map ? Map<String, dynamic>.from(thread['store']) : <String, dynamic>{};
                                final storeName = (store['store_name'] ?? 'Toko').toString();
                                final photoUrl = store['photo_url']?.toString();

                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatDetailScreen(
                                          threadId: thread['id'] as int,
                                          storeName: storeName,
                                          storePhotoUrl: photoUrl,
                                        ),
                                      ),
                                    );
                                  },
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                                    child: (photoUrl == null || photoUrl.isEmpty) ? const Icon(Icons.storefront, color: Colors.white) : null,
                                  ),
                                  title: Text(
                                    storeName,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Ketuk untuk membuka percakapan',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: Text(
                                    _formatTime(thread['last_message_at']),
                                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
