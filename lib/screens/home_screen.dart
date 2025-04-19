import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, String>> _events = const [
    {'id': 'event1', 'name': 'Tech Quiz'},
    {'id': 'event2', 'name': 'Code Marathon'},
    {'id': 'event3', 'name': 'Design Sprint'},
    {'id': 'event4', 'name': 'Hackathon'},
  ];

  void _selectEvent(BuildContext context, String eventId, String eventName) {
    Navigator.pushNamed(
      context,
      '/team-registration',
      arguments: {'eventId': eventId, 'eventName': eventName},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Events"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                event['name']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectEvent(context, event['id']!, event['name']!),
            ),
          );
        },
      ),
    );
  }
}
