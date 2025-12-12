import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/firebase_service.dart';

/// Provider for managing review state
class ReviewProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<ReviewModel>>? _reviewsSubscription;
  
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _averageRating = 0.0;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get averageRating => _averageRating;

  ReviewProvider() {
    loadReviews();
    loadAverageRating();
  }

  @override
  void dispose() {
    _reviewsSubscription?.cancel();
    super.dispose();
  }

  /// Load all visible reviews
  Future<void> loadReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cancel existing subscription if any
      await _reviewsSubscription?.cancel();
      
      // Try one-time fetch first to ensure we have data
      await _loadReviewsOnce();
      
      // Then set up stream for real-time updates
      try {
        _reviewsSubscription = _firebaseService.getReviews().listen(
          (reviews) {
            _reviews = reviews;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            // If stream fails, keep using the one-time fetch data
            // Don't clear the reviews, just log the error
            print('Stream error (using cached data): $error');
          },
          cancelOnError: false,
        );
      } catch (e) {
        // Stream setup failed, but we already have data from _loadReviewsOnce
        print('Stream setup failed (using one-time fetch): $e');
      }
    } catch (e) {
      // If everything fails, try one-time fetch
      _loadReviewsOnce();
    }
  }

  /// Fallback: Load reviews with one-time fetch
  Future<void> _loadReviewsOnce() async {
    try {
      _reviews = await _firebaseService.getReviewsOnce();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load reviews: $e';
      _reviews = []; // Ensure empty list on error
      notifyListeners();
    }
  }

  /// Load average rating
  Future<void> loadAverageRating() async {
    try {
      _averageRating = await _firebaseService.getAverageRating();
      notifyListeners();
    } catch (e) {
      // Silently fail - not critical
    }
  }

  /// Submit a new review
  Future<bool> submitReview({
    required String userId,
    required String userName,
    required int rating,
    required String comment,
    String? reportId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final review = ReviewModel(
        id: '', // Will be set by Firebase
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        reportId: reportId,
        createdAt: DateTime.now(),
        isVisible: true, // Ensure it's visible
      );

      await _firebaseService.createReview(review);
      
      // Wait a bit for Firestore to sync
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Reload reviews to ensure the new review appears
      await _loadReviewsOnce();
      await loadAverageRating();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to submit review: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get reviews for a specific user
  Stream<List<ReviewModel>> getUserReviews(String userId) {
    return _firebaseService.getUserReviews(userId);
  }
}

