/// Announcement model representing barangay announcements
class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final String? fullDescription;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? authorId;
  final String? authorName;
  final String? imageUrl;
  final bool isImportant;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    this.fullDescription,
    required this.createdAt,
    this.updatedAt,
    this.authorId,
    this.authorName,
    this.imageUrl,
    this.isImportant = false,
  });

  /// Create AnnouncementModel from Firestore document
  factory AnnouncementModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AnnouncementModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      fullDescription: data['fullDescription'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate(),
      authorId: data['authorId'],
      authorName: data['authorName'],
      imageUrl: data['imageUrl'],
      isImportant: data['isImportant'] ?? false,
    );
  }

  /// Convert AnnouncementModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'fullDescription': fullDescription,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'authorId': authorId,
      'authorName': authorName,
      'imageUrl': imageUrl,
      'isImportant': isImportant,
    };
  }

  /// Create a copy with updated fields
  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? fullDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorId,
    String? authorName,
    String? imageUrl,
    bool? isImportant,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fullDescription: fullDescription ?? this.fullDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      imageUrl: imageUrl ?? this.imageUrl,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}

