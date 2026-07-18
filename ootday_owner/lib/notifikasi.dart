import 'package:flutter/material.dart';
import 'package:ootday_owner/widgets/owner_bottom_nav.dart';
import 'home_page.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    try {
      final data = await _notificationService.getNotifications();
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } on ApiException catch (e) {
      _notify(e.message, isError: true);
      return <Map<String, dynamic>>[];
    } catch (_) {
      _notify('Gagal memuat notifikasi.', isError: true);
      return <Map<String, dynamic>>[];
    }
  }

  void _notify(String message, {bool isError = false}) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    });
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  Future<void> _onTapNotif(Map<String, dynamic> notif) async {
    if (notif['is_read'] == true) return;
    final id = notif['id'];
    if (id == null) return;
    try {
      await _notificationService.markRead(id as int);
      await _refresh();
    } on ApiException catch (e) {
      _notify(e.message, isError: true);
    } catch (_) {
      _notify('Gagal menandai notifikasi sebagai dibaca.', isError: true);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _notificationService.markAllRead();
      _notify('Semua notifikasi ditandai sudah dibaca.');
      await _refresh();
    } on ApiException catch (e) {
      _notify(e.message, isError: true);
    } catch (_) {
      _notify('Gagal menandai semua notifikasi.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===================== APPBAR MERAH GRADIENT =====================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffb30505), Color(0xffd92b2b)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 15, right: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomePage(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Notifikasi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _markAllRead,
                    child: const Text(
                      'Tandai semua dibaca',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ===================== BODY =====================
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data ?? <Map<String, dynamic>>[];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: notifications.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    children: [
                      Icon(Icons.notifications_none, size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Belum ada notifikasi.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return GestureDetector(
                        onTap: () => _onTapNotif(notif),
                        child: NotifCard(
                          title: notif['title']?.toString() ?? '',
                          desc: notif['body']?.toString() ?? '',
                          isRead: notif['is_read'] == true,
                        ),
                      );
                    },
                  ),
          );
        },
      ),

      bottomNavigationBar: const OwnerBottomNav(currentIndex: 2),
    );
  }
}

// ====================== NOTIF CARD ======================
class NotifCard extends StatelessWidget {
  final String title;
  final String desc;
  final bool isRead;

  const NotifCard({
    super.key,
    required this.title,
    required this.desc,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isRead ? const Color(0xffe7e7e7) : const Color(0xfff7dede),
        borderRadius: BorderRadius.circular(12),
        border: isRead ? null : Border.all(color: const Color(0xffb30505), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xffb30505),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xffb30505),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
