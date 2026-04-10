import 'package:flutter/material.dart';
import 'package:favicon/favicon.dart';
import '../../data/models/qr_model.dart';
import '../../data/services/app_storage_service.dart';
import '../../domain/generate_qr_use_case.dart';

class QRProvider with ChangeNotifier {
  final GenerateQRUseCase _generateQRUseCase;
  final AppStorageService _storageService = AppStorageService();

  QRProvider(this._generateQRUseCase);

  String _url = '';
  QRModel? _qrModel;
  String? _faviconUrl;
  bool _isLoadingFavicon = false;
  List<String> _createdQrHistory = [];

  List<String> get createdQrHistory => _createdQrHistory;

  String get url => _url;
  QRModel? get qrModel => _qrModel;
  String? get faviconUrl => _faviconUrl;
  bool get isLoadingFavicon => _isLoadingFavicon;

  Future<void> loadCreatedQrHistory() async {
    _createdQrHistory = await _storageService.getCreatedQrHistory();
    notifyListeners();
  }

  Future<void> _addCreatedQr(String url) async {
    if (url.isEmpty) return;
    await _storageService.addCreatedQr(url);
    _createdQrHistory = await _storageService.getCreatedQrHistory();
    notifyListeners();
  }

  void setUrl(String url) {
    _url = url;
    notifyListeners();
    _fetchFavicon(url);
  }

  Future<void> _fetchFavicon(String url) async {
    if (url.isEmpty) return;

    _isLoadingFavicon = true;
    notifyListeners();

    try {
      final favicon = await FaviconFinder.getBest(url);
      _faviconUrl = favicon?.url;
    } catch (e) {
      _faviconUrl = null;
    } finally {
      _isLoadingFavicon = false;
      notifyListeners();
    }
  }

  void generateQR() {
    _qrModel = _generateQRUseCase.execute(_url);
    notifyListeners();
    if (_url.isNotEmpty) {
      _addCreatedQr(_url);
    }
  }
}
