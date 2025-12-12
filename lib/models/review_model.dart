/// Review model representing a resident's review/rating
class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final int rating; // 1-5 stars
  final String comment;
  final String? reportId; // Optional: link to a specific report
  final DateTime createdAt;
  final bool isVisible; // Admin can hide inappropriate reviews

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.reportId,
    required this.createdAt,
    this.isVisible = true,
  });

  /// Create ReviewModel from Firestore document
  factory ReviewModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      rating: data['rating'] ?? 5,
      comment: data['comment'] ?? '',
      reportId: data['reportId'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      isVisible: data['isVisible'] ?? true,
    );
  }

  /// Convert ReviewModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'reportId': reportId,
      'createdAt': createdAt,
      'isVisible': isVisible,
    };
  }

  /// Create a copy with updated fields
  ReviewModel copyWith({
    String? id,
    String? userId,
    String? userName,
    int? rating,
    String? comment,
    String? reportId,
    DateTime? createdAt,
    bool? isVisible,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      reportId: reportId ?? this.reportId,
      createdAt: createdAt ?? this.createdAt,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

