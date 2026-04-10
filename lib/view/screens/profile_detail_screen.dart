import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gokdeniz_scanner/data/models/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../presentation/providers/user_profile_provider.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  bool _isEditing = false;
  Uint8List? _selectedImageBytes;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// Profil resmi seç
  Future<void> _changeProfileImage() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Web üzerinde profil resmi değişikliği desteklenmiyor.',
            ),
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

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });

        if (mounted) {
          final profileProvider = context.read<UserProfileProvider>();
          await profileProvider.updateProfile(profileImageUrl: pickedFile.path);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil resmi güncellendi!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resim seçilirken hata oluştu: $e')),
        );
      }
    }
  }

  ImageProvider? _buildImageProvider(UserProfile profile) {
    if (_selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    }

    if (profile.profileImageUrl == null) {
      return null;
    }

    if (kIsWeb) {
      return NetworkImage(profile.profileImageUrl!);
    }

    if (profile.profileImageUrl!.startsWith('http')) {
      return NetworkImage(profile.profileImageUrl!);
    }

    return FileImage(File(profile.profileImageUrl!));
  }

  Future<void> _showExpandedImage(ImageProvider imageProvider) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image(image: imageProvider, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () async {
              if (_isEditing) {
                final profileProvider = context.read<UserProfileProvider>();
                if (profileProvider.profile != null) {
                  await profileProvider.updateProfile(
                    displayName: _displayNameController.text,
                    bio: _bioController.text,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated!')),
                    );
                  }
                }
              }
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, profileProvider, _) {
          final profile = profileProvider.profile;

          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }

          if (!_isEditing) {
            _displayNameController.text = profile.displayName;
            _bioController.text = profile.bio ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Picture - Tıklanabilir
                GestureDetector(
                  onTap: _changeProfileImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _buildImageProvider(profile),
                        child:
                            (_selectedImageBytes == null &&
                                profile.profileImageUrl == null)
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _changeProfileImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_isEditing)
                  TextField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                else
                  Text(
                    profile.displayName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                const SizedBox(height: 16),
                if (_isEditing)
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  )
                else
                  Text(profile.bio ?? 'No bio'),
                const SizedBox(height: 32),
                // Statistics
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  children: [
                    _buildStatCard('Scans', profile.totalScans.toString()),
                    _buildStatCard(
                      'Messages',
                      profile.totalMessages.toString(),
                    ),
                    _buildStatCard(
                      'Favorites',
                      profile.totalFavorites.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
