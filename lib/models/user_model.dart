/// User model representing a resident or admin user
class UserModel {
  final String id;
  final String email;
  final String? phone;
  final String name;
  final bool isAdmin;
  final String? address;
  final DateTime createdAt;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.name,
    this.isAdmin = false,
    this.address,
    required this.createdAt,
    this.profileImageUrl,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      phone: data['phone'],
      name: data['name'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      address: data['address'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      profileImageUrl: data['profileImageUrl'],
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phone': phone,
      'name': name,
      'isAdmin': isAdmin,
      'address': address,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    bool? isAdmin,
    String? address,
    DateTime? createdAt,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

