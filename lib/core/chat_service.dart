import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
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

  /// Mengirim pesan baru ke Firestore
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
        });
        
        // 2. Perbarui ringkasan ruang obrolan (lastMessage)
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
        }, SetOptions(merge: true));
      });
    } catch (e) {
      debugPrint('ChatService.sendMessage error: $e');
    }
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

  /// Mendengarkan seluruh ruang obrolan aktif milik pengguna secara realtime
  static Stream<QuerySnapshot> listenToChatRooms() {
    final myId = currentUserId;
    if (myId.isEmpty) return const Stream.empty();
    
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: myId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
}

class MockChatMessage {
  final String text;
  final bool isMe;
  final String time;

  MockChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

class MockChatStore extends ChangeNotifier {
  MockChatStore._();
  static final MockChatStore instance = MockChatStore._();

  final Map<String, List<MockChatMessage>> _chatsHistory = {};

  List<MockChatMessage> getMessages(String providerName) {
    if (!_chatsHistory.containsKey(providerName)) {
      if (providerName == 'Budi Santoso') {
        _chatsHistory[providerName] = [
          MockChatMessage(text: 'Halo! Saya Budi, saya melihat permintaan Anda tentang perbaikan pipa.', isMe: false, time: '10:32'),
          MockChatMessage(text: 'Bisa ceritakan lebih detail? Apakah pipa bocor atau tersumbat?', isMe: false, time: '10:32'),
          MockChatMessage(text: 'Halo Budi! Pipa di kamar mandi bocor, air menetes dari sambungan pipa.', isMe: true, time: '10:35'),
          MockChatMessage(text: 'Sudah berapa lama? Dan apakah ada kerusakan di sekitarnya?', isMe: false, time: '10:36'),
          MockChatMessage(text: 'Baru sejak kemarin. Belum ada kerusakan besar, tapi cukup mengganggu.', isMe: true, time: '10:38'),
          MockChatMessage(text: 'Baik, saya bisa datang hari ini jam 2 siang. Estimasi pengerjaan 1-2 jam.', isMe: false, time: '10:40'),
        ];
      } else if (providerName == 'Siti Aminah') {
        _chatsHistory[providerName] = [
          MockChatMessage(text: 'Terima kasih! Tugas sudah saya selesaikan.', isMe: false, time: 'Kemarin'),
        ];
      } else if (providerName == 'Andi Pratama') {
        _chatsHistory[providerName] = [
          MockChatMessage(text: 'Apakah ada tambahan alat yang perlu dibawa?', isMe: false, time: 'Senin'),
        ];
      } else if (providerName == 'Rudi Hartono') {
        _chatsHistory[providerName] = [
          MockChatMessage(text: 'Harga sudah kami sepakati ya, terima kasih.', isMe: false, time: 'Minggu'),
        ];
      } else {
        _chatsHistory[providerName] = [];
      }
    }
    return _chatsHistory[providerName]!;
  }

  void addMessage(String providerName, String text, bool isMe) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final msg = MockChatMessage(text: text, isMe: isMe, time: timeStr);
    getMessages(providerName).add(msg);
    notifyListeners();
  }

  String getLastMessage(String providerName, String defaultMsg) {
    final msgs = getMessages(providerName);
    if (msgs.isEmpty) return defaultMsg;
    return msgs.last.text;
  }

  String getLastTime(String providerName, String defaultTime) {
    final msgs = getMessages(providerName);
    if (msgs.isEmpty) return defaultTime;
    return msgs.last.time;
  }
}
