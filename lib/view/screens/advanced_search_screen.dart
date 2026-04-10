import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/scan_history_provider.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedType;
  DateTimeRange? _selectedDate;

  final qrTypes = ['URL', 'TEXT', 'EMAIL', 'PHONE', 'WIFI'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Search')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  context.read<ScanHistoryProvider>().searchScans(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Type filter
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: qrTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedType = value);
                if (value != null) {
                  context.read<ScanHistoryProvider>().filterByType(value);
                }
              },
              decoration: InputDecoration(
                labelText: 'QR Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date range
            ElevatedButton(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                  if (mounted) {
                    context.read<ScanHistoryProvider>().filterByDate(
                      picked.start,
                      picked.end,
                    );
                  }
                }
              },
              child: Text(
                _selectedDate == null
                    ? 'Select Date Range'
                    : '${_selectedDate!.start.toLocal().toString().split(' ')[0]} - '
                        '${_selectedDate!.end.toLocal().toString().split(' ')[0]}',
              ),
            ),
            const SizedBox(height: 32),

            // Results
            Consumer<ScanHistoryProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.scanHistory.isEmpty) {
                  return const Center(child: Text('No results found'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.scanHistory.length,
                  itemBuilder: (context, index) {
                    final scan = provider.scanHistory[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(scan.title ?? scan.qrCode),
                        subtitle: Text(scan.qrType),
                        trailing: Text(
                          scan.scannedAt.toLocal().toString().split('.')[0],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
