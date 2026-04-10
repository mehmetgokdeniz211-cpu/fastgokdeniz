import 'package:flutter/material.dart';
import '../../data/services/app_storage_service.dart';

class ThemeProvider with ChangeNotifier {
  final AppStorageService _storageService = AppStorageService();
  
  String _themeMode = 'dark'; // 'light' or 'dark'
  String _language = 'tr'; // 'tr' or 'en'
  bool _isInitialized = false;

  String get themeMode => _themeMode;
  String get language => _language;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadThemeAndLanguage();
  }

  Future<void> _loadThemeAndLanguage() async {
    try {
      _themeMode = await _storageService.getTheme();
      _language = await _storageService.getLanguage();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme and language: $e');
      _isInitialized = true; // Hata olsa bile initialized olarak işaretle
      notifyListeners();
    }
  }

  Future<void> setTheme(String theme) async {
    _themeMode = theme;
    await _storageService.setTheme(theme);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    await _storageService.setLanguage(language);
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == 'dark';
}
