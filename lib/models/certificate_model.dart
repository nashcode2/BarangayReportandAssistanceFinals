/// Certificate model for barangay documents
class CertificateModel {
  final String id;
  final String userId;
  final String userName;
  final String certificateType; // 'clearance', 'indigency', 'residency'
  final Map<String, dynamic> data; // Certificate-specific data
  final String qrCodeData; // QR code verification data
  final DateTime issuedDate;
  final DateTime? expiryDate;
  final String issuedBy; // Admin ID
  final String issuedByName; // Admin name
  final String status; // 'pending', 'approved', 'issued', 'rejected'
  final String? purpose;
  final String? pdfUrl; // URL to generated PDF
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;

  CertificateModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.certificateType,
    required this.data,
    required this.qrCodeData,
    required this.issuedDate,
    this.expiryDate,
    required this.issuedBy,
    required this.issuedByName,
    this.status = 'pending',
    this.purpose,
    this.pdfUrl,
    required this.createdAt,
    this.updatedAt,
    this.rejectionReason,
  });

  /// Create CertificateModel from Firestore document
  factory CertificateModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CertificateModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      certificateType: data['certificateType'] ?? '',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      qrCodeData: data['qrCodeData'] ?? '',
      issuedDate: data['issuedDate']?.toDate() ?? DateTime.now(),
      expiryDate: data['expiryDate']?.toDate(),
      issuedBy: data['issuedBy'] ?? '',
      issuedByName: data['issuedByName'] ?? '',
      status: data['status'] ?? 'pending',
      purpose: data['purpose'],
      pdfUrl: data['pdfUrl'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate(),
      rejectionReason: data['rejectionReason'],
    );
  }

  /// Convert CertificateModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'certificateType': certificateType,
      'data': data,
      'qrCodeData': qrCodeData,
      'issuedDate': issuedDate,
      'expiryDate': expiryDate,
      'issuedBy': issuedBy,
      'issuedByName': issuedByName,
      'status': status,
      'purpose': purpose,
      'pdfUrl': pdfUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
      'rejectionReason': rejectionReason,
    };
  }

  CertificateModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? certificateType,
    Map<String, dynamic>? data,
    String? qrCodeData,
    DateTime? issuedDate,
    DateTime? expiryDate,
    String? issuedBy,
    String? issuedByName,
    String? status,
    String? purpose,
    String? pdfUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? rejectionReason,
  }) {
    return CertificateModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      certificateType: certificateType ?? this.certificateType,
      data: data ?? this.data,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      issuedDate: issuedDate ?? this.issuedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      issuedBy: issuedBy ?? this.issuedBy,
      issuedByName: issuedByName ?? this.issuedByName,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

/// Certificate types
class CertificateTypes {
  static const String barangayClearance = 'barangay_clearance';
  static const String certificateOfIndigency = 'certificate_of_indigency';
  static const String certificateOfResidency = 'certificate_of_residency';

  static const List<String> all = [
    barangayClearance,
    certificateOfIndigency,
    certificateOfResidency,
  ];

  static String getDisplayName(String type) {
    switch (type) {
      case barangayClearance:
        return 'Barangay Clearance';
      case certificateOfIndigency:
        return 'Certificate of Indigency';
      case certificateOfResidency:
        return 'Certificate of Residency';
      default:
        return type;
    }
  }
}

/// Certificate status
class CertificateStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String issued = 'issued';
  static const String rejected = 'rejected';
}

