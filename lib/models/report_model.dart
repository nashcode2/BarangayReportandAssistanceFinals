/// Report model representing a user-submitted issue report
class ReportModel {
  final String id;
  final String userId;
  final String userName;
  final String issueType; // Garbage, Streetlight, Flooding, Others
  final String description;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String status; // Pending, In Progress, Resolved
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final List<String>? notes;
  final String? resolution;

  ReportModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.issueType,
    required this.description,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.address,
    this.status = 'Pending',
    required this.createdAt,
    this.updatedAt,
    this.assignedStaffId,
    this.assignedStaffName,
    this.notes,
    this.resolution,
  });

  /// Create ReportModel from Firestore document
  factory ReportModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReportModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      issueType: data['issueType'] ?? '',
      description: data['description'] ?? '',
      photoUrl: data['photoUrl'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      address: data['address'],
      status: data['status'] ?? 'Pending',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate(),
      assignedStaffId: data['assignedStaffId'],
      assignedStaffName: data['assignedStaffName'],
      notes: data['notes'] != null ? List<String>.from(data['notes']) : null,
      resolution: data['resolution'],
    );
  }

  /// Convert ReportModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'issueType': issueType,
      'description': description,
      'photoUrl': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'assignedStaffId': assignedStaffId,
      'assignedStaffName': assignedStaffName,
      'notes': notes,
      'resolution': resolution,
    };
  }

  /// Create a copy with updated fields
  ReportModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? issueType,
    String? description,
    String? photoUrl,
    double? latitude,
    double? longitude,
    String? address,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedStaffId,
    String? assignedStaffName,
    List<String>? notes,
    String? resolution,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      issueType: issueType ?? this.issueType,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      notes: notes ?? this.notes,
      resolution: resolution ?? this.resolution,
    );
  }
}

