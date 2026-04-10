import 'package:flutter/material.dart';
import '../../core/services/authentication_service.dart';
import '../../core/services/notification_service.dart';

class AuthenticationProvider extends ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  String? _error;
  bool? _isLoggedIn;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn ?? false;
  String? get currentUserId => _authService.currentUser?.uid;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.loginWithEmail(email, password);
      _isLoggedIn = true;
      
      // Show notification
      await _notificationService.showNotification(
        id: 1,
        title: 'Welcome Back!',
        body: 'You have successfully logged in.',
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Up
  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmail(email, password);
      _isLoggedIn = true;
      
      // Send verification email
      await _authService.sendEmailVerification();
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Anonymous Login
  Future<bool> loginAnonymously() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInAnonymously();
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.logout();
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
