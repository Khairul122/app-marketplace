import 'package:flutter/material.dart';
import 'package:ootday_owner/room_chat.dart';
import 'services/api_service.dart';
import 'services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  late Future<List<Map<String, dynamic>>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    try {
      final data = await _chatService.getThreads();
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on ApiException catch (e) {
      _notifyError(e.message);
      return <Map<String, dynamic>>[];
    } catch (_) {
      _notifyError('Gagal memuat daftar chat.');
      return <Map<String, dynamic>>[];
    }
  }

  void _notifyError(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    });
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ==================== APP BAR ====================
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ==================== BODY ====================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            searchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var threads = snapshot.data ?? <Map<String, dynamic>>[];
                  if (_query.trim().isNotEmpty) {
                    final q = _query.trim().toLowerCase();
                    threads = threads.where((t) {
                      final customer = t['customer'] is Map
                          ? Map<String, dynamic>.from(t['customer'] as Map)
                          : <String, dynamic>{};
                      final name = (customer['name']?.toString() ?? '').toLowerCase();
                      return name.contains(q);
                    }).toList();
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: threads.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 60),
                              Icon(Icons.chat_bubble_outline, size: 56, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  'Belum ada percakapan.',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: threads.length,
                            itemBuilder: (context, index) {
                              final thread = threads[index];
                              final customer = thread['customer'] is Map
                                  ? Map<String, dynamic>.from(thread['customer'] as Map)
                                  : <String, dynamic>{};
                              return chatItem(
                                context: context,
                                threadId: thread['id'] as int,
                                name: customer['name']?.toString() ?? 'Pelanggan',
                                time: _formatTime(thread['last_message_at']?.toString()),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SEARCH BAR ====================
  Widget searchBar() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Cari',
                hintStyle: TextStyle(color: Colors.black54),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CHAT ITEM ====================
  Widget chatItem({
    required BuildContext context,
    required int threadId,
    required String name,
    required String time,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailPage(threadId: threadId, name: name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red),
              ),
              child: const Icon(Icons.person_outline, color: Colors.red),
            ),

            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ketuk untuk membuka percakapan',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Time
            Text(
              time,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
