import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/export_import_service.dart';
import '../../core/services/notification_service.dart';
import '../../presentation/providers/authentication_provider.dart';

class SettingsAdvancedScreen extends StatefulWidget {
  const SettingsAdvancedScreen({Key? key}) : super(key: key);

  @override
  State<SettingsAdvancedScreen> createState() => _SettingsAdvancedScreenState();
}

class _SettingsAdvancedScreenState extends State<SettingsAdvancedScreen> {
  final _exportImportService = ExportImportService();
  final _notificationService = NotificationService();
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive alerts and updates'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              if (value) {
                await _notificationService.enableNotifications();
              } else {
                await _notificationService.disableNotifications();
              }
            },
          ),
          const Divider(),

          // Export
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Export all your data as JSON'),
            onTap: () async {
              try {
                final file = await _exportImportService.exportToFile();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to ${file.path}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Export failed: $e')),
                );
              }
            },
          ),

          // Export as CSV
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export as CSV'),
            subtitle: const Text('Export scan history as CSV file'),
            onTap: () async {
              try {
                await _exportImportService.exportAsCSV();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV exported!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Export failed: $e')),
                );
              }
            },
          ),

          // Import
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Import Data'),
            subtitle: const Text('Import previously exported data'),
            onTap: () {
              _showImportDialog();
            },
          ),
          const Divider(),

          // Logout
          Consumer<AuthenticationProvider>(
            builder: (context, authProvider, _) {
              return ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout?'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await authProvider.logout();
                            if (mounted) {
                              Navigator.of(context)
                                  .pushReplacementNamed('/splash');
                            }
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    final importController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: TextField(
          controller: importController,
          decoration: const InputDecoration(
            labelText: 'Paste JSON data',
            hintText: 'Enter exported JSON',
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _exportImportService.importData(importController.text);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data imported successfully!')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Import failed: $e')),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}
