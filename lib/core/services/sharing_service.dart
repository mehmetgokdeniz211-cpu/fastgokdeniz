import 'package:share_plus/share_plus.dart';

class SharingService {
  static final SharingService _instance = SharingService._internal();

  factory SharingService() {
    return _instance;
  }

  SharingService._internal();

  // Share QR Code
  Future<void> shareQRCode({
    required String qrData,
    required String subject,
  }) async {
    await Share.share(
      qrData,
      subject: subject,
    );
  }

  // Share Text
  Future<void> shareText({
    required String text,
    String? subject,
  }) async {
    await Share.share(
      text,
      subject: subject,
    );
  }

  // Share File
  Future<void> shareFile({
    required String filePath,
    required String mimeType,
    String? subject,
  }) async {
    await Share.shareXFiles(
      [XFile(filePath, mimeType: mimeType)],
      subject: subject,
    );
  }

  // Share multiple files
  Future<void> shareMultipleFiles({
    required List<String> filePaths,
    String? subject,
  }) async {
    final xFiles = filePaths
        .map((path) => XFile(path))
        .toList();
    
    await Share.shareXFiles(
      xFiles,
      subject: subject,
    );
  }

  // Share URL
  Future<void> shareUrl({
    required String url,
    required String title,
    String? subject,
  }) async {
    await Share.share(
      '$title\n$url',
      subject: subject,
    );
  }

  // Export data as text
  Future<void> exportAsText({
    required String data,
    required String filename,
  }) async {
    await Share.share(
      data,
      subject: filename,
    );
  }
}
