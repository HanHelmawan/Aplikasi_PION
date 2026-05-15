import 'package:flutter/material.dart';
import 'active_task_screen.dart';
import 'rating_screen.dart';

class ChatScreen extends StatefulWidget {
  final String providerName;
  final String providerAvatar;
  final bool isOnline;

  const ChatScreen({
    super.key,
    this.providerName = 'Budi Santoso',
    this.providerAvatar = 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop',
    this.isOnline = true,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  final List<_Message> _messages = [
    _Message(text: 'Halo! Saya Budi, saya melihat permintaan Anda tentang perbaikan pipa.', isMe: false, time: '10:32'),
    _Message(text: 'Bisa ceritakan lebih detail? Apakah pipa bocor atau tersumbat?', isMe: false, time: '10:32'),
    _Message(text: 'Halo Budi! Pipa di kamar mandi bocor, air menetes dari sambungan pipa.', isMe: true, time: '10:35'),
    _Message(text: 'Sudah berapa lama? Dan apakah ada kerusakan di sekitarnya?', isMe: false, time: '10:36'),
    _Message(text: 'Baru sejak kemarin. Belum ada kerusakan besar, tapi cukup mengganggu.', isMe: true, time: '10:38'),
    _Message(text: 'Baik, saya bisa datang hari ini jam 2 siang. Estimasi pengerjaan 1-2 jam.', isMe: false, time: '10:40'),
  ];

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isMe: true, time: _timeNow()));
    });
    _inputController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _timeNow() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.providerAvatar)),
                if (widget.isOnline)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.providerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                Text(widget.isOnline ? 'Online' : 'Terakhir aktif baru saja',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_rounded), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating))),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (v) {
              if (v == 'active') Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveTaskScreen()));
              if (v == 'rate') Navigator.push(context, MaterialPageRoute(builder: (_) => const RatingScreen()));
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'active', child: Text('Lihat Tugas Aktif')),
              const PopupMenuItem(value: 'rate', child: Text('Beri Ulasan')),
            ],
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: theme.dividerColor)),
      ),
      body: Column(
        children: [
          // ── Status Banner ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: const Color(0xFFEEF0FF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 16),
                const SizedBox(width: 8),
                Text('Tugas sedang dalam proses negosiasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
              ],
            ),
          ),

          // ── Messages ──────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final showDate = i == 0;
                return Column(
                  children: [
                    if (showDate)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text('Hari ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                      ),
                    _buildBubble(msg, theme),
                  ],
                );
              },
            ),
          ),

          // ── Input ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, -4))],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF94A3B8)),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle(fontFamily: 'Inter')), behavior: SnackBarBehavior.floating)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: TextField(
                      controller: _inputController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Tulis pesan...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_Message msg, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe) ...[
            CircleAvatar(radius: 16, backgroundImage: NetworkImage(widget.providerAvatar)),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: msg.isMe ? theme.colorScheme.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(msg.isMe ? 20 : 4),
                    bottomRight: Radius.circular(msg.isMe ? 4 : 20),
                  ),
                  border: msg.isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: msg.isMe ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))] : null,
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(fontSize: 14, color: msg.isMe ? Colors.white : const Color(0xFF0F172A), height: 1.5),
                ),
              ),
              const SizedBox(height: 6),
              Text(msg.time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isMe;
  final String time;
  const _Message({required this.text, required this.isMe, required this.time});
}
