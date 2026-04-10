import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/scan_history.dart';
import '../models/user_profile.dart';
import '../models/saved_message.dart';
import '../models/cache_item.dart';
import 'hive_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late SharedPreferences _prefs;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Scan History Operations - Using Hive
  Future<void> addScanHistory(ScanHistory scan) async {
    scan.id = DateTime.now().millisecondsSinceEpoch; // Generate ID
    await HiveService.addScanHistory(scan);
  }

  Future<List<ScanHistory>> getScanHistory({
    int limit = 50,
    bool favoritesOnly = false,
  }) async {
    List<ScanHistory> scans = HiveService.getScanHistory();

    if (favoritesOnly) {
      scans = scans.where((s) => s.isFavorite).toList();
    }

    scans.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return scans.take(limit).toList();
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    List<ScanHistory> scans = HiveService.getScanHistory();
    int index = scans.indexWhere((s) => s.id == id);
    if (index >= 0) {
      scans[index].isFavorite = isFavorite;
      await HiveService.updateScanHistory(index, scans[index]);
    }
  }

  Future<void> deleteScanHistory(int id) async {
    List<ScanHistory> scans = HiveService.getScanHistory();
    int index = scans.indexWhere((s) => s.id == id);
    if (index >= 0) {
      await HiveService.deleteScanHistory(index);
    }
  }

  Future<void> clearScanHistory() async {
    // For backward compatibility, also clear SharedPreferences
    await _prefs.remove('scan_history');
    // Clear Hive box
    await HiveService.scanHistoryBox.clear();
  }

  // User Profile Operations - Using Hive
  Future<void> saveUserProfile(UserProfile profile) async {
    profile.id = DateTime.now().millisecondsSinceEpoch; // Generate ID
    await HiveService.addUserProfile(profile);
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    List<UserProfile> profiles = HiveService.getUserProfiles();
    return profiles.where((p) => p.userId == userId).firstOrNull;
  }

  Future<void> updateUserStats(String userId, {
    int? scans,
    int? messages,
    int? favorites,
  }) async {
    List<UserProfile> profiles = HiveService.getUserProfiles();
    int index = profiles.indexWhere((p) => p.userId == userId);
    if (index >= 0) {
      UserProfile profile = profiles[index];
      if (scans != null) profile.totalScans = scans;
      if (messages != null) profile.totalMessages = messages;
      if (favorites != null) profile.totalFavorites = favorites;
      profile.updatedAt = DateTime.now();
      await HiveService.updateUserProfile(index, profile);
    }
  }

  // Saved Messages Operations - Using Hive
  Future<void> addSavedMessage(SavedMessage message) async {
    message.id = DateTime.now().millisecondsSinceEpoch; // Generate ID
    await HiveService.addSavedMessage(message);
  }

  Future<List<SavedMessage>> getSavedMessages({String? category}) async {
    List<SavedMessage> messages = HiveService.getSavedMessages();

    if (category != null) {
      messages = messages.where((m) => m.category == category).toList();
    }

    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return messages;
  }

  Future<void> deleteSavedMessage(int id) async {
    final messages = HiveService.getSavedMessages();
    final index = messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      await HiveService.deleteSavedMessage(index);
    }
  }

  Future<void> updateSavedMessage(int index, SavedMessage message) async {
    await HiveService.updateSavedMessage(index, message);
  }

  // Cache Operations - Using Hive
  Future<void> setCacheItem(String key, String value, {int expiryDays = 30}) async {
    CacheItem cacheItem = CacheItem()
      ..key = key
      ..value = value
      ..createdAt = DateTime.now()
      ..expiresAt = DateTime.now().add(Duration(days: expiryDays))
      ..type = 'text';

    // Check if item already exists
    List<CacheItem> items = HiveService.getCacheItems();
    int existingIndex = items.indexWhere((item) => item.key == key);

    if (existingIndex >= 0) {
      await HiveService.updateCacheItem(existingIndex, cacheItem);
    } else {
      await HiveService.addCacheItem(cacheItem);
    }
  }

  Future<String?> getCacheItem(String key) async {
    List<CacheItem> items = HiveService.getCacheItems();
    CacheItem? item;
    for (final cacheItem in items) {
      if (cacheItem.key == key) {
        item = cacheItem;
        break;
      }
    }

    if (item == null || item.isExpired()) {
      if (item != null) {
        // Remove expired item
        int index = items.indexOf(item);
        await HiveService.deleteCacheItem(index);
      }
      return null;
    }

    return item.value;
  }

  Future<void> deleteCacheItem(String key) async {
    List<CacheItem> items = HiveService.getCacheItems();
    int index = items.indexWhere((item) => item.key == key);
    if (index >= 0) {
      await HiveService.deleteCacheItem(index);
    }
  }

  Future<void> clearExpiredCache() async {
    List<CacheItem> items = HiveService.getCacheItems();
    for (int i = items.length - 1; i >= 0; i--) {
      if (items[i].isExpired()) {
        await HiveService.deleteCacheItem(i);
      }
    }
  }

  Future<void> close() async {
    await HiveService.closeBoxes();
  }
}
