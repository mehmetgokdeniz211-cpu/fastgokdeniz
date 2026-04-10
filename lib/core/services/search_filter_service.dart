import '../../data/services/database_service.dart';
import '../../data/models/scan_history.dart';

class SearchFilterService {
  static final SearchFilterService _instance = SearchFilterService._internal();
  final DatabaseService _db = DatabaseService();

  factory SearchFilterService() {
    return _instance;
  }

  SearchFilterService._internal();

  // Advanced search
  Future<List<ScanHistory>> advancedSearch({
    String? query,
    String? qrType,
    DateTime? fromDate,
    DateTime? toDate,
    bool? favoritesOnly,
    SortBy sortBy = SortBy.newest,
  }) async {
    List<ScanHistory> results = await _db.getScanHistory(limit: 10000);

    // Filter by query
    if (query != null && query.isNotEmpty) {
      results = results
          .where((scan) =>
              scan.qrCode.toLowerCase().contains(query.toLowerCase()) ||
              (scan.title?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (scan.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }

    // Filter by type
    if (qrType != null && qrType.isNotEmpty) {
      results = results.where((scan) => scan.qrType == qrType).toList();
    }

    // Filter by date range
    if (fromDate != null) {
      results = results
          .where((scan) => scan.scannedAt.isAfter(fromDate))
          .toList();
    }

    if (toDate != null) {
      results = results
          .where((scan) => scan.scannedAt.isBefore(toDate))
          .toList();
    }

    // Filter favorites
    if (favoritesOnly == true) {
      results = results.where((scan) => scan.isFavorite).toList();
    }

    // Sort
    results = _sortResults(results, sortBy);

    return results;
  }

  // Search by prefix
  Future<List<ScanHistory>> searchByPrefix(String prefix) async {
    final allScans = await _db.getScanHistory(limit: 10000);
    return allScans
        .where((scan) => scan.qrCode.toLowerCase().startsWith(prefix.toLowerCase()))
        .toList();
  }

  // Get frequency statistics
  Future<Map<String, int>> getFrequencyStats() async {
    final allScans = await _db.getScanHistory(limit: 10000);
    final stats = <String, int>{};

    for (var scan in allScans) {
      stats[scan.qrType] = (stats[scan.qrType] ?? 0) + 1;
    }

    return stats;
  }

  // Get trending items
  Future<List<ScanHistory>> getTrendingItems({int limit = 10}) async {
    final allScans = await _db.getScanHistory(limit: 10000);
    
    // Sort by access count and recent date
    allScans.sort((a, b) {
      final countCompare = b.accessCount.compareTo(a.accessCount);
      if (countCompare != 0) return countCompare;
      return b.scannedAt.compareTo(a.scannedAt);
    });

    return allScans.take(limit).toList();
  }

  // Get related items
  Future<List<ScanHistory>> getRelatedItems(String qrType, {int limit = 5}) async {
    final allScans = await _db.getScanHistory(limit: 10000);
    return allScans
        .where((scan) => scan.qrType == qrType)
        .take(limit)
        .toList();
  }

  // Autocomplete suggestions
  Future<List<String>> getAutocompleteSuggestions(String query) async {
    final allScans = await _db.getScanHistory(limit: 10000);
    final suggestions = <String>{};

    for (var scan in allScans) {
      if (scan.qrCode.toLowerCase().startsWith(query.toLowerCase())) {
        suggestions.add(scan.qrCode);
      }
      if (scan.title?.toLowerCase().startsWith(query.toLowerCase()) ?? false) {
        suggestions.add(scan.title!);
      }
    }

    return suggestions.toList()..sort();
  }

  List<ScanHistory> _sortResults(List<ScanHistory> results, SortBy sortBy) {
    switch (sortBy) {
      case SortBy.newest:
        results.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
        break;
      case SortBy.oldest:
        results.sort((a, b) => a.scannedAt.compareTo(b.scannedAt));
        break;
      case SortBy.mostAccessed:
        results.sort((a, b) => b.accessCount.compareTo(a.accessCount));
        break;
      case SortBy.alphabetical:
        results.sort((a, b) => a.qrCode.compareTo(b.qrCode));
        break;
    }
    return results;
  }
}

enum SortBy {
  newest,
  oldest,
  mostAccessed,
  alphabetical,
}
