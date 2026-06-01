import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/task_request.dart';
import 'active_task_screen.dart';
import 'rating_screen.dart';
import '../core/auth_service.dart';
import '../core/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String? providerId;
  final String providerName;
  final String providerAvatar;
  final bool isOnline;
  final TaskRequest? request;

  const ChatScreen({
    super.key,
    this.providerId,
    this.providerName = 'Budi Santoso',
    this.providerAvatar = 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&auto=format&fit=crop',
    this.isOnline = true,
    this.request,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  String _myName = 'Pengguna';
  String _myAvatar = '';

  bool get _isMockMode => widget.providerId == null || widget.providerId!.startsWith('mock_');

  @override
  void initState() {
    super.initState();
    _loadSenderInfo();
    MockChatStore.instance.addListener(_onMockChatStoreChanged);
  }

  void _onMockChatStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSenderInfo() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _myName = user?['name'] ?? 'Pengguna';
        _myAvatar = user?['avatarUrl'] ?? '';
      });
    }
  }

  void _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    if (_isMockMode) {
      MockChatStore.instance.addMessage(widget.providerName, text, true);
    } else {
      await ChatService.sendMessage(
        recipientId: widget.providerId!,
        recipientName: widget.providerName,
        recipientAvatar: widget.providerAvatar,
        senderName: _myName,
        senderAvatar: _myAvatar,
        text: text,
      );
    }
    _inputController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    MockChatStore.instance.removeListener(_onMockChatStoreChanged);
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
                PionAvatar(radius: 20, url: widget.providerAvatar),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.providerName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.isOnline ? 'Online' : 'Terakhir aktif baru saja',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_rounded), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle()), behavior: SnackBarBehavior.floating))),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (v) {
              if (v == 'active') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ActiveTaskScreen(request: widget.request)));
              }
              if (v == 'rate') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RatingScreen(
                  taskId: widget.request?.id ?? '',
                  workerName: widget.providerName,
                  workerAvatar: widget.providerAvatar,
                  taskTitle: widget.request?.title ?? 'Pekerjaan',
                )));
              }
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
            child: _isMockMode
                ? Builder(
                    builder: (context) {
                      final mockMsgs = MockChatStore.instance.getMessages(widget.providerName);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                        }
                      });
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        itemCount: mockMsgs.length,
                        itemBuilder: (_, i) {
                          final msg = mockMsgs[i];
                          final showDate = i == 0;
                          return Column(
                            children: [
                              if (showDate)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Text('Hari ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                                ),
                              _buildBubble(msg.text, msg.isMe, msg.time, theme),
                            ],
                          );
                        },
                      );
                    },
                  )
                : StreamBuilder<List<ChatMessage>>(
                    stream: ChatService.listenToMessages(widget.providerId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final list = snapshot.data ?? [];
                      // Scroll to bottom when new message arrives
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                        }
                      });
                      
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final msg = list[i];
                          final showDate = i == 0;
                          final timeStr = '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';
                          final isMe = msg.senderId == ChatService.currentUserId;
                          return Column(
                            children: [
                              if (showDate)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: Text('Hari ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                                ),
                              _buildBubble(msg.text, isMe, timeStr, theme),
                            ],
                          );
                        },
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
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur sedang dalam tahap perbaikan', style: TextStyle()), behavior: SnackBarBehavior.floating)),
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

  Widget _buildBubble(String text, bool isMe, String time, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            PionAvatar(radius: 16, url: widget.providerAvatar),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? theme.colorScheme.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: isMe ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))] : null,
                ),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 14, color: isMe ? Colors.white : const Color(0xFF0F172A), height: 1.5),
                ),
              ),
              const SizedBox(height: 6),
              Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
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
