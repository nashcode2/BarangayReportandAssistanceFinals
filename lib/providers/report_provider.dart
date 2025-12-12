import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

/// Provider for report state management
class ReportProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<ReportModel>>? _userReportsSubscription;
  StreamSubscription<List<ReportModel>>? _allReportsSubscription;
  
  List<ReportModel> _reports = [];
  List<ReportModel> _userReports = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<ReportModel> get reports => _reports;
  List<ReportModel> get userReports => _userReports;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _userReportsSubscription?.cancel();
    _allReportsSubscription?.cancel();
    super.dispose();
  }

  /// Load all reports (for admin)
  Future<void> loadAllReports() async {
    // Don't set loading if we're submitting
    if (_isSubmitting) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cancel existing subscription if any
      await _allReportsSubscription?.cancel();
      
      // Set up stream for real-time updates
      _allReportsSubscription = _firebaseService.getAllReports().listen(
        (reports) {
          _reports = reports;
          _errorMessage = null;
          if (!_isSubmitting) {
            _isLoading = false;
          }
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Failed to load reports: $error';
          if (!_isSubmitting) {
            _isLoading = false;
          }
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _errorMessage = 'Failed to load reports: $e';
      if (!_isSubmitting) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Load user reports
  Future<void> loadUserReports(String userId) async {
    // Don't set loading if we're submitting
    if (_isSubmitting) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cancel existing subscription if any
      await _userReportsSubscription?.cancel();
      
      // Load data first with one-time fetch to ensure we have data
      try {
        _userReports = await _firebaseService.getUserReportsOnce(userId);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      } catch (e) {
        print('One-time fetch failed: $e');
      }
      
      // Then set up stream for real-time updates
      try {
        _userReportsSubscription = _firebaseService.getUserReports(userId).listen(
          (reports) {
            _userReports = reports;
            _errorMessage = null;
            if (!_isSubmitting) {
              _isLoading = false;
            }
            notifyListeners();
          },
          onError: (error) {
            // If stream fails, keep using the one-time fetch data
            print('Stream error (using cached data): $error');
            if (!_isSubmitting) {
              _isLoading = false;
            }
            notifyListeners();
          },
          cancelOnError: false,
        );
      } catch (e) {
        print('Stream setup failed (using one-time fetch): $e');
        if (!_isSubmitting) {
          _isLoading = false;
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load user reports: $e';
      if (!_isSubmitting) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Create new report
  Future<ReportModel?> createReport(ReportModel report, {bool manageSubmitting = true}) async {
    if (manageSubmitting) {
      _isSubmitting = true;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      final createdReport = await _firebaseService.createReport(report);
      _errorMessage = null;
      return createdReport;
    } catch (e) {
      _errorMessage = 'Failed to create report: $e';
      if (manageSubmitting) {
        _isSubmitting = false;
        notifyListeners();
      }
      return null;
    } finally {
      if (manageSubmitting) {
        _isSubmitting = false;
        notifyListeners();
      }
    }
  }

  /// Update report
  Future<bool> updateReport(ReportModel report, {bool manageSubmitting = true}) async {
    if (manageSubmitting) {
      _isSubmitting = true;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      // Get old report to check if status changed
      final oldReport = _userReports.firstWhere(
        (r) => r.id == report.id,
        orElse: () => report,
      );
      
      await _firebaseService.updateReport(report);
      
      // Send notification if status changed
      if (oldReport.status != report.status) {
        await NotificationService.notifyReportStatusChange(
          reportId: report.id,
          status: report.status,
          issueType: report.issueType,
        );
      }
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update report: $e';
      if (manageSubmitting) {
        _isSubmitting = false;
        notifyListeners();
      }
      return false;
    } finally {
      if (manageSubmitting) {
        _isSubmitting = false;
        notifyListeners();
      }
    }
  }

  /// Upload report photo
  Future<String?> uploadReportPhoto(String reportId, String filePath) async {
    try {
      final result = await _firebaseService.uploadReportPhoto(reportId, filePath);
      return result;
    } catch (e) {
      _errorMessage = 'Failed to upload photo: $e';
      notifyListeners();
      return null;
    }
  }

  /// Set submitting state (for managing submission flow)
  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

