import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pesan'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating))),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1), 
          child: Container(height: 1, color: theme.dividerColor),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFC6D8FF)],
            stops: [0.3, 1.0],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _chatItem(
            context,
            name: 'Budi Santoso',
            message: 'Baik, saya akan segera meluncur ke lokasi.',
            time: '10:42',
            unreadCount: 2,
            isOnline: true,
            avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop',
          ),
          _chatItem(
            context,
            name: 'Siti Aminah',
            message: 'Terima kasih! Tugas sudah saya selesaikan.',
            time: 'Kemarin',
            unreadCount: 0,
            isOnline: false,
            avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&auto=format&fit=crop',
          ),
          _chatItem(
            context,
            name: 'Andi Pratama',
            message: 'Apakah ada tambahan alat yang perlu dibawa?',
            time: 'Senin',
            unreadCount: 0,
            isOnline: true,
            avatarUrl: 'https://images.unsplash.com/photo-1600868620786-641e737119b4?q=80&w=200&auto=format&fit=crop',
          ),
        ],
      ),
      ),
    );
  }

  Widget _chatItem(BuildContext context, {
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    required bool isOnline,
    required String avatarUrl,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: unreadCount > 0 ? const Color(0xFFF8FAFC) : Colors.transparent,
          border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(radius: 28, backgroundImage: NetworkImage(avatarUrl)),
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
                      Text(name, style: TextStyle(fontSize: 16, fontWeight: unreadCount > 0 ? FontWeight.w800 : FontWeight.w700, color: const Color(0xFF0F172A))),
                      Text(time, style: TextStyle(fontSize: 12, fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w500, color: unreadCount > 0 ? theme.colorScheme.primary : const Color(0xFF94A3B8))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400, color: unreadCount > 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(20)),
                          child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
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
