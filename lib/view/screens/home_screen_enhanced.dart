import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/scan_history_provider.dart';
import '../../presentation/providers/user_profile_provider.dart';

class HomeScreenEnhanced extends StatefulWidget {
  const HomeScreenEnhanced({Key? key}) : super(key: key);

  @override
  State<HomeScreenEnhanced> createState() => _HomeScreenEnhancedState();
}

class _HomeScreenEnhancedState extends State<HomeScreenEnhanced> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanHistoryProvider>().loadScanHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FastGokdeniz'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(
              context,
              '/search-advanced',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(
              context,
              '/profile-detail',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/qr'),
        child: const Icon(Icons.qr_code),
      ),
      body: Consumer2<ScanHistoryProvider, UserProfileProvider>(
        builder: (context, scanProvider, profileProvider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Card
                if (profileProvider.profile != null)
                  _buildStatsCard(context, profileProvider),

                // Recent Scans
                _buildRecentScansSection(context, scanProvider),

                // Action Buttons
                _buildActionButtons(context),

                // Trending Items
                _buildTrendingSection(context),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/favorites');
              break;
            case 2:
              Navigator.pushNamed(context, '/history');
              break;
            case 3:
              Navigator.pushNamed(context, '/settings-advanced');
              break;
          }
        },
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    UserProfileProvider provider,
  ) {
    final profile = provider.profile!;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${profile.displayName}!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Scans', profile.totalScans),
                _buildStatItem('Favorites', profile.totalFavorites),
                _buildStatItem('Messages', profile.totalMessages),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentScansSection(
    BuildContext context,
    ScanHistoryProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Scans',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/history'),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        if (provider.isLoading)
          const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (provider.scanHistory.isEmpty)
          const SizedBox(
            height: 100,
            child: Center(
              child: Text('No scans yet. Start scanning!'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.scanHistory.take(5).length,
            itemBuilder: (context, index) {
              final scan = provider.scanHistory[index];
              return ListTile(
                leading: Icon(
                  _getIconForType(scan.qrType),
                ),
                title: Text(scan.title ?? scan.qrCode),
                subtitle: Text(scan.qrType),
                trailing: IconButton(
                  icon: Icon(
                    scan.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  color: Colors.red,
                  onPressed: () {
                    provider.toggleFavorite(scan.id);
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/qr'),
              icon: const Icon(Icons.qr_code),
              label: const Text('Scan'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/message'),
              icon: const Icon(Icons.message),
              label: const Text('Message'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Trending',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildTrendingCard('URL', Icons.link),
              _buildTrendingCard('Email', Icons.email),
              _buildTrendingCard('Phone', Icons.phone),
              _buildTrendingCard('WiFi', Icons.wifi),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCard(String label, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'EMAIL':
        return Icons.email;
      case 'PHONE':
        return Icons.phone;
      case 'WIFI':
        return Icons.wifi;
      default:
        return Icons.text_fields;
    }
  }
}
