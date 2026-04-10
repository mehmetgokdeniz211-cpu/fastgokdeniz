import 'package:flutter/material.dart';
import '../../data/models/scan_history.dart';
import '../../data/services/database_service.dart';
import '../../core/services/search_filter_service.dart';

class ScanHistoryProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final SearchFilterService _search = SearchFilterService();

  List<ScanHistory> _scanHistory = [];
  List<ScanHistory> _filteredHistory = [];
  bool _isLoading = false;
  String? _error;

  List<ScanHistory> get scanHistory => _filteredHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadScanHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _scanHistory = await _db.getScanHistory(limit: 10000);
      _filteredHistory = _scanHistory;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addScan(ScanHistory scan) async {
    try {
      await _db.addScanHistory(scan);
      _scanHistory.insert(0, scan);
      _filteredHistory = _scanHistory;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int id) async {
    try {
      final scan = _scanHistory.firstWhere((s) => s.id == id);
      scan.isFavorite = !scan.isFavorite;
      await _db.toggleFavorite(id, scan.isFavorite);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchScans(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _filteredHistory = await _search.advancedSearch(query: query);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByType(String type) async {
    _isLoading = true;
    notifyListeners();

    try {
      _filteredHistory = await _search.advancedSearch(qrType: type);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByDate(DateTime from, DateTime to) async {
    _isLoading = true;
    notifyListeners();

    try {
      _filteredHistory = await _search.advancedSearch(
        fromDate: from,
        toDate: to,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> showFavoritesOnly() async {
    _filteredHistory = 
        _scanHistory.where((scan) => scan.isFavorite).toList();
    notifyListeners();
  }

  Future<void> getTrendingItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _filteredHistory = await _search.getTrendingItems(limit: 20);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    try {
      await _db.clearScanHistory();
      _scanHistory.clear();
      _filteredHistory.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void resetFilter() {
    _filteredHistory = _scanHistory;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
