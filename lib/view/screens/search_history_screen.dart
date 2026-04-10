import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/app_storage_service.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../core/localization/app_strings.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  final _storageService = AppStorageService();
  late Future<List<String>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = _storageService.getSearchHistory();
    });
  }

  void _deleteItem(String item) async {
    await _storageService.removeSearchItem(item);
    _loadHistory();
  }

  void _clearAll() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final language = themeProvider.language;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.get('clearHistory', language)),
        content: Text(AppStrings.get('confirmClearHistory', language)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('cancel', language)),
          ),
          TextButton(
            onPressed: () async {
              await _storageService.clearSearchHistory();
              Navigator.pop(context);
              _loadHistory();
            },
            child: Text(AppStrings.get('delete', language), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final language = themeProvider.language;

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('searchHistory', language)),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAll,
              tooltip: AppStrings.get('clearHistory', language),
            ),
          ],
        ),
        body: SafeArea(
          child: FutureBuilder<List<String>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.get('searchHistoryEmpty', language),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final history = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(item),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _deleteItem(item),
                    ),
                    onTap: () {
                      Navigator.pop(context, item);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
