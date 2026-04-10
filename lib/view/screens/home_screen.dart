import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' hide Barcode, BarcodeFormat;
import 'package:provider/provider.dart';

import '../../core/navigation/navigation_service.dart';
import '../../core/enums/message_type.dart';
import '../../core/localization/app_strings.dart';
import '../../core/services/app_launcher_service.dart';
import '../../presentation/providers/qr_scanner_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../data/services/app_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MobileScannerController controller;
  bool _showScanner = false;
  final _storageService = AppStorageService();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      controller = MobileScannerController();
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Galeriden QR kod resmi seç
  Future<void> _pickAndCropImageFromGallery() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Web üzerinde QR resmi seçme desteklenmiyor.'),
          ),
        );
      }
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile != null && mounted) {
        final provider = Provider.of<QRScannerProvider>(context, listen: false);
        await _processLocalQRImage(pickedFile.path, provider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Galeri açılırken hata: $e')));
      }
    }
  }

  /// Kameradan QR kod resmi çek
  Future<void> _takeAndCropPhotoFromCamera() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Web üzerinde kamera ile QR seçme desteklenmiyor.'),
          ),
        );
      }
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (pickedFile != null && mounted) {
        final provider = Provider.of<QRScannerProvider>(context, listen: false);
        await _processLocalQRImage(pickedFile.path, provider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kamera açılırken hata: $e')));
      }
    }
  }

  /// Yerel QR resmini işle (QR kodu oku)
  Future<void> _processLocalQRImage(
    String imagePath,
    QRScannerProvider provider,
  ) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
      final barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();

      if (barcodes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bu resimde QR kod bulunamadı.')),
          );
        }
        return;
      }

      final barcode = barcodes.first;
      final code = barcode.rawValue ?? barcode.displayValue ?? '';
      if (code.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR kod okundu, ancak içerik bulunamadı.'),
            ),
          );
        }
        return;
      }

      await provider.handleScannedCode(code);
      if (mounted) {
        final themeProvider = Provider.of<ThemeProvider>(
          context,
          listen: false,
        );
        _showQRActionDialog(context, code, provider, themeProvider.language);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR işlenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showQRActionDialog(
    BuildContext context,
    String code,
    QRScannerProvider provider,
    String language,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('QR Kod Tarandı'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kod: ${code.length > 50 ? '${code.substring(0, 50)}...' : code}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text('Ne yapmak istiyorsunuz?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          if (!code.startsWith('http://') && !code.startsWith('https://'))
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await provider.openWhatsApp(code);
                  await _storageService.addSearchHistory('QR: $code');
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('WhatsApp hatası: $e')),
                    );
                  }
                }
              },
              child: const Text('WhatsApp'),
            ),
          if (!code.startsWith('http://') && !code.startsWith('https://'))
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await provider.openSMS(code);
                  await _storageService.addSearchHistory('QR: $code');
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('SMS hatası: $e')));
                  }
                }
              },
              child: const Text('SMS'),
            ),
          if (!code.startsWith('http://') && !code.startsWith('https://'))
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await provider.openPhoneCall(code);
                  await _storageService.addSearchHistory('QR: $code');
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Ara hatası: $e')));
                  }
                }
              },
              child: const Text('Ara'),
            ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Telefon numarası ise WhatsApp yap, URL ise web aç
                if (code.startsWith('http://') || code.startsWith('https://')) {
                  await provider.launchWebURL(code);
                } else {
                  await provider.openWhatsApp(code);
                }
                await _storageService.addSearchHistory('QR: $code');
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                }
              }
            },
            child: const Text('Hızlı Aç'),
          ),
        ],
      ),
    );
  }

  void _showWhatsAppDialog(BuildContext context, String language) {
    String selectedCountry = 'TR';

    // Ülke kodları ve bilgileri
    final Map<String, Map<String, String>> countryData = {
      'AR': {
        'flag': '🇦🇷',
        'code': '+54',
        'name': 'Argentina',
        'example': '11 2345-6789',
      },
      'AT': {
        'flag': '🇦🇹',
        'code': '+43',
        'name': 'Österreich',
        'example': '0664 12345678',
      },
      'AU': {
        'flag': '🇦🇺',
        'code': '+61',
        'name': 'Australia',
        'example': '0412 345 678',
      },
      'AE': {
        'flag': '🇦🇪',
        'code': '+971',
        'name': 'الإمارات',
        'example': '50 123 4567',
      },
      'BD': {
        'flag': '🇧🇩',
        'code': '+880',
        'name': 'Bangladesh',
        'example': '01712 345678',
      },
      'BE': {
        'flag': '🇧🇪',
        'code': '+32',
        'name': 'Belgique',
        'example': '0471 23 45 67',
      },
      'BR': {
        'flag': '🇧🇷',
        'code': '+55',
        'name': 'Brasil',
        'example': '(11) 91234-5678',
      },
      'CA': {
        'flag': '🇨🇦',
        'code': '+1',
        'name': 'Canada',
        'example': '(416) 123-4567',
      },
      'CI': {
        'flag': '🇨🇮',
        'code': '+225',
        'name': 'Côte d\'Ivoire',
        'example': '01 02 03 04 05',
      },
      'CH': {
        'flag': '🇨🇭',
        'code': '+41',
        'name': 'Schweiz',
        'example': '079 123 45 67',
      },
      'CL': {
        'flag': '🇨🇱',
        'code': '+56',
        'name': 'Chile',
        'example': '9 1234 5678',
      },
      'CN': {
        'flag': '🇨🇳',
        'code': '+86',
        'name': '中国',
        'example': '138 0013 8000',
      },
      'CO': {
        'flag': '🇨🇴',
        'code': '+57',
        'name': 'Colombia',
        'example': '300 1234567',
      },
      'CZ': {
        'flag': '🇨🇿',
        'code': '+420',
        'name': 'Česká republika',
        'example': '723 456 789',
      },
      'DE': {
        'flag': '🇩🇪',
        'code': '+49',
        'name': 'Deutschland',
        'example': '151 12345678',
      },
      'DK': {
        'flag': '🇩🇰',
        'code': '+45',
        'name': 'Danmark',
        'example': '20 12 34 56',
      },
      'EG': {
        'flag': '🇪🇬',
        'code': '+20',
        'name': 'مصر',
        'example': '10 123 4567',
      },
      'ES': {
        'flag': '🇪🇸',
        'code': '+34',
        'name': 'España',
        'example': '612 345 678',
      },
      'FI': {
        'flag': '🇫🇮',
        'code': '+358',
        'name': 'Suomi',
        'example': '040 123 4567',
      },
      'FR': {
        'flag': '🇫🇷',
        'code': '+33',
        'name': 'France',
        'example': '06 12 34 56 78',
      },
      'GR': {
        'flag': '🇬🇷',
        'code': '+30',
        'name': 'Ελλάδα',
        'example': '691 234 5678',
      },
      'HR': {
        'flag': '🇭🇷',
        'code': '+385',
        'name': 'Hrvatska',
        'example': '091 234 5678',
      },
      'HU': {
        'flag': '🇭🇺',
        'code': '+36',
        'name': 'Magyarország',
        'example': '20 123 4567',
      },
      'ID': {
        'flag': '🇮🇩',
        'code': '+62',
        'name': 'Indonesia',
        'example': '0812 3456 789',
      },
      'IL': {
        'flag': '🇮🇱',
        'code': '+972',
        'name': 'ישראל',
        'example': '054 234 5678',
      },
      'IN': {
        'flag': '🇮🇳',
        'code': '+91',
        'name': 'India',
        'example': '98765 43210',
      },
      'IR': {
        'flag': '🇮🇷',
        'code': '+98',
        'name': 'ایران',
        'example': '912 345 6789',
      },
      'IT': {
        'flag': '🇮🇹',
        'code': '+39',
        'name': 'Italia',
        'example': '312 345 6789',
      },
      'JP': {
        'flag': '🇯🇵',
        'code': '+81',
        'name': '日本',
        'example': '090 1234 5678',
      },
      'KE': {
        'flag': '🇰🇪',
        'code': '+254',
        'name': 'Kenya',
        'example': '0712 345678',
      },
      'KR': {
        'flag': '🇰🇷',
        'code': '+82',
        'name': '한국',
        'example': '010-1234-5678',
      },
      'MX': {
        'flag': '🇲🇽',
        'code': '+52',
        'name': 'México',
        'example': '55 1234 5678',
      },
      'MY': {
        'flag': '🇲🇾',
        'code': '+60',
        'name': 'Malaysia',
        'example': '012 345 6789',
      },
      'NG': {
        'flag': '🇳🇬',
        'code': '+234',
        'name': 'Nigeria',
        'example': '0803 123 4567',
      },
      'NL': {
        'flag': '🇳🇱',
        'code': '+31',
        'name': 'Nederland',
        'example': '06 12345678',
      },
      'NO': {
        'flag': '🇳🇴',
        'code': '+47',
        'name': 'Norge',
        'example': '412 34 567',
      },
      'NZ': {
        'flag': '🇳🇿',
        'code': '+64',
        'name': 'New Zealand',
        'example': '021 123 4567',
      },
      'PE': {
        'flag': '🇵🇪',
        'code': '+51',
        'name': 'Perú',
        'example': '987 654 321',
      },
      'PH': {
        'flag': '🇵🇭',
        'code': '+63',
        'name': 'Philippines',
        'example': '0917 123 4567',
      },
      'PK': {
        'flag': '🇵🇰',
        'code': '+92',
        'name': 'Pakistan',
        'example': '300 1234567',
      },
      'PL': {
        'flag': '🇵🇱',
        'code': '+48',
        'name': 'Polska',
        'example': '512 345 678',
      },
      'PT': {
        'flag': '🇵🇹',
        'code': '+351',
        'name': 'Portugal',
        'example': '917 123 456',
      },
      'RO': {
        'flag': '🇷🇴',
        'code': '+40',
        'name': 'România',
        'example': '0721 234 567',
      },
      'RU': {
        'flag': '🇷🇺',
        'code': '+7',
        'name': 'Россия',
        'example': '912 345-67-89',
      },
      'SA': {
        'flag': '🇸🇦',
        'code': '+966',
        'name': 'المملكة',
        'example': '50 123 4567',
      },
      'SE': {
        'flag': '🇸🇪',
        'code': '+46',
        'name': 'Sverige',
        'example': '070 123 45 67',
      },
      'SG': {
        'flag': '🇸🇬',
        'code': '+65',
        'name': 'Singapore',
        'example': '8123 4567',
      },
      'SK': {
        'flag': '🇸🇰',
        'code': '+421',
        'name': 'Slovensko',
        'example': '0940 123 456',
      },
      'TH': {
        'flag': '🇹🇭',
        'code': '+66',
        'name': 'ไทย',
        'example': '081 234 5678',
      },
      'TR': {
        'flag': '🇹🇷',
        'code': '+90',
        'name': 'Türkiye',
        'example': '555 123 45 67',
      },
      'TW': {
        'flag': '🇹🇼',
        'code': '+886',
        'name': '台灣',
        'example': '0912 345 678',
      },
      'UA': {
        'flag': '🇺🇦',
        'code': '+380',
        'name': 'Україна',
        'example': '050 123 45 67',
      },
      'UK': {
        'flag': '🇬🇧',
        'code': '+44',
        'name': 'United Kingdom',
        'example': '07123 456789',
      },
      'US': {
        'flag': '🇺🇸',
        'code': '+1',
        'name': 'United States',
        'example': '(555) 123-4567',
      },
      'VN': {
        'flag': '🇻🇳',
        'code': '+84',
        'name': 'Việt Nam',
        'example': '091 234 5678',
      },
      'ZA': {
        'flag': '🇿🇦',
        'code': '+27',
        'name': 'South Africa',
        'example': '071 123 4567',
      },
    };

    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('WhatsApp'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: countryData[selectedCountry]!['example'],
                    labelText: AppStrings.get('enterPhoneNumber', language),
                    prefix: SizedBox(
                      width: 110,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCountry,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, size: 24),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          dropdownColor: Colors.white,
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                selectedCountry = value;
                              });
                            }
                          },
                          items: countryData.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                '${entry.value['flag']} ${entry.value['code']}',
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.get('cancel', language)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen telefon numarası girin'),
                      ),
                    );
                    return;
                  }

                  if (!mounted) return;
                  final provider = Provider.of<QRScannerProvider>(
                    context,
                    listen: false,
                  );

                  // Add to search history
                  await _storageService.addSearchHistory(
                    'WHATSAPP: ${phoneController.text}',
                  );

                  // Call openWhatsApp with country code
                  await provider.openWhatsApp(
                    phoneController.text,
                    countryCode: selectedCountry,
                  );

                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppStrings.get('error', language)} $e',
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(AppStrings.get('send', language)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSmsDialog(BuildContext context, String language) {
    String selectedCountry = 'TR';

    final Map<String, Map<String, String>> countryData = {
      'AR': {
        'flag': '🇦🇷',
        'code': '+54',
        'name': 'Argentina',
        'example': '11 2345-6789',
      },
      'AT': {
        'flag': '🇦🇹',
        'code': '+43',
        'name': 'Österreich',
        'example': '0664 12345678',
      },
      'AU': {
        'flag': '🇦🇺',
        'code': '+61',
        'name': 'Australia',
        'example': '0412 345 678',
      },
      'AE': {
        'flag': '🇦🇪',
        'code': '+971',
        'name': 'الإمارات',
        'example': '50 123 4567',
      },
      'BD': {
        'flag': '🇧🇩',
        'code': '+880',
        'name': 'Bangladesh',
        'example': '01712 345678',
      },
      'BE': {
        'flag': '🇧🇪',
        'code': '+32',
        'name': 'Belgique',
        'example': '0471 23 45 67',
      },
      'BR': {
        'flag': '🇧🇷',
        'code': '+55',
        'name': 'Brasil',
        'example': '(11) 91234-5678',
      },
      'CA': {
        'flag': '🇨🇦',
        'code': '+1',
        'name': 'Canada',
        'example': '(416) 123-4567',
      },
      'CI': {
        'flag': '🇨🇮',
        'code': '+225',
        'name': 'Côte d\'Ivoire',
        'example': '01 02 03 04 05',
      },
      'CH': {
        'flag': '🇨🇭',
        'code': '+41',
        'name': 'Schweiz',
        'example': '079 123 45 67',
      },
      'CL': {
        'flag': '🇨🇱',
        'code': '+56',
        'name': 'Chile',
        'example': '9 1234 5678',
      },
      'CN': {
        'flag': '🇨🇳',
        'code': '+86',
        'name': '中国',
        'example': '138 0013 8000',
      },
      'CO': {
        'flag': '🇨🇴',
        'code': '+57',
        'name': 'Colombia',
        'example': '300 1234567',
      },
      'CZ': {
        'flag': '🇨🇿',
        'code': '+420',
        'name': 'Česká republika',
        'example': '723 456 789',
      },
      'DE': {
        'flag': '🇩🇪',
        'code': '+49',
        'name': 'Deutschland',
        'example': '151 12345678',
      },
      'DK': {
        'flag': '🇩🇰',
        'code': '+45',
        'name': 'Danmark',
        'example': '20 12 34 56',
      },
      'EG': {
        'flag': '🇪🇬',
        'code': '+20',
        'name': 'مصر',
        'example': '10 123 4567',
      },
      'ES': {
        'flag': '🇪🇸',
        'code': '+34',
        'name': 'España',
        'example': '612 345 678',
      },
      'FI': {
        'flag': '🇫🇮',
        'code': '+358',
        'name': 'Suomi',
        'example': '040 123 4567',
      },
      'FR': {
        'flag': '🇫🇷',
        'code': '+33',
        'name': 'France',
        'example': '06 12 34 56 78',
      },
      'GR': {
        'flag': '🇬🇷',
        'code': '+30',
        'name': 'Ελλάδα',
        'example': '691 234 5678',
      },
      'HR': {
        'flag': '🇭🇷',
        'code': '+385',
        'name': 'Hrvatska',
        'example': '091 234 5678',
      },
      'HU': {
        'flag': '🇭🇺',
        'code': '+36',
        'name': 'Magyarország',
        'example': '20 123 4567',
      },
      'ID': {
        'flag': '🇮🇩',
        'code': '+62',
        'name': 'Indonesia',
        'example': '0812 3456 789',
      },
      'IL': {
        'flag': '🇮🇱',
        'code': '+972',
        'name': 'ישראל',
        'example': '054 234 5678',
      },
      'IN': {
        'flag': '🇮🇳',
        'code': '+91',
        'name': 'India',
        'example': '98765 43210',
      },
      'IR': {
        'flag': '🇮🇷',
        'code': '+98',
        'name': 'ایران',
        'example': '912 345 6789',
      },
      'IT': {
        'flag': '🇮🇹',
        'code': '+39',
        'name': 'Italia',
        'example': '312 345 6789',
      },
      'JP': {
        'flag': '🇯🇵',
        'code': '+81',
        'name': '日本',
        'example': '090 1234 5678',
      },
      'KE': {
        'flag': '🇰🇪',
        'code': '+254',
        'name': 'Kenya',
        'example': '0712 345678',
      },
      'KR': {
        'flag': '🇰🇷',
        'code': '+82',
        'name': '한국',
        'example': '010-1234-5678',
      },
      'MX': {
        'flag': '🇲🇽',
        'code': '+52',
        'name': 'México',
        'example': '55 1234 5678',
      },
      'MY': {
        'flag': '🇲🇾',
        'code': '+60',
        'name': 'Malaysia',
        'example': '012 345 6789',
      },
      'NG': {
        'flag': '🇳🇬',
        'code': '+234',
        'name': 'Nigeria',
        'example': '0803 123 4567',
      },
      'NL': {
        'flag': '🇳🇱',
        'code': '+31',
        'name': 'Nederland',
        'example': '06 12345678',
      },
      'NO': {
        'flag': '🇳🇴',
        'code': '+47',
        'name': 'Norge',
        'example': '412 34 567',
      },
      'NZ': {
        'flag': '🇳🇿',
        'code': '+64',
        'name': 'New Zealand',
        'example': '021 123 4567',
      },
      'PE': {
        'flag': '🇵🇪',
        'code': '+51',
        'name': 'Perú',
        'example': '987 654 321',
      },
      'PH': {
        'flag': '🇵🇭',
        'code': '+63',
        'name': 'Philippines',
        'example': '0917 123 4567',
      },
      'PK': {
        'flag': '🇵🇰',
        'code': '+92',
        'name': 'Pakistan',
        'example': '300 1234567',
      },
      'PL': {
        'flag': '🇵🇱',
        'code': '+48',
        'name': 'Polska',
        'example': '512 345 678',
      },
      'PT': {
        'flag': '🇵🇹',
        'code': '+351',
        'name': 'Portugal',
        'example': '917 123 456',
      },
      'RO': {
        'flag': '🇷🇴',
        'code': '+40',
        'name': 'România',
        'example': '0721 234 567',
      },
      'RU': {
        'flag': '🇷🇺',
        'code': '+7',
        'name': 'Россия',
        'example': '912 345-67-89',
      },
      'SA': {
        'flag': '🇸🇦',
        'code': '+966',
        'name': 'المملكة',
        'example': '50 123 4567',
      },
      'SE': {
        'flag': '🇸🇪',
        'code': '+46',
        'name': 'Sverige',
        'example': '070 123 45 67',
      },
      'SG': {
        'flag': '🇸🇬',
        'code': '+65',
        'name': 'Singapore',
        'example': '8123 4567',
      },
      'SK': {
        'flag': '🇸🇰',
        'code': '+421',
        'name': 'Slovensko',
        'example': '0940 123 456',
      },
      'TH': {
        'flag': '🇹🇭',
        'code': '+66',
        'name': 'ไทย',
        'example': '081 234 5678',
      },
      'TR': {
        'flag': '🇹🇷',
        'code': '+90',
        'name': 'Türkiye',
        'example': '555 123 45 67',
      },
      'TW': {
        'flag': '🇹🇼',
        'code': '+886',
        'name': '台灣',
        'example': '0912 345 678',
      },
      'UA': {
        'flag': '🇺🇦',
        'code': '+380',
        'name': 'Україна',
        'example': '050 123 45 67',
      },
      'UK': {
        'flag': '🇬🇧',
        'code': '+44',
        'name': 'United Kingdom',
        'example': '07123 456789',
      },
      'US': {
        'flag': '🇺🇸',
        'code': '+1',
        'name': 'United States',
        'example': '(555) 123-4567',
      },
      'VN': {
        'flag': '🇻🇳',
        'code': '+84',
        'name': 'Việt Nam',
        'example': '091 234 5678',
      },
      'ZA': {
        'flag': '🇿🇦',
        'code': '+27',
        'name': 'South Africa',
        'example': '071 123 4567',
      },
    };

    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('SMS'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintText: countryData[selectedCountry]!['example'],
                    labelText: AppStrings.get('enterPhoneNumber', language),
                    prefix: SizedBox(
                      width: 110,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCountry,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, size: 24),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          dropdownColor: Colors.white,
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                selectedCountry = value;
                              });
                            }
                          },
                          items: countryData.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                '${entry.value['flag']} ${entry.value['code']}',
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.get('cancel', language)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (phoneController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lütfen telefon numarası girin'),
                      ),
                    );
                    return;
                  }

                  if (!mounted) return;
                  final provider = Provider.of<QRScannerProvider>(
                    context,
                    listen: false,
                  );
                  String rawNumber = phoneController.text.replaceAll(
                    RegExp(r'[^0-9]'),
                    '',
                  );
                  if (rawNumber.startsWith('0')) {
                    rawNumber = rawNumber.substring(1);
                  }
                  final fullPhone =
                      '${countryData[selectedCountry]!['code']}$rawNumber';

                  await _storageService.addSearchHistory('SMS: $fullPhone');
                  await provider.openSMS(fullPhone);

                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppStrings.get('error', language)} $e',
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text(AppStrings.get('send', language)),
            ),
          ],
        ),
      ),
    );
  }

  void _showInputDialog(
    BuildContext context,
    MessageType type,
    String language,
  ) {
    String hint = '';
    String label = '';
    String title = '';

    switch (type) {
      case MessageType.whatsapp:
        _showWhatsAppDialog(context, language);
        return;
      case MessageType.instagram:
        hint = '@username';
        label = AppStrings.get('enterUsername', language);
        title = 'Instagram';
        break;
      case MessageType.x:
        hint = '@username';
        label = AppStrings.get('enterUsername', language);
        title = 'X (Twitter)';
        break;
      case MessageType.discord:
        hint = '123456789';
        label = AppStrings.get('enterDiscordID', language);
        title = 'Discord';
        break;
      case MessageType.email:
        hint = 'user@example.com';
        label = AppStrings.get('enterEmail', language);
        title = 'Email';
        break;
      case MessageType.sms:
        _showSmsDialog(context, language);
        return;
      case MessageType.facebook:
        hint = 'page_username';
        label = AppStrings.get('enterUsername', language);
        title = 'Facebook';
        break;
      case MessageType.youtube:
        hint = '@channel_username';
        label = AppStrings.get('enterUsername', language);
        title = 'YouTube';
        break;
      case MessageType.telegram:
        hint = '@username';
        label = AppStrings.get('enterUsername', language);
        title = 'Telegram';
        break;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$title - $label'),
        content: TextField(
          decoration: InputDecoration(hintText: hint, labelText: label),
          onSubmitted: (value) async {
            try {
              if (!mounted) return;
              final provider = Provider.of<QRScannerProvider>(
                context,
                listen: false,
              );

              // Add to search history
              await _storageService.addSearchHistory(
                '${type.name.toUpperCase()}: $value',
              );

              switch (type) {
                case MessageType.whatsapp:
                  await provider.openWhatsApp(value);
                  break;
                case MessageType.instagram:
                  await provider.openInstagram(value);
                  break;
                case MessageType.x:
                  await provider.openX(value);
                  break;
                case MessageType.discord:
                  await provider.openDiscord(value);
                  break;
                case MessageType.email:
                  await provider.openEmail(value);
                  break;
                case MessageType.sms:
                  await provider.openSMS(value);
                  break;
                case MessageType.facebook:
                  await provider.openFacebook(value);
                  break;
                case MessageType.youtube:
                  await provider.openYouTube(value);
                  break;
                case MessageType.telegram:
                  await provider.openTelegram(value);
                  break;
              }

              if (mounted) Navigator.pop(context);
            } catch (e) {
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${AppStrings.get('error', language)} $e'),
                  ),
                );
              }
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('cancel', language)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformButton(
    BuildContext context, {
    required MessageType type,
    required String label,
    required IconData? icon,
    required Color color,
    Widget? customIcon,
    required String language,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showInputDialog(context, type, language),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color.withOpacity(1.0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customIcon ?? Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QRScannerProvider>(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final language = themeProvider.language;

        return PopScope(
          canPop: true,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'FastGokdeniz',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
              elevation: 8,
              shadowColor: Colors.blue.withOpacity(0.3),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: AppStrings.get('searchHistory', language),
                  onPressed: () => Navigator.of(context).pushNamed('/history'),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_2),
                  tooltip: AppStrings.get('createQR', language),
                  onPressed: () => NavigationService.navigateTo('/qr'),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: AppStrings.get('settings', language),
                  onPressed: () => Navigator.of(context).pushNamed('/settings'),
                ),
              ],
            ),
            body: SafeArea(
              child: _showScanner
                  ? Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.blue.shade400,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: kIsWeb
                                ? Center(
                                    child: Text(
                                      AppStrings.get(
                                        'cameraNotSupported',
                                        'tr',
                                      ),
                                    ),
                                  )
                                : MobileScanner(
                                    controller: controller,
                                    onDetect: (capture) {
                                      final barcodes = capture.barcodes;
                                      for (final barcode in barcodes) {
                                        final String? rawValue =
                                            barcode.rawValue;
                                        if (rawValue != null && mounted) {
                                          provider.handleScannedCode(rawValue);
                                        }
                                      }
                                    },
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showScanner = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade400,
                              ),
                              child: Text(AppStrings.get('close', language)),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hızlı Bağlantı Başlığı
                            Text(
                              AppStrings.get('quickConnect', language),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Hızlı Bağlantı Seçenekleri - QR ve Galeri
                            Row(
                              children: [
                                // QR Tarama
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showScanner = true;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade600,
                                            Colors.blue.shade800,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.qr_code_scanner,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            AppStrings.get('scanQR', language),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Galeriden Seç
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _pickAndCropImageFromGallery,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.purple.shade600,
                                            Colors.purple.shade800,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.purple.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.image,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            AppStrings.get('gallery', language),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Sosyal Medya Sekmesi
                            Text(
                              AppStrings.get('socialMedia', language),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Platform Buttons Grid
                            SizedBox(
                              height: 120,
                              child: Row(
                                children: [
                                  _buildPlatformButton(
                                    context,
                                    type: MessageType.whatsapp,
                                    label: AppStrings.get('whatsapp', language),
                                    icon: Icons.chat,
                                    color: const Color(0xFF25D366),
                                    language: language,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildPlatformButton(
                                    context,
                                    type: MessageType.instagram,
                                    label: AppStrings.get(
                                      'instagram',
                                      language,
                                    ),
                                    icon: Icons.camera_alt,
                                    color: const Color(0xFFE1306C),
                                    language: language,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildPlatformButton(
                                    context,
                                    type: MessageType.x,
                                    label: AppStrings.get('x', language),
                                    icon: null,
                                    color: const Color(0xFF000000),
                                    customIcon: const Text(
                                      'X',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    language: language,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: Row(
                                children: [
                                  _buildPlatformButton(
                                    context,
                                    type: MessageType.discord,
                                    label: AppStrings.get('discord', language),
                                    icon: Icons.people,
                                    color: const Color(0xFF5865F2),
                                    language: language,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildPlatformButton(
                                    context,
                                    type: MessageType.email,
                                    label: AppStrings.get('email', language),
                                    icon: Icons.mail,
                                    color: const Color(0xFFD44638),
                                    language: language,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildPlatformButton(
                                    context,
                                    type: MessageType.sms,
                                    label: AppStrings.get('sms', language),
                                    icon: Icons.sms,
                                    color: const Color(0xFF34B7F1),
                                    language: language,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: Row(
                                children: [
                                  _buildPlatformButton(
                                    context,
                                    type: MessageType.telegram,
                                    label: AppStrings.get('telegram', language),
                                    icon: Icons.send,
                                    color: const Color(0xFF0088cc),
                                    language: language,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildPlatformButton(
                                    context,
                                    type: MessageType.facebook,
                                    label: AppStrings.get('facebook', language),
                                    icon: Icons.group,
                                    color: const Color(0xFF1877F2),
                                    language: language,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildPlatformButton(
                                    context,
                                    type: MessageType.youtube,
                                    label: AppStrings.get('youtube', language),
                                    icon: Icons.play_circle,
                                    color: const Color(0xFFFF0000),
                                    language: language,
                                  ),
                                ],
                              ),
                            ),
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
