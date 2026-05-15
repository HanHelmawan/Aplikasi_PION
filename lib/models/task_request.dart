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
}

/// Simple in-memory store for the current session.
class TaskRequestStore {
  TaskRequestStore._();
  static final TaskRequestStore instance = TaskRequestStore._();

  final List<TaskRequest> requests = [];

  void add(TaskRequest r) => requests.insert(0, r);

  TaskRequest? findById(String id) {
    try {
      return requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
