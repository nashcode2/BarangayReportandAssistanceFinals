import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

/// Provider for managing event state
class EventProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<EventModel>>? _eventsSubscription;
  
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<EventModel> get upcomingEvents => 
      _events.where((e) => e.isUpcoming).toList();
  
  List<EventModel> get ongoingEvents => 
      _events.where((e) => e.isOngoing).toList();

  EventProvider() {
    loadEvents();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }

  /// Load all events
  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cancel existing subscription if any
      await _eventsSubscription?.cancel();
      
      // Load data first with one-time fetch
      try {
        _events = await _firebaseService.getEventsOnce();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      } catch (e) {
        print('One-time fetch failed: $e');
      }
      
      // Then set up stream for real-time updates
      try {
        _eventsSubscription = _firebaseService.getEvents().listen(
          (events) {
            _events = events;
            _errorMessage = null;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            print('Stream error (using cached data): $error');
            if (_events.isEmpty) {
              _errorMessage = 'Failed to load events: $error';
              _isLoading = false;
              notifyListeners();
            }
          },
          cancelOnError: false,
        );
      } catch (e) {
        print('Stream setup failed (using one-time fetch): $e');
        if (_events.isEmpty) {
          _isLoading = false;
          notifyListeners();
        }
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load events: $e';
      notifyListeners();
    }
  }

  /// Create a new event (admin only)
  Future<bool> createEvent(EventModel event) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.createEvent(event);
      
      // Send notification about new event
      await NotificationService.notifyNewEvent(
        eventTitle: event.title,
      );
      
      await loadEvents(); // Reload events
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create event: $e';
      notifyListeners();
      return false;
    }
  }

  /// RSVP to an event
  Future<bool> rsvpToEvent(String eventId, String userId) async {
    try {
      await _firebaseService.rsvpToEvent(eventId, userId);
      await loadEvents(); // Reload to get updated RSVP list
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to RSVP: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cancel RSVP
  Future<bool> cancelRsvp(String eventId, String userId) async {
    try {
      await _firebaseService.cancelRsvp(eventId, userId);
      await loadEvents(); // Reload to get updated RSVP list
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel RSVP: $e';
      notifyListeners();
      return false;
    }
  }

  /// Check if user has RSVP'd
  bool hasUserRsvpd(String eventId, String userId) {
    final event = _events.firstWhere(
      (e) => e.id == eventId,
      orElse: () => EventModel(
        id: '',
        title: '',
        description: '',
        eventType: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        createdBy: '',
        createdByName: '',
        createdAt: DateTime.now(),
      ),
    );
    return event.rsvpUserIds.contains(userId);
  }

  /// Update event (admin only)
  Future<bool> updateEvent(EventModel event) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.updateEvent(event);
      await loadEvents();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update event: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete event (admin only)
  Future<bool> deleteEvent(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.deleteEvent(eventId);
      await loadEvents();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete event: $e';
      notifyListeners();
      return false;
    }
  }
}

