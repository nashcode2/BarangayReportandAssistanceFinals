import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/certificate_model.dart';
import '../services/firebase_service.dart';
import '../services/certificate_service.dart';
import '../services/notification_service.dart';
import '../services/communication_service.dart';

/// Provider for certificate state management
class CertificateProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<CertificateModel>>? _userCertificatesSubscription;
  StreamSubscription<List<CertificateModel>>? _allCertificatesSubscription;
  
  List<CertificateModel> _certificates = [];
  List<CertificateModel> _userCertificates = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<CertificateModel> get certificates => _certificates;
  List<CertificateModel> get userCertificates => _userCertificates;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _userCertificatesSubscription?.cancel();
    _allCertificatesSubscription?.cancel();
    super.dispose();
  }

  /// Load all certificates (for admin)
  Future<void> loadAllCertificates() async {
    if (_isSubmitting) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _allCertificatesSubscription?.cancel();
      
      _allCertificatesSubscription = _firebaseService.getAllCertificates().listen(
        (certificates) {
          _certificates = certificates;
          _errorMessage = null;
          if (!_isSubmitting) {
            _isLoading = false;
          }
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user certificates
  Future<void> loadUserCertificates(String userId) async {
    if (userId.isEmpty) {
      _userCertificates = [];
      _isLoading = false;
      _errorMessage = 'No user';
      notifyListeners();
      return;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      // Always cancel existing subscription first
      await _userCertificatesSubscription?.cancel();
      _userCertificatesSubscription = null;
      
      // Set loading state
      _isLoading = true;
      notifyListeners();

      // Prime UI quickly with one-time fetch in case the stream is slow to start
      try {
        final initial = await _firebaseService.getUserCertificatesOnce(userId);
        _userCertificates = initial;
        _isLoading = false;
        notifyListeners();
      } catch (_) {
        // Ignore and let stream continue; we keep loading=true if this failed
      }
      
      // Small delay to ensure previous subscription is fully cancelled
      await Future.delayed(const Duration(milliseconds: 100));
      
      _userCertificatesSubscription = _firebaseService.getUserCertificates(userId).listen(
        (certificates) {
          _userCertificates = certificates;
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = error.toString();
          _isLoading = false;
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('EXCEPTION setting up stream: $e');
      notifyListeners();
    }
  }

  /// Request a certificate
  Future<bool> requestCertificate({
    required String userId,
    required String userName,
    required String certificateType,
    required Map<String, dynamic> data,
    required String purpose,
    required String barangayName,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Generate QR code data
      final qrCodeData = 'cert:$certificateType:${DateTime.now().millisecondsSinceEpoch}';
      
      final certificate = CertificateModel(
        id: '', // Will be set by Firestore
        userId: userId,
        userName: userName,
        certificateType: certificateType,
        data: data,
        qrCodeData: qrCodeData,
        issuedDate: DateTime.now(),
        issuedBy: '',
        issuedByName: '',
        status: CertificateStatus.pending,
        purpose: purpose,
        createdAt: DateTime.now(),
      );

      final certificateId = await _firebaseService.createCertificateRequest(certificate);
      
      // Send notification to admins
      await NotificationService.sendCertificateRequestNotification(
        certificateId: certificateId,
        userName: userName,
        certificateType: certificateType,
      );

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Approve certificate (admin)
  Future<bool> approveCertificate(CertificateModel certificate, String adminId, String adminName) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCertificate = certificate.copyWith(
        status: CertificateStatus.approved,
        issuedBy: adminId,
        issuedByName: adminName,
        updatedAt: DateTime.now(),
      );

      print('=== APPROVING CERTIFICATE ===');
      print('Certificate ID: ${certificate.id}');
      print('Certificate userId: ${certificate.userId}');
      print('Updating status to: ${CertificateStatus.approved}');

      await _firebaseService.updateCertificate(updatedCertificate);

      print('Certificate updated in Firestore. Now forcing refresh for resident...');

      // IMPORTANT: Force refresh the resident's certificate list immediately
      // This ensures they see the update right away
      if (certificate.userId.isNotEmpty) {
        print('Triggering immediate refresh for user: ${certificate.userId}');
        // Cancel existing subscription
        await _userCertificatesSubscription?.cancel();
        _userCertificatesSubscription = null;
        // Wait for Firestore to commit the update
        await Future.delayed(const Duration(milliseconds: 500));
        // Force reload the stream - this will update the resident's view
        await loadUserCertificates(certificate.userId);
        print('Refresh completed for user certificates');
      }

      // Send notification to user
      await NotificationService.sendCertificateStatusUpdateNotification(
        userId: certificate.userId,
        certificateType: certificate.certificateType,
        status: CertificateStatus.approved,
      );

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Issue certificate (generate PDF and mark as issued)
  Future<bool> issueCertificate(
    CertificateModel certificate,
    String adminId,
    String adminName,
    String barangayName,
  ) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Uint8List pdfData;
      
      // Generate PDF based on certificate type
      if (certificate.certificateType == CertificateTypes.barangayClearance) {
        pdfData = await CertificateService.generateBarangayClearance(
          residentName: certificate.userName,
          address: certificate.data['address'] ?? '',
          purpose: certificate.purpose ?? '',
          qrCodeData: certificate.qrCodeData,
          barangayName: barangayName,
          issuedBy: adminName,
          issuedDate: certificate.issuedDate,
        );
      } else if (certificate.certificateType == CertificateTypes.certificateOfIndigency) {
        pdfData = await CertificateService.generateCertificateOfIndigency(
          residentName: certificate.userName,
          address: certificate.data['address'] ?? '',
          purpose: certificate.purpose ?? '',
          qrCodeData: certificate.qrCodeData,
          barangayName: barangayName,
          issuedBy: adminName,
          issuedDate: certificate.issuedDate,
        );
      } else if (certificate.certificateType == CertificateTypes.certificateOfResidency) {
        pdfData = await CertificateService.generateCertificateOfResidency(
          residentName: certificate.userName,
          address: certificate.data['address'] ?? '',
          qrCodeData: certificate.qrCodeData,
          barangayName: barangayName,
          issuedBy: adminName,
          issuedDate: certificate.issuedDate,
        );
      } else {
        throw Exception('Unknown certificate type');
      }

      // Update certificate status immediately (don't wait for upload)
      final updatedCertificate = certificate.copyWith(
        status: CertificateStatus.issued,
        issuedBy: adminId,
        issuedByName: adminName,
        updatedAt: DateTime.now(),
      );

      print('About to update certificate ${certificate.id} to status: ${CertificateStatus.issued}');
      print('Certificate userId: ${certificate.userId}');
      
      await _firebaseService.updateCertificate(updatedCertificate);
      
      print('Certificate update completed. Stream should detect change automatically.');
      
      // IMPORTANT: Force refresh the resident's certificate list immediately
      // This ensures they see the update right away
      if (certificate.userId.isNotEmpty) {
        print('Triggering immediate refresh for user: ${certificate.userId}');
        // Cancel existing subscription
        await _userCertificatesSubscription?.cancel();
        // Wait for Firestore to commit the update
        await Future.delayed(const Duration(milliseconds: 500));
        // Force reload the stream - this will update the resident's view
        await loadUserCertificates(certificate.userId);
        print('Refresh completed for user certificates');
      }

      // Send notification immediately (don't wait for PDF upload)
      NotificationService.sendCertificateStatusUpdateNotification(
        userId: certificate.userId,
        certificateType: certificate.certificateType,
        status: CertificateStatus.issued,
      ).catchError((e) => print('Notification error: $e'));

      // Upload PDF to storage in background (async - doesn't block)
      _firebaseService.uploadCertificatePDF(certificate.id, pdfData).then((pdfUrl) {
        // Update with PDF URL once upload completes
        final certWithPdf = updatedCertificate.copyWith(pdfUrl: pdfUrl);
        _firebaseService.updateCertificate(certWithPdf).catchError((e) {
          print('Failed to update PDF URL: $e');
        });

        // Send email notification with PDF URL once upload is complete
        _firebaseService.getUserData(certificate.userId).then((user) {
          if (user?.email != null) {
            CommunicationService.sendCertificateReadyEmail(
              email: user!.email,
              residentName: certificate.userName,
              certificateType: CertificateTypes.getDisplayName(certificate.certificateType),
              downloadUrl: pdfUrl,
            ).catchError((e) => print('Email error: $e'));
          }
        }).catchError((e) => print('Get user error: $e'));
      }).catchError((e) {
        print('PDF upload failed (non-critical): $e');
        // Don't fail the whole process if upload fails
      });

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to issue certificate: ${e.toString()}';
      _isSubmitting = false;
      notifyListeners();
      print('Certificate issuance error: $e');
      return false;
    }
  }

  /// Reject certificate
  Future<bool> rejectCertificate(
    CertificateModel certificate,
    String adminId,
    String adminName,
    String reason,
  ) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCertificate = certificate.copyWith(
        status: CertificateStatus.rejected,
        issuedBy: adminId,
        issuedByName: adminName,
        rejectionReason: reason,
        updatedAt: DateTime.now(),
      );

      await _firebaseService.updateCertificate(updatedCertificate);

      // Force refresh for the resident to see the update
      if (certificate.userId.isNotEmpty) {
        await _userCertificatesSubscription?.cancel();
        await Future.delayed(const Duration(milliseconds: 300));
        await loadUserCertificates(certificate.userId);
      }

      // Send notification to user
      await NotificationService.sendCertificateStatusUpdateNotification(
        userId: certificate.userId,
        certificateType: certificate.certificateType,
        status: CertificateStatus.rejected,
      );

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}

