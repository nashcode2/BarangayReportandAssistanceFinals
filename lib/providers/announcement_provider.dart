import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/announcement_model.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

/// Provider for announcement state management
class AnnouncementProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<AnnouncementModel>>? _announcementsSubscription;

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all announcements
  Future<void> loadAnnouncements() async {
    print('AnnouncementProvider: loadAnnouncements called');
    
    // Cancel existing subscription if any
    await _announcementsSubscription?.cancel();
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print('AnnouncementProvider: Set loading to true');

    try {
      // First, try one-time fetch to get initial data quickly
      print('AnnouncementProvider: Attempting one-time fetch...');
      try {
        final announcements = await _firebaseService.getAnnouncementsOnce();
        print('AnnouncementProvider: Got ${announcements.length} announcements');
        _announcements = announcements;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        print('AnnouncementProvider: Updated state, isLoading=false');
      } catch (e) {
        print('AnnouncementProvider: One-time fetch failed: $e');
        // If one-time fetch fails, show error
        _errorMessage = 'Failed to load announcements: $e';
        _isLoading = false;
        notifyListeners();
      }
      
      // Then set up stream for real-time updates (don't block on errors)
      print('AnnouncementProvider: Setting up stream...');
      try {
        _announcementsSubscription = _firebaseService.getAnnouncements().listen(
          (announcements) {
            print('AnnouncementProvider: Stream update: ${announcements.length} announcements');
            _announcements = announcements;
            _errorMessage = null;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            print('AnnouncementProvider: Stream error: $error');
            // Don't overwrite successful data with stream errors
            if (_announcements.isEmpty) {
              _errorMessage = 'Failed to load announcements: $error';
              _isLoading = false;
              notifyListeners();
            }
          },
        );
        print('AnnouncementProvider: Stream subscription created');
      } catch (e) {
        print('AnnouncementProvider: Stream setup failed: $e');
        // Stream setup failed, but we might have data from one-time fetch
        if (_announcements.isEmpty) {
          _errorMessage = 'Failed to set up real-time updates: $e';
          _isLoading = false;
          notifyListeners();
        }
      }
    } catch (e, stackTrace) {
      print('AnnouncementProvider: Unexpected error: $e');
      print('AnnouncementProvider: Stack trace: $stackTrace');
      _errorMessage = 'Failed to load announcements: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _announcementsSubscription?.cancel();
    super.dispose();
  }

  /// Create announcement
  Future<bool> createAnnouncement(AnnouncementModel announcement) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.createAnnouncement(announcement);
      
      // Send notification to all users about new announcement
      await NotificationService.notifyNewAnnouncement(
        title: announcement.title,
      );
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create announcement: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update announcement
  Future<bool> updateAnnouncement(AnnouncementModel announcement) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.updateAnnouncement(announcement);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update announcement: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete announcement
  Future<bool> deleteAnnouncement(String announcementId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.deleteAnnouncement(announcementId);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete announcement: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

