import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;

import '../../presentation/providers/qr_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../core/localization/app_strings.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  late TextEditingController _urlController;
  final GlobalKey _qrImageKey = GlobalKey();
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<QRProvider>(context, listen: false);
      final route = ModalRoute.of(context);
      await provider.loadCreatedQrHistory();

      if (!mounted) return;
      final url = route?.settings.arguments as String?;
      if (url != null) {
        _urlController.text = url;
        provider.setUrl(url);
        provider.generateQR();
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _captureQrImage() async {
    try {
      final boundary =
          _qrImageKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.any);
      if (!mounted) return;
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _selectedFileName = file.name;
          });
          _urlController.text = file.path!;
          final provider = Provider.of<QRProvider>(context, listen: false);
          provider.setUrl(file.path!);
          provider.generateQR();
        }
      }
    } catch (e) {
      if (!mounted) return;
      final language = Provider.of<ThemeProvider>(context, listen: false).language;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.get('fileSelectError', language)} $e')),
      );
    }
  }

  Future<void> _shareQrPng() async {
    final bytes = await _captureQrImage();
    if (!mounted) return;
    if (bytes == null) {
      final language = Provider.of<ThemeProvider>(context, listen: false).language;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('qrImageError', language))),
      );
      return;
    }

    if (kIsWeb) {
      final language = Provider.of<ThemeProvider>(context, listen: false).language;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('webShareNotSupported', language)),
        ),
      );
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final file = File(path.join(tempDir.path, 'qr_code.png'));
    await file.writeAsBytes(bytes);
    final language = Provider.of<ThemeProvider>(context, listen: false).language;
    await Share.shareXFiles([XFile(file.path)], text: AppStrings.get('qrShareText', language));
  }

  void _copyToClipboard(String text) {
    final language = Provider.of<ThemeProvider>(context, listen: false).language;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('urlCopied', language)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QRProvider>(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final language = themeProvider.language;

        return PopScope(
          canPop: true,
          child: Scaffold(
            appBar: AppBar(
              title: Text(AppStrings.get('createQR', language)),
              centerTitle: true,
              elevation: 0,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('enterURLTitle', language),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('urlExample', language),
                          prefixIcon: const Icon(Icons.link),
                          hintText: AppStrings.get('urlHint', language),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                        onChanged: provider.setUrl,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: provider.generateQR,
                          child: Text(
                            AppStrings.get('createQR', language),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (provider.qrModel != null) ...[
                        Text(
                          AppStrings.get('yourQR', language),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade50, Colors.purple.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.blue.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: RepaintBoundary(
                                  key: _qrImageKey,
                                  child: QrImageView(
                                    data: provider.qrModel!.url,
                                    version: QrVersions.auto,
                                    size: 280.0,
                                    embeddedImage: provider.faviconUrl != null
                                        ? NetworkImage(provider.faviconUrl!)
                                        : null,
                                    embeddedImageStyle: const QrEmbeddedImageStyle(
                                      size: Size(50, 50),
                                    ),
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () =>
                                    _copyToClipboard(provider.qrModel!.url),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          provider.qrModel!.url,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.copy,
                                        size: 16,
                                        color: Colors.blue.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (provider.isLoadingFavicon) ...[
                                const SizedBox(height: 16),
                                const CircularProgressIndicator(),
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.get('loadingFavicon', language),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _copyToClipboard(provider.qrModel!.url);
                                },
                                icon: const Icon(Icons.copy),
                                label: Text(AppStrings.get('copy', language)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _shareQrPng,
                                icon: const Icon(Icons.share),
                                label: Text(AppStrings.get('sharePNG', language)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ] else ...[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.qr_code_2,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppStrings.get('enterQRUrl', language),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (provider.createdQrHistory.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          AppStrings.get('createdQrHistory', language),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: provider.createdQrHistory.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = provider.createdQrHistory[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(AppStrings.get('tapToReload', language)),
                              leading: const Icon(Icons.history),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                _urlController.text = item;
                                provider.setUrl(item);
                                provider.generateQR();
                              },
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
