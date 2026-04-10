import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/theme_provider.dart';
import '../../core/localization/app_strings.dart';

class LinkCreatorScreen extends StatefulWidget {
  const LinkCreatorScreen({super.key});

  @override
  State<LinkCreatorScreen> createState() => _LinkCreatorScreenState();
}

class _LinkCreatorScreenState extends State<LinkCreatorScreen> {
  String? _selectedFilePath;
  String? _selectedFileName;
  String? _downloadUrl;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.any);
      if (!mounted) return;
      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        if (pickedFile.path != null) {
          setState(() {
            _selectedFilePath = pickedFile.path;
            _selectedFileName = pickedFile.name;
            _downloadUrl = null;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dosya seçme hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final language = themeProvider.language;
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.get('linkCreator', language)),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickFile,
                  icon: const Icon(Icons.file_upload),
                  label: Text(AppStrings.get('selectFile', language)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedFileName != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('selectedFile', language),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(_selectedFileName!),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}