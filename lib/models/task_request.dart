import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Status permintaan tugas
enum RequestStatus { menunggu, ditawar, dikerjakan, selesai, dibatalkan }

extension RequestStatusLabel on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.menunggu:   return 'Menunggu';
      case RequestStatus.ditawar:    return 'Ditawar';
      case RequestStatus.dikerjakan: return 'Dikerjakan';
      case RequestStatus.selesai:    return 'Selesai';
      case RequestStatus.dibatalkan: return 'Dibatalkan';
    }
  }
}

class TaskRequest {
  final String id;
  final String userId;       // ✅ AUDIT FIX: tambahkan userId untuk filter per-user
  final String title;
  final String description;
  final String category;
  final String location;
  final String scheduledAt;
  final double estimatedPrice;
  final double? workerOffer;
  final double? finalPrice;
  final RequestStatus status;
  final List<String> photoUrls;
  final DateTime createdAt;

  // Worker assignment
  final String? assignedWorkerName;
  final String? assignedWorkerAvatar;
  final String? assignedWorkerPhone;

  const TaskRequest({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.category,
    required this.location,
    required this.scheduledAt,
    required this.estimatedPrice,
    required this.photoUrls,
    required this.createdAt,
    this.status = RequestStatus.menunggu,
    this.workerOffer,
    this.finalPrice,
    this.assignedWorkerName,
    this.assignedWorkerAvatar,
    this.assignedWorkerPhone,
  });

  /// ✅ AUDIT FIX: copyWith untuk immutable updates
  TaskRequest copyWith({
    String? userId,
    String? title,
    String? description,
    String? category,
    String? location,
    String? scheduledAt,
    double? estimatedPrice,
    double? workerOffer,
    double? finalPrice,
    RequestStatus? status,
    List<String>? photoUrls,
    String? assignedWorkerName,
    String? assignedWorkerAvatar,
    String? assignedWorkerPhone,
  }) {
    return TaskRequest(
      id: id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      workerOffer: workerOffer ?? this.workerOffer,
      finalPrice: finalPrice ?? this.finalPrice,
      status: status ?? this.status,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt,
      assignedWorkerName: assignedWorkerName ?? this.assignedWorkerName,
      assignedWorkerAvatar: assignedWorkerAvatar ?? this.assignedWorkerAvatar,
      assignedWorkerPhone: assignedWorkerPhone ?? this.assignedWorkerPhone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'scheduledAt': scheduledAt,
      'estimatedPrice': estimatedPrice,
      'workerOffer': workerOffer,
      'finalPrice': finalPrice,
      'status': status.name,
      'photoUrls': photoUrls,
      'createdAt': Timestamp.fromDate(createdAt), // ✅ AUDIT FIX: gunakan Timestamp native Firestore
      'assignedWorkerName': assignedWorkerName,
      'assignedWorkerAvatar': assignedWorkerAvatar,
      'assignedWorkerPhone': assignedWorkerPhone,
    };
  }

  factory TaskRequest.fromMap(String id, Map<String, dynamic> map) {
    RequestStatus statusVal;
    try {
      statusVal = RequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RequestStatus.menunggu,
      );
    } catch (_) {
      statusVal = RequestStatus.menunggu;
    }

    // ✅ AUDIT FIX: handle both Timestamp and legacy ISO string
    DateTime createdAt;
    final rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return TaskRequest(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      scheduledAt: map['scheduledAt'] ?? '',
      estimatedPrice: (map['estimatedPrice'] as num?)?.toDouble() ?? 0.0,
      workerOffer: (map['workerOffer'] as num?)?.toDouble(),
      finalPrice: (map['finalPrice'] as num?)?.toDouble(),
      status: statusVal,
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      createdAt: createdAt,
      assignedWorkerName: map['assignedWorkerName'],
      assignedWorkerAvatar: map['assignedWorkerAvatar'],
      assignedWorkerPhone: map['assignedWorkerPhone'],
    );
  }
}

/// Simple in-memory store for the current session, synced with Firebase Firestore.
/// ✅ AUDIT FIX: sekarang memfilter data berdasarkan userId user yang login
class TaskRequestStore {
  TaskRequestStore._();
  static final TaskRequestStore instance = TaskRequestStore._();

  final List<TaskRequest> requests = [];

  /// Mendapatkan UID user yang sedang login, atau null jika tidak ada.
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> add(TaskRequest r) async {
    // Add locally first
    if (!requests.any((req) => req.id == r.id)) {
      requests.insert(0, r);
    }
    // Sync with Firestore
    try {
      await FirebaseFirestore.instance
          .collection('task_requests')
          .doc(r.id)
          .set(r.toMap());
    } catch (e) {
      debugPrint('Firestore error adding task request: $e'); // ✅ AUDIT FIX: debugPrint
      rethrow;
    }
  }

  /// Alias for [add] — adds a request to the top of the list.
  Future<void> addRequest(TaskRequest r) async => add(r);

  Future<void> updateRequest(TaskRequest r) async {
    // Update locally
    final idx = requests.indexWhere((req) => req.id == r.id);
    if (idx != -1) {
      requests[idx] = r;
    }
    // Sync with Firestore
    try {
      await FirebaseFirestore.instance
          .collection('task_requests')
          .doc(r.id)
          .update(r.toMap());
    } catch (e) {
      debugPrint('Firestore error updating task request: $e'); // ✅ AUDIT FIX: debugPrint
      rethrow;
    }
  }

  Future<void> fetchRequests({bool onlyCurrentUser = true}) async {
    final uid = _currentUserId;
    if (uid == null) {
      debugPrint('fetchRequests: No user logged in, skipping.');
      return;
    }

    try {
      Query query = FirebaseFirestore.instance.collection('task_requests');
      if (onlyCurrentUser) {
        query = query.where('userId', isEqualTo: uid);
      }
      
      final snapshot = await query.orderBy('createdAt', descending: true).get();

      final loaded = snapshot.docs
          .map((doc) => TaskRequest.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // Clear local list first to ensure in-memory state is clean and accurate
      requests.clear();
      requests.addAll(loaded);
    } catch (e) {
      debugPrint('Firestore error fetching task requests: $e'); // ✅ AUDIT FIX: debugPrint
    }
  }

  /// Bersihkan data saat user logout untuk menghindari data leakage antar sesi
  void clear() {
    requests.clear();
  }

  TaskRequest? findById(String id) {
    try {
      return requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
