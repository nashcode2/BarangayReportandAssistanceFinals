import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

/// Provider for authentication state management
class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize authentication listener
  void _initializeAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        await loadUserData(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  /// Load user data from Firestore
  Future<void> loadUserData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _firebaseService.getUserData(userId);
      if (_currentUser != null) {
        debugPrint(
          'Loaded user ${_currentUser!.email} (id: ${_currentUser!.id}) isAdmin=${_currentUser!.isAdmin}',
        );
      } else {
        debugPrint('No user document found for uid: $userId');
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _firebaseService.signInWithEmail(
        email,
        password,
      );

      if (userCredential?.user != null) {
        await loadUserData(userCredential!.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Sign in failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register new user
  Future<bool> registerWithEmail(
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _firebaseService.registerWithEmail(
        email,
        password,
        name,
        phone,
      );

      if (userCredential?.user != null) {
        await loadUserData(userCredential!.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.signOut();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Sign out failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.resetPassword(email);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Password reset failed: $e';
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

