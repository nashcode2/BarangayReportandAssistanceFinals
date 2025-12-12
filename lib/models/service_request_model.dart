/// Service Request model representing a user's service request
class ServiceRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String serviceType; // Waste Collection, Street Cleaning, etc.
  final String description;
  final DateTime preferredDate;
  final String? address;
  final String status; // Pending, Scheduled, In Progress, Completed, Cancelled
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final String? notes;

  ServiceRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.serviceType,
    required this.description,
    required this.preferredDate,
    this.address,
    this.status = 'Pending',
    required this.createdAt,
    this.scheduledDate,
    this.completedDate,
    this.assignedStaffId,
    this.assignedStaffName,
    this.notes,
  });

  /// Create ServiceRequestModel from Firestore document
  factory ServiceRequestModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ServiceRequestModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      serviceType: data['serviceType'] ?? '',
      description: data['description'] ?? '',
      preferredDate: data['preferredDate']?.toDate() ?? DateTime.now(),
      address: data['address'],
      status: data['status'] ?? 'Pending',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      scheduledDate: data['scheduledDate']?.toDate(),
      completedDate: data['completedDate']?.toDate(),
      assignedStaffId: data['assignedStaffId'],
      assignedStaffName: data['assignedStaffName'],
      notes: data['notes'],
    );
  }

  /// Convert ServiceRequestModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'serviceType': serviceType,
      'description': description,
      'preferredDate': preferredDate,
      'address': address,
      'status': status,
      'createdAt': createdAt,
      'scheduledDate': scheduledDate,
      'completedDate': completedDate,
      'assignedStaffId': assignedStaffId,
      'assignedStaffName': assignedStaffName,
      'notes': notes,
    };
  }

  /// Create a copy with updated fields
  ServiceRequestModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? serviceType,
    String? description,
    DateTime? preferredDate,
    String? address,
    String? status,
    DateTime? createdAt,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? assignedStaffId,
    String? assignedStaffName,
    String? notes,
  }) {
    return ServiceRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      preferredDate: preferredDate ?? this.preferredDate,
      address: address ?? this.address,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      notes: notes ?? this.notes,
    );
  }
}

