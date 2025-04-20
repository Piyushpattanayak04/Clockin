import 'package:flutter/material.dart';
import 'my_tickets_screen.dart'; // Ensure this is the correct path to MyTicketsScreen
import 'profile/profile_screen.dart'; // Replace with actual profile screen import
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _events = const [
    {'id': 'event1', 'name': 'Hack-o-Clock'},
    // Add more events here if needed
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

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
      appBar: AppBar(
        title: const Text("Hackathon Hub"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Welcome!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? ListView.builder(
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
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () =>
                  _selectEvent(context, event['id']!, event['name']!),
            ),
          );
        },
      )
          : const MyTicketsScreen(), // ✅ No need to pass tickets
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number), label: 'My Tickets'),
        ],
      ),
    );
  }
}
