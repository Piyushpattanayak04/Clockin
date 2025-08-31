import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // New: Import Firestore
import 'package:shared_preferences/shared_preferences.dart';
import 'my_tickets_screen.dart';
import 'profile/profile_screen.dart';

// New: A data model class for your events for type-safety and cleaner code.
class Event {
  final String id;
  final String name;

  Event({required this.id, required this.name});

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id, // The document ID is the event's unique ID
      name: data['eventName'] ?? '', // Get the eventName field
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Removed: The hardcoded list is no longer needed.
  // final List<Map<String, String>> _events = const [ ... ];

  // New: Define a stream to listen for events from Firestore in real-time.
  final Stream<QuerySnapshot> _eventsStream =
  FirebaseFirestore.instance.collection('skeleton').snapshots();

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Modified: This function now accepts an Event object.
  void _selectEvent(BuildContext context, Event event) {
    Navigator.pushNamed(
      context,
      '/team-registration',
      arguments: {'eventId': event.id, 'eventName': event.name},
    );
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else {
                exit(0);
              }
            },
            child: const Text("Exit"),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Clock-in"),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.deepPurple),
                child: Text('Welcome!',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
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

                  // Add these two lines to clear local data
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('myQrCodes');

                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (_) => false);
                },
              ),
            ],
          ),
        ),
        // Modified: Replaced the static list with a StreamBuilder
        body: _selectedIndex == 0
            ? StreamBuilder<QuerySnapshot>(
          stream: _eventsStream,
          builder: (context, snapshot) {
            // Handle loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Handle error state
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong!"));
            }
            // Handle no data state
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No events found."));
            }

            // If data exists, build the list
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                // Create an Event object from the Firestore document
                final event =
                Event.fromFirestore(snapshot.data!.docs[index]);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _selectEvent(context, event),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.asset(
                            'assets/banner.png',
                            fit: BoxFit.cover,
                            height: 150,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                event.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        )
            : const MyTicketsScreen(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
            BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number), label: 'My Tickets'),
          ],
        ),
      ),
    );
  }
}