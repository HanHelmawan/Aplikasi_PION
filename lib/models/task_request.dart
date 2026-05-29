import 'package:cloud_firestore/cloud_firestore.dart';

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
  String title;
  String description;
  String category;
  String location;
  String scheduledAt;
  double estimatedPrice;   // harga dari user
  double? workerOffer;     // penawaran worker
  double? finalPrice;      // harga yang disepakati
  RequestStatus status;
  List<String> photoUrls;
  final DateTime createdAt;

  // Worker assignment
  String? assignedWorkerName;
  String? assignedWorkerAvatar;
  String? assignedWorkerPhone;

  TaskRequest({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.location,
    required this.scheduledAt,
    required this.estimatedPrice,
    required this.photoUrls,
    DateTime? createdAt,
    this.status = RequestStatus.menunggu,
    this.workerOffer,
    this.finalPrice,
    this.assignedWorkerName,
    this.assignedWorkerAvatar,
    this.assignedWorkerPhone,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
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
      'createdAt': createdAt.toIso8601String(),
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

    return TaskRequest(
      id: id,
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
      createdAt: map['createdAt'] != null ? (DateTime.tryParse(map['createdAt']) ?? DateTime.now()) : DateTime.now(),
      assignedWorkerName: map['assignedWorkerName'],
      assignedWorkerAvatar: map['assignedWorkerAvatar'],
      assignedWorkerPhone: map['assignedWorkerPhone'],
    );
  }
}

/// Simple in-memory store for the current session, synced with Firebase Firestore.
class TaskRequestStore {
  TaskRequestStore._();
  static final TaskRequestStore instance = TaskRequestStore._();

  final List<TaskRequest> requests = [];

  Future<void> add(TaskRequest r) async {
    // Add locally first
    if (!requests.any((req) => req.id == r.id)) {
      requests.insert(0, r);
    }
    // Sync with Firestore
    try {
      await FirebaseFirestore.instance.collection('task_requests').doc(r.id).set(r.toMap());
    } catch (e) {
      print('Firestore error adding task request: $e');
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
      await FirebaseFirestore.instance.collection('task_requests').doc(r.id).update(r.toMap());
    } catch (e) {
      print('Firestore error updating task request: $e');
    }
  }

  Future<void> fetchRequests() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('task_requests')
          .orderBy('createdAt', descending: true)
          .get();
      
      final loaded = snapshot.docs.map((doc) => TaskRequest.fromMap(doc.id, doc.data())).toList();
      
      // Merge with local requests (avoid duplicates, keep order)
      for (final r in loaded) {
        final idx = requests.indexWhere((req) => req.id == r.id);
        if (idx == -1) {
          requests.add(r);
        } else {
          requests[idx] = r;
        }
      }
      
      // Sort requests by createdAt descending
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Firestore error fetching task requests: $e');
    }
  }

  TaskRequest? findById(String id) {
    try {
      return requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
