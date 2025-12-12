import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';
import '../models/announcement_model.dart';
import '../models/review_model.dart';
import '../models/event_model.dart';
import '../models/service_request_model.dart';
import '../models/certificate_model.dart';
import '../utils/constants.dart';

/// Service class for Firebase operations
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication Methods
  
  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Register new user with email and password
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (userCredential.user != null) {
        final userModel = UserModel(
          id: userCredential.user!.uid,
          email: email,
          phone: phone,
          name: name,
          isAdmin: false,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .set(userModel.toFirestore());
      }

      return userCredential;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Sign in with Google (requires google_sign_in package setup)
  Future<UserCredential?> signInWithGoogle() async {
    // TODO: Implement Google Sign-In
    // This requires additional setup with google_sign_in package
    throw UnimplementedError('Google Sign-In not yet implemented');
  }

  /// Sign in with Facebook (requires facebook_auth package setup)
  Future<UserCredential?> signInWithFacebook() async {
    // TODO: Implement Facebook Sign-In
    // This requires additional setup with facebook_auth package
    throw UnimplementedError('Facebook Sign-In not yet implemented');
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .get();
      
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  /// Stream user data
  Stream<UserModel?> streamUserData(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Report Methods

  /// Create a new report
  Future<ReportModel> createReport(ReportModel report) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.reportsCollection)
          .add(report.toFirestore());
      return report.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  /// Get reports for a specific user
  Stream<List<ReportModel>> getUserReports(String userId) {
    // Get all reports and filter/sort manually to avoid index requirements
    return _firestore
        .collection(AppConstants.reportsCollection)
        .snapshots()
        .map((snapshot) {
      final reports = snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc.data(), doc.id))
          .where((report) => report.userId == userId)
          .toList();
      // Sort by createdAt descending (newest first)
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    });
  }

  /// Get reports for a specific user (one-time fetch)
  Future<List<ReportModel>> getUserReportsOnce(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.reportsCollection)
          .get();
      
      final reports = snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc.data(), doc.id))
          .where((report) => report.userId == userId)
          .toList();
      
      // Sort by createdAt descending (newest first)
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    } catch (e) {
      throw Exception('Failed to load user reports: $e');
    }
  }

  /// Get all reports (for admin)
  Stream<List<ReportModel>> getAllReports() {
    // Get all reports and sort manually to avoid index requirements
    return _firestore
        .collection(AppConstants.reportsCollection)
        .snapshots()
        .map((snapshot) {
      final reports = snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc.data(), doc.id))
          .toList();
      // Sort by createdAt descending (newest first)
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    });
  }

  /// Get reports by status
  Stream<List<ReportModel>> getReportsByStatus(String status) {
    return _firestore
        .collection(AppConstants.reportsCollection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Update report
  Future<void> updateReport(ReportModel report) async {
    try {
      await _firestore
          .collection(AppConstants.reportsCollection)
          .doc(report.id)
          .update(report.toFirestore());
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  /// Upload report photo
  Future<String> uploadReportPhoto(String reportId, String filePath) async {
    try {
      final ref = _storage
          .ref()
          .child(AppConstants.reportPhotosPath)
          .child('$reportId.jpg');
      
      final file = File(filePath);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  // Announcement Methods

  /// Create announcement
  Future<String> createAnnouncement(AnnouncementModel announcement) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.announcementsCollection)
          .add(announcement.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create announcement: $e');
    }
  }

  /// Get all announcements (stream)
  Stream<List<AnnouncementModel>> getAnnouncements() {
    try {
      return _firestore
          .collection(AppConstants.announcementsCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => AnnouncementModel.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      // Return empty stream on error
      return Stream.value([]);
    }
  }

  /// Get all announcements (one-time fetch, fallback)
  Future<List<AnnouncementModel>> getAnnouncementsOnce() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.announcementsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AnnouncementModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      // If orderBy fails, try without it
      try {
        final snapshot = await _firestore
            .collection(AppConstants.announcementsCollection)
            .get();
        
        final announcements = snapshot.docs
            .map((doc) => AnnouncementModel.fromFirestore(doc.data(), doc.id))
            .toList();
        
        // Sort manually
        announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return announcements;
      } catch (e2) {
        throw Exception('Failed to load announcements: $e2');
      }
    }
  }

  /// Update announcement
  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      await _firestore
          .collection(AppConstants.announcementsCollection)
          .doc(announcement.id)
          .update(announcement.toFirestore());
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }

  /// Delete announcement
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _firestore
          .collection(AppConstants.announcementsCollection)
          .doc(announcementId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  // Analytics Methods

  /// Get report statistics
  Future<Map<String, int>> getReportStatistics() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.reportsCollection)
          .get();
      
      final stats = <String, int>{
        'total': snapshot.docs.length,
        'pending': 0,
        'inProgress': 0,
        'resolved': 0,
      };

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'Pending';
        if (status == AppConstants.statusPending) {
          stats['pending'] = (stats['pending'] ?? 0) + 1;
        } else if (status == AppConstants.statusInProgress) {
          stats['inProgress'] = (stats['inProgress'] ?? 0) + 1;
        } else if (status == AppConstants.statusResolved) {
          stats['resolved'] = (stats['resolved'] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  /// Get issue type statistics
  Future<Map<String, int>> getIssueTypeStatistics() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.reportsCollection)
          .get();
      
      final stats = <String, int>{};

      for (var doc in snapshot.docs) {
        final issueType = doc.data()['issueType'] as String? ?? 'Others';
        stats[issueType] = (stats[issueType] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get issue type statistics: $e');
    }
  }

  // Review Methods

  /// Create a new review
  Future<ReviewModel> createReview(ReviewModel review) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.reviewsCollection)
          .add(review.toFirestore());
      return review.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  /// Get all reviews (visible only)
  Stream<List<ReviewModel>> getReviews() {
    // Get all reviews and filter/sort manually to avoid index requirements
    return _firestore
        .collection(AppConstants.reviewsCollection)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc.data(), doc.id))
          .where((review) => review.isVisible)
          .toList();
      // Sort by createdAt descending (newest first)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  /// Get all reviews (one-time fetch, fallback)
  Future<List<ReviewModel>> getReviewsOnce() async {
    try {
      // Get all reviews and filter/sort manually to avoid index requirements
      final snapshot = await _firestore
          .collection(AppConstants.reviewsCollection)
          .get();
      
      final reviews = snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc.data(), doc.id))
          .where((review) => review.isVisible)
          .toList();
      
      // Sort by createdAt descending (newest first)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }

  /// Get all reviews (for admin - includes hidden)
  Stream<List<ReviewModel>> getAllReviews() {
    return _firestore
        .collection(AppConstants.reviewsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get reviews for a specific user
  Stream<List<ReviewModel>> getUserReviews(String userId) {
    return _firestore
        .collection(AppConstants.reviewsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get average rating
  Future<double> getAverageRating() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.reviewsCollection)
          .where('isVisible', isEqualTo: true)
          .get();
      
      if (snapshot.docs.isEmpty) return 0.0;
      
      int totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += doc.data()['rating'] as int? ?? 0;
      }
      
      return totalRating / snapshot.docs.length;
    } catch (e) {
      return 0.0;
    }
  }

  /// Update review visibility (admin only)
  Future<void> updateReviewVisibility(String reviewId, bool isVisible) async {
    try {
      await _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId)
          .update({'isVisible': isVisible});
    } catch (e) {
      throw Exception('Failed to update review visibility: $e');
    }
  }

  /// Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  // Event Methods

  /// Create a new event
  Future<EventModel> createEvent(EventModel event) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.eventsCollection)
          .add(event.toFirestore());
      return event.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  /// Get all active events
  Stream<List<EventModel>> getEvents() {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
          .where((event) => event.isActive)
          .toList();
      events.sort((a, b) => a.startDate.compareTo(b.startDate));
      return events;
    });
  }

  /// Get all events (one-time fetch)
  Future<List<EventModel>> getEventsOnce() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.eventsCollection)
          .get();
      
      final events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc.data(), doc.id))
          .where((event) => event.isActive)
          .toList();
      
      events.sort((a, b) => a.startDate.compareTo(b.startDate));
      return events;
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  /// RSVP to an event
  Future<void> rsvpToEvent(String eventId, String userId) async {
    try {
      final eventRef = _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId);
      
      await eventRef.update({
        'rsvpUserIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Failed to RSVP: $e');
    }
  }

  /// Cancel RSVP
  Future<void> cancelRsvp(String eventId, String userId) async {
    try {
      final eventRef = _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId);
      
      await eventRef.update({
        'rsvpUserIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Failed to cancel RSVP: $e');
    }
  }

  /// Update event
  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(event.id)
          .update(event.toFirestore());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Service Request Methods

  /// Create a new service request
  Future<ServiceRequestModel> createServiceRequest(ServiceRequestModel request) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.serviceRequestsCollection)
          .add(request.toFirestore());
      return request.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create service request: $e');
    }
  }

  /// Get service requests for a specific user
  Stream<List<ServiceRequestModel>> getUserServiceRequests(String userId) {
    return _firestore
        .collection(AppConstants.serviceRequestsCollection)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs
          .map((doc) => ServiceRequestModel.fromFirestore(doc.data(), doc.id))
          .where((request) => request.userId == userId)
          .toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  /// Get all service requests (for admin)
  Stream<List<ServiceRequestModel>> getAllServiceRequests() {
    return _firestore
        .collection(AppConstants.serviceRequestsCollection)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs
          .map((doc) => ServiceRequestModel.fromFirestore(doc.data(), doc.id))
          .toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  /// Get service requests (one-time fetch)
  Future<List<ServiceRequestModel>> getUserServiceRequestsOnce(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.serviceRequestsCollection)
          .get();
      
      final requests = snapshot.docs
          .map((doc) => ServiceRequestModel.fromFirestore(doc.data(), doc.id))
          .where((request) => request.userId == userId)
          .toList();
      
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    } catch (e) {
      throw Exception('Failed to load service requests: $e');
    }
  }

  /// Update service request
  Future<void> updateServiceRequest(ServiceRequestModel request) async {
    try {
      await _firestore
          .collection(AppConstants.serviceRequestsCollection)
          .doc(request.id)
          .update(request.toFirestore());
    } catch (e) {
      throw Exception('Failed to update service request: $e');
    }
  }

  /// Delete service request
  Future<void> deleteServiceRequest(String requestId) async {
    try {
      await _firestore
          .collection(AppConstants.serviceRequestsCollection)
          .doc(requestId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete service request: $e');
    }
  }

  // Certificate Methods

  /// Create a certificate request
  Future<String> createCertificateRequest(CertificateModel certificate) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.certificatesCollection)
          .add(certificate.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create certificate request: $e');
    }
  }

  /// Get certificates for a specific user
  Stream<List<CertificateModel>> getUserCertificates(String userId) {
    // Query without orderBy to avoid requiring composite index
    // We'll sort manually in the map function
    return _firestore
        .collection(AppConstants.certificatesCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final certificates = snapshot.docs
          .map((doc) => CertificateModel.fromFirestore(doc.data(), doc.id))
          .toList();
      
      // Sort by createdAt descending (newest first)
      certificates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return certificates;
    });
  }

  /// One-time fetch of certificates for a specific user (no stream)
  Future<List<CertificateModel>> getUserCertificatesOnce(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.certificatesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final certificates = snapshot.docs
          .map((doc) => CertificateModel.fromFirestore(doc.data(), doc.id))
          .toList();

      certificates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return certificates;
    } catch (e) {
      throw Exception('Failed to load certificates: $e');
    }
  }

  /// Get all certificates (for admin)
  Stream<List<CertificateModel>> getAllCertificates() {
    return _firestore
        .collection(AppConstants.certificatesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CertificateModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get certificates by status
  Stream<List<CertificateModel>> getCertificatesByStatus(String status) {
    return _firestore
        .collection(AppConstants.certificatesCollection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CertificateModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Update certificate
  Future<void> updateCertificate(CertificateModel certificate) async {
    try {
      final data = <String, dynamic>{
        'status': certificate.status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Add optional fields if they exist
      if (certificate.issuedBy.isNotEmpty) {
        data['issuedBy'] = certificate.issuedBy;
      }
      if (certificate.issuedByName.isNotEmpty) {
        data['issuedByName'] = certificate.issuedByName;
      }
      if (certificate.pdfUrl != null && certificate.pdfUrl!.isNotEmpty) {
        data['pdfUrl'] = certificate.pdfUrl;
      }
      if (certificate.rejectionReason != null && certificate.rejectionReason!.isNotEmpty) {
        data['rejectionReason'] = certificate.rejectionReason;
      }
      
      print('Updating certificate ${certificate.id} with status: ${certificate.status}');
      print('Update data: $data');
      
      // Update the certificate
      await _firestore
          .collection(AppConstants.certificatesCollection)
          .doc(certificate.id)
          .update(data);
    } catch (e) {
      print('Error updating certificate: $e');
      throw Exception('Failed to update certificate: $e');
    }
  }

  /// Upload certificate PDF to storage
  Future<String> uploadCertificatePDF(String certificateId, Uint8List pdfData) async {
    try {
      final ref = _storage
          .ref()
          .child('certificates')
          .child('$certificateId.pdf');
      
      // Use putData with metadata for better performance
      final metadata = SettableMetadata(
        contentType: 'application/pdf',
        cacheControl: 'public, max-age=31536000',
      );
      
      final uploadTask = ref.putData(pdfData, metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload certificate PDF: $e');
    }
  }
}

