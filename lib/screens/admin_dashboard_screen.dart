import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Mock data
  final List<Map<String, String>> allRegistrations = [
    {
      'member': 'Ankit',
      'team': 'CodeMasters',
      'college': 'ABC University',
      'scanned': 'true',
    },
    {
      'member': 'Riya',
      'team': 'HackHustlers',
      'college': 'XYZ College',
      'scanned': 'false',
    },
    {
      'member': 'Sameer',
      'team': 'CodeMasters',
      'college': 'ABC University',
      'scanned': 'true',
    },
  ];

  String _filterTeam = '';

  List<Map<String, String>> get filteredList {
    if (_filterTeam.isEmpty) return allRegistrations;
    return allRegistrations
        .where(
          (entry) =>
              entry['team']!.toLowerCase().contains(_filterTeam.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = allRegistrations.length;
    final scanned =
        allRegistrations.where((r) => r['scanned'] == 'true').length;
    final remaining = total - scanned;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/qr-scanner',
              ); // Define route separately
            },
            tooltip: "Scan QR for Attendance",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatsCard("Total Registered", total.toString(), Colors.blue),
            _buildStatsCard("Scanned", scanned.toString(), Colors.green),
            _buildStatsCard("Remaining", remaining.toString(), Colors.orange),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: "Filter by Team Name",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _filterTeam = value),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final reg = filteredList[index];
                  return Card(
                    child: ListTile(
                      title: Text(reg['member']!),
                      subtitle: Text("${reg['team']} • ${reg['college']}"),
                      trailing: Icon(
                        reg['scanned'] == 'true'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            reg['scanned'] == 'true'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value, style: TextStyle(fontSize: 18, color: color)),
      ),
    );
  }
}
