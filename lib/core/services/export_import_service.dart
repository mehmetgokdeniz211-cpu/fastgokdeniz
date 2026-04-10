import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../data/services/database_service.dart';
import '../../data/models/scan_history.dart';
import '../../data/models/saved_message.dart';

class ExportImportService {
  static final ExportImportService _instance = ExportImportService._internal();
  final DatabaseService _db = DatabaseService();

  factory ExportImportService() {
    return _instance;
  }

  ExportImportService._internal();

  // Export all data
  Future<String> exportAllData() async {
    final scanHistory = await _db.getScanHistory(limit: 10000);
    final messages = await _db.getSavedMessages();

    final exportData = {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'scanHistory': scanHistory
          .map((s) => {
                'qrCode': s.qrCode,
                'qrType': s.qrType,
                'scannedAt': s.scannedAt.toIso8601String(),
                'isFavorite': s.isFavorite,
                'accessCount': s.accessCount,
                'title': s.title,
                'description': s.description,
              })
          .toList(),
      'savedMessages': messages
          .map((m) => {
                'messageContent': m.messageContent,
                'createdAt': m.createdAt.toIso8601String(),
                'category': m.category,
                'isFavorite': m.isFavorite,
                'title': m.title,
                'usageCount': m.usageCount,
              })
          .toList(),
    };

    return jsonEncode(exportData);
  }

  // Export as JSON file
  Future<File> exportToFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'app_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$fileName');

    final jsonData = await exportAllData();
    await file.writeAsString(jsonData);

    return file;
  }

  // Import data
  Future<void> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;

      // Import scan history
      if (data['scanHistory'] is List) {
        for (var item in data['scanHistory']) {
          final scan = ScanHistory()
            ..qrCode = item['qrCode']
            ..qrType = item['qrType']
            ..scannedAt = DateTime.parse(item['scannedAt'])
            ..isFavorite = item['isFavorite'] ?? false
            ..accessCount = item['accessCount'] ?? 0
            ..title = item['title']
            ..description = item['description'];
          await _db.addScanHistory(scan);
        }
      }

      // Import messages
      if (data['savedMessages'] is List) {
        for (var item in data['savedMessages']) {
          final message = SavedMessage()
            ..messageContent = item['messageContent']
            ..createdAt = DateTime.parse(item['createdAt'])
            ..category = item['category']
            ..isFavorite = item['isFavorite'] ?? false
            ..title = item['title']
            ..usageCount = item['usageCount'] ?? 0;
          await _db.addSavedMessage(message);
        }
      }
    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }

  // Import from file
  Future<void> importFromFile(File file) async {
    try {
      final content = await file.readAsString();
      await importData(content);
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  // Export scan history only
  Future<String> exportScanHistory() async {
    final scanHistory = await _db.getScanHistory(limit: 10000);
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'scans': scanHistory
          .map((s) => {
                'qrCode': s.qrCode,
                'qrType': s.qrType,
                'scannedAt': s.scannedAt.toIso8601String(),
              })
          .toList(),
    };
    return jsonEncode(data);
  }

  // Export as CSV
  Future<String> exportAsCSV() async {
    final scanHistory = await _db.getScanHistory(limit: 10000);
    
    final buffer = StringBuffer();
    buffer.writeln('QR Code,Type,Scanned At,Is Favorite,Access Count');
    
    for (var scan in scanHistory) {
      buffer.writeln(
        '${_escapeCsv(scan.qrCode)},${scan.qrType},${scan.scannedAt},'
        '${scan.isFavorite},${scan.accessCount}',
      );
    }
    
    return buffer.toString();
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
