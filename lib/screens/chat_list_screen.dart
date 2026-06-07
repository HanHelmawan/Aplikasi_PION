import 'package:flutter/material.dart';
import '../models/task_request.dart';
import 'chat_screen.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/chat_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  int _filterIndex = 0; // 0=Semua, 1=Aktif, 2=Selesai

  List<Map<String, dynamic>> _firestoreChats = [];
  StreamSubscription? _chatRoomsSubscription;
  bool _isSearching = false;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _initChatRoomsListener();
  }

  void _initChatRoomsListener() {
    // Set a tiny delay so Auth service is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      final myId = ChatService.currentUserId;
      if (myId.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      _chatRoomsSubscription = ChatService.listenToChatRooms().listen((snapshot) {
        final List<Map<String, dynamic>> loaded = [];
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) continue;

          final participants = List<String>.from(data['participants'] ?? []);
          final recipientId = participants.firstWhere((id) => id != myId, orElse: () => '');
          if (recipientId.isEmpty) continue;

          final recipientData = data['user_$recipientId'] as Map<String, dynamic>? ?? {};
          final recipientName = recipientData['name'] ?? 'Pengguna Pion';
          final recipientAvatar = recipientData['avatarUrl'] ?? '';

          final lastMsg = data['lastMessage'] as Map<String, dynamic>? ?? {};
          final lastText = lastMsg['text'] ?? '';
          final ts = lastMsg['timestamp'];

          String timeStr = 'Baru saja';
          if (ts is Timestamp) {
            final date = ts.toDate();
            final now = DateTime.now();
            final diff = now.difference(date);
            if (diff.inDays == 0) {
              timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
            } else if (diff.inDays == 1) {
              timeStr = 'Kemarin';
            } else if (diff.inDays < 7) {
              const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
              timeStr = days[date.weekday - 1];
            } else {
              timeStr = '${date.day}/${date.month}';
            }
          }

          // Unread count untuk user saat ini
          final unread = (data['unread_$myId'] as int?) ?? 0;

          loaded.add({
            'name': recipientName,
            'message': lastText,
            'time': timeStr,
            'unread': unread,
            'isOnline': true,
            'isDone': false,
            'avatarUrl': recipientAvatar.isNotEmpty
                ? recipientAvatar
                : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
            'providerId': recipientId,
          });
        }

        // Juga tambahkan chat dari TaskRequestStore (worker yang sudah ditetapkan)
        final requests = TaskRequestStore.instance.requests;
        for (var r in requests) {
          if (r.assignedWorkerName != null &&
              r.assignedWorkerName!.isNotEmpty &&
              !loaded.any((c) => c['providerId'] == (r.assignedWorkerPhone ?? r.assignedWorkerName))) {
            // Hanya tampilkan jika belum ada di Firestore chats
            if (!loaded.any((c) => c['name'] == r.assignedWorkerName)) {
              final defaultMsg = r.status == RequestStatus.selesai
                  ? 'Pekerjaan selesai: ${r.title}'
                  : 'Pekerjaan aktif: ${r.title}';
              final defaultTime =
                  '${r.createdAt.hour.toString().padLeft(2, '0')}:${r.createdAt.minute.toString().padLeft(2, '0')}';

              loaded.add({
                'name': r.assignedWorkerName!,
                'message': defaultMsg,
                'time': defaultTime,
                'unread': 0,
                'isOnline': r.status == RequestStatus.dikerjakan,
                'isDone': r.status == RequestStatus.selesai,
                'avatarUrl': r.assignedWorkerAvatar ??
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
                'request': r,
                'providerId': null, // Worker belum terdaftar di Firestore auth
              });
            }
          }
        }

        if (mounted) {
          setState(() {
            _firestoreChats = loaded;
            _isLoading = false;
          });
        }
      }, onError: (e) {
        debugPrint('ChatListScreen stream error: $e');
        if (mounted) setState(() => _isLoading = false);
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _chatRoomsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    List<Map<String, dynamic>> statusFiltered;
    switch (_filterIndex) {
      case 1:
        statusFiltered = _firestoreChats.where((c) => c['isOnline'] as bool).toList();
        break;
      case 2:
        statusFiltered = _firestoreChats.where((c) => c['isDone'] as bool).toList();
        break;
      default:
        statusFiltered = _firestoreChats;
        break;
    }

    if (_isSearching && _searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      return statusFiltered.where((c) {
        final name = (c['name'] as String).toLowerCase();
        final msg = (c['message'] as String).toLowerCase();
        return name.contains(query) || msg.contains(query);
      }).toList();
    }

    return statusFiltered;
  }

  int get _onlineCount => _firestoreChats.where((c) => c['isOnline'] as bool).length;

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Theme.of(context).primaryColor.withValues(alpha: 0.08)],
            stops: const [0.3, 1.0],
          ),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau pesan...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                        border: InputBorder.none,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B)),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    )
                  : const Text(
                      'Pesan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close_rounded : Icons.search_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isSearching) {
                        _isSearching = false;
                        _searchController.clear();
                      } else {
                        _isSearching = true;
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      _filterChip('Semua', 0),
                      const SizedBox(width: 8),
                      _filterChip('Aktif', 1, dotColor: const Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      _filterChip('Selesai', 2),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: Column(
            children: [
              // ── Online Status Header ──────────────────────────────────────
              if (_onlineCount > 0)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (ctx, child) => Opacity(
                          opacity: _pulseAnim.value,
                          child: Container(
                            width: 10, height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$_onlineCount kontak sedang aktif',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                      const Spacer(),
                      // Online avatars row
                      SizedBox(
                        height: 28,
                        width: 56,
                        child: Stack(
                          children: _firestoreChats
                              .where((c) => c['isOnline'] as bool)
                              .toList()
                              .asMap()
                              .entries
                              .take(3)
                              .map((e) => Positioned(
                                    left: e.key * 18.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFFF0FDF4), width: 2),
                                      ),
                                      child: CircleAvatar(
                                        radius: 13,
                                        backgroundImage: NetworkImage(e.value['avatarUrl'] as String),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Chat List ─────────────────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 80),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) => _chatItem(filtered[i]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, int index, {Color? dotColor}) {
    final isSelected = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: const BoxDecoration(color: Color(0xFFEEF0FF), shape: BoxShape.circle),
              child: Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 20),
            const Text('Belum Ada Pesan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            const Text('Pesan dari mitra akan muncul di sini',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          ],
        ),
      );

  Widget _chatItem(Map<String, dynamic> chat) {
    final unread = chat['unread'] as int;
    final isOnline = chat['isOnline'] as bool;

    return InkWell(
      onTap: () {
        TaskRequest? matchedReq;
        if (chat['request'] != null) {
          matchedReq = chat['request'] as TaskRequest;
        } else {
          try {
            matchedReq = TaskRequestStore.instance.requests.firstWhere(
              (r) => r.assignedWorkerName == chat['name'],
            );
          } catch (_) {}
        }

        final providerId = chat['providerId'] as String?;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ChatScreen(
              providerId: providerId,
              providerName: chat['name'] as String,
              providerAvatar: chat['avatarUrl'] as String,
              isOnline: chat['isOnline'] as bool,
              request: matchedReq,
            ),
          ),
        ).then((_) {
          // Refresh setelah kembali agar unread count diperbarui
          setState(() {});
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: unread > 0 ? const Color(0xFFF8FAFC) : Colors.transparent,
          border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(chat['avatarUrl'] as String),
                ),
                if (isOnline)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        chat['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                          color: unread > 0 ? Theme.of(context).primaryColor : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['message'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                            color: unread > 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
