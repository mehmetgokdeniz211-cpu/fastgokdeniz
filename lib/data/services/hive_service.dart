import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/saved_message.dart';
import '../models/cache_item.dart';
import '../models/user_profile.dart';
import '../models/scan_history.dart';

class HiveService {
  static const String _savedMessagesBox = 'saved_messages';
  static const String _cacheBox = 'cache';
  static const String _userProfilesBox = 'user_profiles';
  static const String _scanHistoryBox = 'scan_history';
  
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      // Web platformunda Hive destekte sınırlı, bu nedenle initialize'ı koşullu yap
      if (kIsWeb) {
        debugPrint('Web platformu: Hive desteklenmek üzere (beta)');
        _isInitialized = false;
        return;
      }

      await Hive.initFlutter();

      // Register adapters
      Hive.registerAdapter(SavedMessageAdapter());
      Hive.registerAdapter(CacheItemAdapter());
      Hive.registerAdapter(UserProfileAdapter());
      Hive.registerAdapter(ScanHistoryAdapter());

      // Open boxes
      await Hive.openBox<SavedMessage>(_savedMessagesBox);
      await Hive.openBox<CacheItem>(_cacheBox);
      await Hive.openBox<UserProfile>(_userProfilesBox);
      await Hive.openBox<ScanHistory>(_scanHistoryBox);
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Hive initialization error: $e');
      _isInitialized = false;
    }
  }

  // Saved Messages operations
  static Box<SavedMessage>? get _savedMessagesBoxSafe {
    if (!_isInitialized) return null;
    try {
      return Hive.box<SavedMessage>(_savedMessagesBox);
    } catch (e) {
      debugPrint('Error accessing savedMessagesBox: $e');
      return null;
    }
  }

  static Box<SavedMessage> get savedMessagesBox {
    final box = _savedMessagesBoxSafe;
    if (box == null) throw Exception('Hive not initialized');
    return box;
  }

  static Future<void> addSavedMessage(SavedMessage message) async {
    if (!_isInitialized) return;
    try {
      await savedMessagesBox.add(message);
    } catch (e) {
      debugPrint('Error adding saved message: $e');
    }
  }

  static List<SavedMessage> getSavedMessages() {
    if (!_isInitialized) return [];
    try {
      return savedMessagesBox.values.toList();
    } catch (e) {
      debugPrint('Error getting saved messages: $e');
      return [];
    }
  }

  static Future<void> updateSavedMessage(int index, SavedMessage message) async {
    if (!_isInitialized) return;
    try {
      await savedMessagesBox.putAt(index, message);
    } catch (e) {
      debugPrint('Error updating saved message: $e');
    }
  }

  static Future<void> deleteSavedMessage(int index) async {
    if (!_isInitialized) return;
    try {
      await savedMessagesBox.deleteAt(index);
    } catch (e) {
      debugPrint('Error deleting saved message: $e');
    }
  }

  // Cache operations
  static Box<CacheItem>? get _cacheBoxSafe {
    if (!_isInitialized) return null;
    try {
      return Hive.box<CacheItem>(_cacheBox);
    } catch (e) {
      debugPrint('Error accessing cacheBox: $e');
      return null;
    }
  }

  static Box<CacheItem> get cacheBox {
    final box = _cacheBoxSafe;
    if (box == null) throw Exception('Hive not initialized');
    return box;
  }

  static Future<void> addCacheItem(CacheItem item) async {
    if (!_isInitialized) return;
    try {
      await cacheBox.add(item);
    } catch (e) {
      debugPrint('Error adding cache item: $e');
    }
  }

  static List<CacheItem> getCacheItems() {
    if (!_isInitialized) return [];
    try {
      return cacheBox.values.toList();
    } catch (e) {
      debugPrint('Error getting cache items: $e');
      return [];
    }
  }

  static Future<void> updateCacheItem(int index, CacheItem item) async {
    if (!_isInitialized) return;
    try {
      await cacheBox.putAt(index, item);
    } catch (e) {
      debugPrint('Error updating cache item: $e');
    }
  }

  static Future<void> deleteCacheItem(int index) async {
    if (!_isInitialized) return;
    try {
      await cacheBox.deleteAt(index);
    } catch (e) {
      debugPrint('Error deleting cache item: $e');
    }
  }

  // User Profile operations
  static Box<UserProfile>? get _userProfilesBoxSafe {
    if (!_isInitialized) return null;
    try {
      return Hive.box<UserProfile>(_userProfilesBox);
    } catch (e) {
      debugPrint('Error accessing userProfilesBox: $e');
      return null;
    }
  }

  static Box<UserProfile> get userProfilesBox {
    final box = _userProfilesBoxSafe;
    if (box == null) throw Exception('Hive not initialized');
    return box;
  }

  static Future<void> addUserProfile(UserProfile profile) async {
    if (!_isInitialized) return;
    try {
      await userProfilesBox.add(profile);
    } catch (e) {
      debugPrint('Error adding user profile: $e');
    }
  }

  static List<UserProfile> getUserProfiles() {
    if (!_isInitialized) return [];
    try {
      return userProfilesBox.values.toList();
    } catch (e) {
      debugPrint('Error getting user profiles: $e');
      return [];
    }
  }

  static Future<void> updateUserProfile(int index, UserProfile profile) async {
    if (!_isInitialized) return;
    try {
      await userProfilesBox.putAt(index, profile);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
    }
  }

  static Future<void> deleteUserProfile(int index) async {
    if (!_isInitialized) return;
    try {
      await userProfilesBox.deleteAt(index);
    } catch (e) {
      debugPrint('Error deleting user profile: $e');
    }
  }

  // Scan History operations
  static Box<ScanHistory>? get _scanHistoryBoxSafe {
    if (!_isInitialized) return null;
    try {
      return Hive.box<ScanHistory>(_scanHistoryBox);
    } catch (e) {
      debugPrint('Error accessing scanHistoryBox: $e');
      return null;
    }
  }

  static Box<ScanHistory> get scanHistoryBox {
    final box = _scanHistoryBoxSafe;
    if (box == null) throw Exception('Hive not initialized');
    return box;
  }

  static Future<void> addScanHistory(ScanHistory scan) async {
    if (!_isInitialized) return;
    try {
      await scanHistoryBox.add(scan);
    } catch (e) {
      debugPrint('Error adding scan history: $e');
    }
  }

  static List<ScanHistory> getScanHistory() {
    if (!_isInitialized) return [];
    try {
      return scanHistoryBox.values.toList();
    } catch (e) {
      debugPrint('Error getting scan history: $e');
      return [];
    }
  }

  static Future<void> updateScanHistory(int index, ScanHistory scan) async {
    if (!_isInitialized) return;
    try {
      await scanHistoryBox.putAt(index, scan);
    } catch (e) {
      debugPrint('Error updating scan history: $e');
    }
  }

  static Future<void> deleteScanHistory(int index) async {
    if (!_isInitialized) return;
    try {
      await scanHistoryBox.deleteAt(index);
    } catch (e) {
      debugPrint('Error deleting scan history: $e');
    }
  }

  // Utility methods
  static Future<void> clearAllData() async {
    if (!_isInitialized) return;
    try {
      await savedMessagesBox.clear();
      await cacheBox.clear();
      await userProfilesBox.clear();
      await scanHistoryBox.clear();
    } catch (e) {
      debugPrint('Error clearing all data: $e');
    }
  }

  static Future<void> closeBoxes() async {
    if (!_isInitialized) return;
    try {
      await Hive.close();
    } catch (e) {
      debugPrint('Error closing boxes: $e');
    }
  }
}