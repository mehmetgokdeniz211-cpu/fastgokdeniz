import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/database_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _db.getUserProfile(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProfile(UserProfile profile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _db.saveUserProfile(profile);
      _profile = profile;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? profileImageUrl,
  }) async {
    if (_profile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (displayName != null) _profile!.displayName = displayName;
      if (bio != null) _profile!.bio = bio;
      if (profileImageUrl != null) _profile!.profileImageUrl = profileImageUrl;
      
      _profile!.updatedAt = DateTime.now();
      await _db.saveUserProfile(_profile!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> incrementScans() async {
    if (_profile == null) return;
    _profile!.totalScans++;
    await _db.saveUserProfile(_profile!);
    notifyListeners();
  }

  Future<void> incrementMessages() async {
    if (_profile == null) return;
    _profile!.totalMessages++;
    await _db.saveUserProfile(_profile!);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
