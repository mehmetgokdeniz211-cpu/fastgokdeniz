import 'package:shared_preferences/shared_preferences.dart';

class AppStorageService {
  static const String _isProfileCreatedKey = 'is_profile_created';
  static const String _usernameKey = 'username';
  static const String _userImageKey = 'user_image';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _searchHistoryKey = 'search_history';
  static const String _createdQrHistoryKey = 'created_qr_history';
  static const String _themeKey = 'theme_mode'; // 'light' or 'dark'
  static const String _languageKey = 'language'; // 'tr' or 'en'

  Future<bool> isProfileCreated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isProfileCreatedKey) ?? false;
  }

  Future<void> createProfile({
    required String username,
    String? imagePath,
    String? email,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isProfileCreatedKey, true);
    await prefs.setString(_usernameKey, username);
    if (imagePath != null) {
      await prefs.setString(_userImageKey, imagePath);
    }
    if (email != null) {
      await prefs.setString(_userEmailKey, email);
    }
    if (phone != null) {
      await prefs.setString(_userPhoneKey, phone);
    }
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<String?> getUserImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userImageKey);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey);
  }

  Future<void> updateUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  Future<void> updateUserPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPhoneKey, phone);
  }

  Future<void> resetProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isProfileCreatedKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userImageKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhoneKey);
  }

  Future<void> updateUserImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userImageKey, imagePath);
  }

  Future<void> addSearchHistory(String item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_searchHistoryKey) ?? [];

    // Remove if already exists to avoid duplicates
    history.remove(item);

    // Add to beginning
    history.insert(0, item);

    // Keep only last 20 items
    if (history.length > 20) {
      history = history.sublist(0, 20);
    }

    await prefs.setStringList(_searchHistoryKey, history);
  }

  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }

  Future<void> removeSearchItem(String item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_searchHistoryKey) ?? [];
    history.remove(item);
    await prefs.setStringList(_searchHistoryKey, history);
  }

  Future<void> addCreatedQr(String url) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_createdQrHistoryKey) ?? [];
    history.remove(url);
    history.insert(0, url);
    if (history.length > 20) {
      history = history.sublist(0, 20);
    }
    await prefs.setStringList(_createdQrHistoryKey, history);
  }

  Future<List<String>> getCreatedQrHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_createdQrHistoryKey) ?? [];
  }

  Future<void> clearCreatedQrHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_createdQrHistoryKey);
  }

  // Theme methods
  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'dark';
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  // Language methods
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'tr';
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<void> setLoggedIn(String text) async {}
}
