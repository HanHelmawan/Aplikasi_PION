import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../models/task_request.dart';
import 'active_task_screen.dart';
import 'rating_screen.dart';
import '../core/auth_service.dart';
import '../core/chat_service.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String? providerId;
  final String providerName;
  final String providerAvatar;
  final bool isOnline;
  final TaskRequest? request;

  const ChatScreen({
    super.key,
    this.providerId,
    this.providerName = 'Mitra Pion',
    this.providerAvatar = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop',
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
  String _providerPhone = '';
  bool _isOnline = false;
  StreamSubscription? _providerStatusSubscription;

  /// True jika providerId tidak ada — chat tidak bisa dilakukan via Firestore
  bool get _isReadOnly => widget.providerId == null;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.isOnline;
    _loadSenderInfo();
    if (!_isReadOnly) {
      _loadProviderInfo();
      _subscribeToProviderStatus();
      // Reset unread count saat membuka chatroom
      ChatService.markMessagesRead(widget.providerId!);
    } else {
      // Untuk request yang worker-nya belum terdaftar di Firebase Auth,
      // coba ambil nomor dari assignedWorkerPhone
      _providerPhone = widget.request?.assignedWorkerPhone ?? '';
    }
  }

  void _subscribeToProviderStatus() {
    if (widget.providerId == null) return;
    _providerStatusSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.providerId)
        .snapshots()
        .listen((snap) {
      if (snap.exists && mounted) {
        final userData = snap.data() ?? {};
        bool online = userData['isOnline'] as bool? ?? false;
        if (!online && userData.containsKey('workerProfile')) {
          final profile = userData['workerProfile'] as Map<String, dynamic>? ?? {};
          online = profile['isOnline'] as bool? ?? false;
        }
        setState(() {
          _isOnline = online;
        });
      }
    });
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

  Future<void> _loadProviderInfo() async {
    if (widget.providerId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.providerId)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          _providerPhone = data?['phone'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading provider info: $e');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka dialer telepon'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan panggilan: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kirim Lampiran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentItem(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  color: const Color(0xFFEC4899),
                  onTap: () => _sendAttachment('[📷 Foto Kamera]'),
                ),
                _buildAttachmentItem(
                  icon: Icons.image_rounded,
                  label: 'Galeri',
                  color: const Color(0xFF3B82F6),
                  onTap: () => _sendAttachment('[🖼️ Foto Galeri]'),
                ),
                _buildAttachmentItem(
                  icon: Icons.description_rounded,
                  label: 'Dokumen',
                  color: const Color(0xFF10B981),
                  onTap: () => _sendAttachment('[📄 Dokumen PDF]'),
                ),
                _buildAttachmentItem(
                  icon: Icons.location_on_rounded,
                  label: 'Lokasi',
                  color: const Color(0xFFF59E0B),
                  onTap: () => _sendAttachment('[📍 Lokasi Saat Ini]'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  void _sendAttachment(String typeLabel) {
    Navigator.pop(context);
    if (_isReadOnly) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat hanya tersedia untuk mitra yang terdaftar di Pion'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ChatService.sendMessage(
      recipientId: widget.providerId!,
      recipientName: widget.providerName,
      recipientAvatar: widget.providerAvatar,
      senderName: _myName,
      senderAvatar: _myAvatar,
      text: typeLabel,
    );
    _scrollToBottom();
  }

  void _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    if (_isReadOnly) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat hanya tersedia untuk mitra yang terdaftar di Pion'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await ChatService.sendMessage(
      recipientId: widget.providerId!,
      recipientName: widget.providerName,
      recipientAvatar: widget.providerAvatar,
      senderName: _myName,
      senderAvatar: _myAvatar,
      text: text,
    );
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
    _providerStatusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                PionAvatar(radius: 20, url: widget.providerAvatar),
                if (_isOnline)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _isOnline ? 'Online' : 'Terakhir aktif baru saja',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_rounded),
            onPressed: () {
              final phone = _providerPhone.isNotEmpty
                  ? _providerPhone
                  : (widget.request?.assignedWorkerPhone ?? '');
              if (phone.isNotEmpty) {
                _makePhoneCall(phone);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nomor telepon tidak tersedia'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (v) {
              if (v == 'active') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActiveTaskScreen(request: widget.request),
                  ),
                );
              }
              if (v == 'rate') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RatingScreen(
                      taskId: widget.request?.id ?? '',
                      workerName: widget.providerName,
                      workerAvatar: widget.providerAvatar,
                      taskTitle: widget.request?.title ?? 'Pekerjaan',
                    ),
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'active', child: Text('Lihat Tugas Aktif')),
              const PopupMenuItem(value: 'rate', child: Text('Beri Ulasan')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: theme.dividerColor),
        ),
      ),
      body: Column(
        children: [
          // ── Status Banner ─────────────────────────────────────────────────
          if (widget.request != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: const Color(0xFFEEF0FF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: theme.colorScheme.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Tugas: ${widget.request!.title}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

          // ── Read-only warning jika providerId null ─────────────────────
          if (_isReadOnly)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: const Color(0xFFFFF7ED),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mitra ini belum terdaftar di Pion. Chat tidak tersedia.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Messages ──────────────────────────────────────────────────────
          Expanded(
            child: _isReadOnly
                ? _buildReadOnlyState()
                : StreamBuilder<List<ChatMessage>>(
                    stream: ChatService.listenToMessages(widget.providerId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Gagal memuat pesan: ${snapshot.error}',
                            style: const TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        );
                      }
                      final list = snapshot.data ?? [];

                      // Jika ada pesan masuk yang belum dibaca dari lawan bicara, tandai sebagai dibaca
                      final hasUnreadFromOther = list.any((msg) =>
                          msg.senderId == widget.providerId && !msg.isRead);
                      if (hasUnreadFromOther) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ChatService.markMessagesRead(widget.providerId!);
                        });
                      }

                      // Scroll to bottom when new message arrives
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients &&
                            _scrollController.position.maxScrollExtent > 0) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        }
                      });

                      if (list.isEmpty) {
                        return _buildEmptyChat();
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final msg = list[i];
                          final showDate = i == 0;
                          final timeStr =
                              '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';
                          final isMe =
                              msg.senderId == ChatService.currentUserId;
                          return Column(
                            children: [
                              if (showDate)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Text(
                                    _formatDateLabel(msg.timestamp),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              _buildBubble(msg.text, isMe, timeStr, msg.isRead, theme),
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
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 20,
                  offset: Offset(0, -4),
                )
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file_rounded,
                      color: Color(0xFF94A3B8)),
                  onPressed: _showAttachmentOptions,
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
                      enabled: !_isReadOnly,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: _isReadOnly
                            ? 'Chat tidak tersedia'
                            : 'Tulis pesan...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isReadOnly
                          ? const Color(0xFFCBD5E1)
                          : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: _isReadOnly
                          ? null
                          : [
                              BoxShadow(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_off_rounded,
                  size: 40, color: Color(0xFFD97706)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chat Tidak Tersedia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Mitra ini belum terdaftar sebagai pengguna Pion.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      );

  Widget _buildEmptyChat() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF0FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 36, color: Color(0xFF6366F1)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Pesan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mulai percakapan dengan mitra Anda',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _buildBubble(String text, bool isMe, String time, bool isRead, ThemeData theme) {
    Widget bubbleContent;
    bool isAttachment = text.startsWith('[') && text.endsWith(']');
    EdgeInsetsGeometry? customPadding;

    if (isAttachment) {
      customPadding = EdgeInsets.zero;
      if (text == '[📷 Foto Kamera]' || text == '[🖼️ Foto Galeri]') {
        bubbleContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                width: 200,
                height: 120,
                color: const Color(0xFFE2E8F0),
                child: Icon(
                  text == '[📷 Foto Kamera]'
                      ? Icons.camera_alt_rounded
                      : Icons.image_rounded,
                  color: const Color(0xFF64748B),
                  size: 40,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: isMe ? Colors.white70 : const Color(0xFF10B981),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    text == '[📷 Foto Kamera]' ? 'Foto Kamera' : 'Foto Galeri',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      } else if (text == '[📄 Dokumen PDF]') {
        bubbleContent = Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: Color(0xFFEF4444), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'invoice_perbaikan.pdf',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color:
                            isMe ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '1.2 MB • PDF',
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe
                            ? Colors.white70
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (text == '[📍 Lokasi Saat Ini]') {
        bubbleContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                width: 220,
                height: 100,
                color: const Color(0xFFEFF6FF),
                child: const Center(
                  child: Icon(Icons.map_rounded,
                      color: Color(0xFF3B82F6), size: 36),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Lokasi Saya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isMe
                            ? Colors.white
                            : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        isAttachment = false;
        bubbleContent = Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isMe ? Colors.white : const Color(0xFF0F172A),
            height: 1.5,
          ),
        );
      }
    } else {
      bubbleContent = Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isMe ? Colors.white : const Color(0xFF0F172A),
          height: 1.5,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            PionAvatar(radius: 16, url: widget.providerAvatar),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: customPadding ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? theme.colorScheme.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  border: isMe
                      ? null
                      : Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: isMe
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: bubbleContent,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      isRead ? Icons.done_all_rounded : Icons.done_rounded,
                      size: 14,
                      color: isRead ? Colors.blue : const Color(0xFF94A3B8),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
