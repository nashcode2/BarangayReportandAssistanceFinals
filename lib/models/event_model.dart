/// Event model representing a barangay event
class EventModel {
  final String id;
  final String title;
  final String description;
  final String eventType;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final String? imageUrl;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final List<String> rsvpUserIds; // Users who RSVP'd
  final bool isActive;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventType,
    required this.startDate,
    required this.endDate,
    this.location,
    this.imageUrl,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    this.rsvpUserIds = const [],
    this.isActive = true,
  });

  /// Create EventModel from Firestore document
  factory EventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      eventType: data['eventType'] ?? '',
      startDate: data['startDate']?.toDate() ?? DateTime.now(),
      endDate: data['endDate']?.toDate() ?? DateTime.now(),
      location: data['location'],
      imageUrl: data['imageUrl'],
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      rsvpUserIds: data['rsvpUserIds'] != null
          ? List<String>.from(data['rsvpUserIds'])
          : [],
      isActive: data['isActive'] ?? true,
    );
  }

  /// Convert EventModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'eventType': eventType,
      'startDate': startDate,
      'endDate': endDate,
      'location': location,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt,
      'rsvpUserIds': rsvpUserIds,
      'isActive': isActive,
    };
  }

  /// Create a copy with updated fields
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? imageUrl,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    List<String>? rsvpUserIds,
    bool? isActive,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      rsvpUserIds: rsvpUserIds ?? this.rsvpUserIds,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Check if event is upcoming
  bool get isUpcoming => startDate.isAfter(DateTime.now());

  /// Check if event is ongoing
  bool get isOngoing =>
      startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());

  /// Check if event has passed
  bool get hasPassed => endDate.isBefore(DateTime.now());
}

