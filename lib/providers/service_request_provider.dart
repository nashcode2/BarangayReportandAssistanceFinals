import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/service_request_model.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

/// Provider for managing service request state
class ServiceRequestProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<ServiceRequestModel>>? _requestsSubscription;
  
  List<ServiceRequestModel> _userRequests = [];
  List<ServiceRequestModel> _allRequests = []; // For admin
  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceRequestModel> get userRequests => _userRequests;
  List<ServiceRequestModel> get allRequests => _allRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ServiceRequestProvider() {
    // Don't auto-load, wait for explicit call
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    super.dispose();
  }

  /// Load service requests for a specific user
  Future<void> loadUserRequests(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cancel existing subscription if any
      await _requestsSubscription?.cancel();
      
      // Load data first with one-time fetch
      try {
        _userRequests = await _firebaseService.getUserServiceRequestsOnce(userId);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      } catch (e) {
        print('One-time fetch failed: $e');
      }
      
      // Then set up stream for real-time updates
      try {
        _requestsSubscription = _firebaseService.getUserServiceRequests(userId).listen(
          (requests) {
            _userRequests = requests;
            _errorMessage = null;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            print('Stream error (using cached data): $error');
            if (_userRequests.isEmpty) {
              _errorMessage = 'Failed to load service requests: $error';
              _isLoading = false;
              notifyListeners();
            }
          },
          cancelOnError: false,
        );
      } catch (e) {
        print('Stream setup failed (using one-time fetch): $e');
        if (_userRequests.isEmpty) {
          _isLoading = false;
          notifyListeners();
        }
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load service requests: $e';
      notifyListeners();
    }
  }

  /// Load all service requests (admin only)
  Future<void> loadAllRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _requestsSubscription?.cancel();
      
      _requestsSubscription = _firebaseService.getAllServiceRequests().listen(
        (requests) {
          _allRequests = requests;
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Failed to load service requests: $error';
          _isLoading = false;
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load service requests: $e';
      notifyListeners();
    }
  }

  /// Create a new service request
  Future<bool> createServiceRequest(ServiceRequestModel request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.createServiceRequest(request);
      // Reload user requests
      if (request.userId.isNotEmpty) {
        await loadUserRequests(request.userId);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create service request: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update service request
  Future<bool> updateServiceRequest(ServiceRequestModel request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get old request to check if status changed
      final oldRequest = _userRequests.firstWhere(
        (r) => r.id == request.id,
        orElse: () => request,
      );
      
      await _firebaseService.updateServiceRequest(request);
      
      // Send notification if status changed
      if (oldRequest.status != request.status) {
        await NotificationService.notifyServiceRequestUpdate(
          serviceType: request.serviceType,
          status: request.status,
        );
      }
      
      // Reload requests
      if (request.userId.isNotEmpty) {
        await loadUserRequests(request.userId);
      }
      await loadAllRequests();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update service request: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete service request
  Future<bool> deleteServiceRequest(String requestId, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.deleteServiceRequest(requestId);
      await loadUserRequests(userId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete service request: $e';
      notifyListeners();
      return false;
    }
  }
}

