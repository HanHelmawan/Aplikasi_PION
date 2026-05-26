import 'package:flutter/material.dart';
import 'chat_screen.dart';

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

  static const List<Map<String, dynamic>> _chats = [
    {
      'name': 'Budi Santoso',
      'message': 'Baik, saya akan segera meluncur ke lokasi.',
      'time': '10:42',
      'unread': 2,
      'isOnline': true,
      'isDone': false,
      'avatarUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop',
    },
    {
      'name': 'Siti Aminah',
      'message': 'Terima kasih! Tugas sudah saya selesaikan.',
      'time': 'Kemarin',
      'unread': 0,
      'isOnline': false,
      'isDone': true,
      'avatarUrl': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&auto=format&fit=crop',
    },
    {
      'name': 'Andi Pratama',
      'message': 'Apakah ada tambahan alat yang perlu dibawa?',
      'time': 'Senin',
      'unread': 0,
      'isOnline': true,
      'isDone': false,
      'avatarUrl': 'https://images.unsplash.com/photo-1600868620786-641e737119b4?q=80&w=200&auto=format&fit=crop',
    },
    {
      'name': 'Rudi Hartono',
      'message': 'Harga sudah kami sepakati ya, terima kasih.',
      'time': 'Minggu',
      'unread': 0,
      'isOnline': false,
      'isDone': true,
      'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    switch (_filterIndex) {
      case 1:
        return _chats.where((c) => c['isOnline'] as bool).toList();
      case 2:
        return _chats.where((c) => c['isDone'] as bool).toList();
      default:
        return _chats;
    }
  }

  int get _onlineCount => _chats.where((c) => c['isOnline'] as bool).length;

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
            colors: [Colors.white, Theme.of(context).primaryColor.withOpacity(0.08)],
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
              title: const Text(
                'Pesan',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search_rounded, color: Theme.of(context).primaryColor),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cari pesan — segera hadir', style: TextStyle(fontFamily: 'Inter')),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                          fontFamily: 'Inter',
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
                          children: _chats
                              .where((c) => c['isOnline'] as bool)
                              .toList()
                              .asMap()
                              .entries
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
                child: filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 12, bottom: 100),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
                fontFamily: 'Inter',
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
                style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            const Text('Pesan dari mitra akan muncul di sini',
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF64748B))),
          ],
        ),
      );

  Widget _chatItem(Map<String, dynamic> chat) {
    final unread = chat['unread'] as int;
    final isOnline = chat['isOnline'] as bool;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => ChatScreen(
            providerName: chat['name'] as String,
            providerAvatar: chat['avatarUrl'] as String,
            isOnline: chat['isOnline'] as bool,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        chat['time'] as String,
                        style: TextStyle(
                          fontFamily: 'Inter',
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
                            fontFamily: 'Inter',
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
                              fontFamily: 'Inter',
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
