import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/scan_history_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanHistoryProvider>().showFavoritesOnly();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              context.read<ScanHistoryProvider>().resetFilter();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Consumer<ScanHistoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.scanHistory.isEmpty) {
            return const Center(
              child: Text('No favorites yet'),
            );
          }

          return ListView.builder(
            itemCount: provider.scanHistory.length,
            itemBuilder: (context, index) {
              final scan = provider.scanHistory[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(scan.title ?? scan.qrCode),
                  subtitle: Text(scan.qrType),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite),
                    color: Colors.red,
                    onPressed: () async {
                      await provider.toggleFavorite(scan.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Removed from favorites'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
