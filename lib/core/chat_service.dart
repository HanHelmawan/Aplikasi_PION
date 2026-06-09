import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    DateTime ts;
    final rawTs = map['timestamp'];
    if (rawTs is Timestamp) {
      ts = rawTs.toDate();
    } else if (rawTs is String) {
      ts = DateTime.tryParse(rawTs) ?? DateTime.now();
    } else {
      ts = DateTime.now();
    }
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: ts,
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}

class ChatService {
  ChatService._();

  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get currentUserId => _auth.currentUser?.uid ?? '';

  /// Mendapatkan ID ruang obrolan unik antara dua pengguna secara konsisten (diurutkan alfabetis)
  static String getChatRoomId(String user1, String user2) {
    final list = [user1, user2]..sort();
    return list.join('_');
  }

  /// Mengirim pesan baru ke Firestore dan meng-increment unread count penerima
  static Future<void> sendMessage({
    required String recipientId,
    required String recipientName,
    required String recipientAvatar,
    required String senderName,
    required String senderAvatar,
    required String text,
  }) async {
    final myId = currentUserId;
    if (myId.isEmpty) return;

    final chatRoomId = getChatRoomId(myId, recipientId);

    final messageRef = _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc();

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Tambah pesan baru
        transaction.set(messageRef, {
          'senderId': myId,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

        // 2. Perbarui ringkasan ruang obrolan (lastMessage) dan unread count penerima
        transaction.set(_firestore.collection('chats').doc(chatRoomId), {
          'lastMessage': {
            'text': text,
            'senderId': myId,
            'timestamp': FieldValue.serverTimestamp(),
          },
          'participants': [myId, recipientId],
          'updatedAt': FieldValue.serverTimestamp(),
          'user_$myId': {
            'name': senderName,
            'avatarUrl': senderAvatar,
          },
          'user_$recipientId': {
            'name': recipientName,
            'avatarUrl': recipientAvatar,
          },
          // Increment unread count untuk penerima
          'unread_$recipientId': FieldValue.increment(1),
        }, SetOptions(merge: true));
      });
    } catch (e) {
      debugPrint('ChatService.sendMessage error: $e');
    }
  }

  /// Menandai semua pesan sudah dibaca oleh user saat ini (reset unread count dan set isRead = true pada dokumen messages)
  static Future<void> markMessagesRead(String recipientId) async {
    final myId = currentUserId;
    if (myId.isEmpty) return;

    final chatRoomId = getChatRoomId(myId, recipientId);
    try {
      await _firestore.collection('chats').doc(chatRoomId).update({
        'unread_$myId': 0,
      });

      // Tandai semua pesan dari penerima (lawan bicara) sebagai sudah dibaca (isRead = true)
      final unreadQuery = await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isEqualTo: recipientId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadQuery.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in unreadQuery.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('ChatService.markMessagesRead error: $e');
    }
  }

  /// Stream unread count untuk satu chatroom tertentu (untuk tampilan di dalam chat list item)
  static Stream<int> listenUnreadCount(String recipientId) {
    final myId = currentUserId;
    if (myId.isEmpty) return const Stream.empty();

    final chatRoomId = getChatRoomId(myId, recipientId);
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return 0;
          final data = doc.data();
          return (data?['unread_$myId'] as int?) ?? 0;
        });
  }

  /// Stream total unread count dari semua chatroom milik user (untuk badge di bottom nav)
  static Stream<int> listenTotalUnread() {
    final myId = currentUserId;
    if (myId.isEmpty) return const Stream.empty();

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: myId)
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (final doc in snapshot.docs) {
            final data = doc.data();
            total += (data['unread_$myId'] as int?) ?? 0;
          }
          return total;
        });
  }

  /// Mendengarkan pesan dalam ruang obrolan secara realtime
  static Stream<List<ChatMessage>> listenToMessages(String recipientId) {
    final myId = currentUserId;
    if (myId.isEmpty) return const Stream.empty();

    final chatRoomId = getChatRoomId(myId, recipientId);

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  /// Mendengarkan seluruh ruang obrolan aktif milik pengguna secara realtime (tanpa orderBy server-side untuk menghindari composite index error)
  static Stream<QuerySnapshot> listenToChatRooms() {
    final myId = currentUserId;
    if (myId.isEmpty) return const Stream.empty();

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: myId)
        .snapshots();
  }
}
