import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'my_tickets_screen.dart';
import 'profile/profile_screen.dart';

// A data model class for your events for type-safety and cleaner code.
class Event {
  final String id;
  final String name;
  final String description;
  final String bannerUrl;
  final bool isTeamBased;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.bannerUrl,
    required this.isTeamBased,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      name: data['eventName'] ?? '',
      description: data['description'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      isTeamBased: data['isTeamBasedEvent'] ?? false,
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

  // A stream to listen for events from Firestore in real-time.
  final Stream<QuerySnapshot> _eventsStream =
  FirebaseFirestore.instance.collection('skeleton').snapshots();

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _selectEvent(BuildContext context, Event event) {
    // Show event details bottom sheet before registration
    _showEventDetails(context, event);
  }

  void _showEventDetails(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: event.bannerUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: event.bannerUrl,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: Colors.grey[800],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[800],
                        child: const Icon(Icons.event, size: 64, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Icon(Icons.event, size: 64, color: Colors.grey),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Name
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Team/Individual badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.isTeamBased ? Colors.blue : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.isTeamBased ? 'Team Event' : 'Individual Event',
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    if (event.description.isNotEmpty) ...[
                      const Text(
                        'About',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            event.description,
                            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ] else
                      const Expanded(
                        child: Center(
                          child: Text('No description available', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close bottom sheet
                          Navigator.pushNamed(
                            context,
                            '/team-registration',
                            arguments: {'eventId': event.id, 'eventName': event.name},
                          );
                        },
                        child: const Text('Register Now', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('myTickets');

                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (_) => false);
                },
              ),
            ],
          ),
        ),
        body: _selectedIndex == 0
            ? StreamBuilder<QuerySnapshot>(
          stream: _eventsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong!"));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No events found."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
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
                                      child: event.bannerUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: event.bannerUrl,
                                              fit: BoxFit.cover,
                                              height: 150,
                                              placeholder: (context, url) => Container(
                                                height: 150,
                                                color: Colors.grey[800],
                                                child: const Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) =>
                                                  Container(
                                                height: 150,
                                                color: Colors.grey[800],
                                                child: const Icon(
                                                  Icons.event,
                                                  size: 48,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              height: 150,
                                              color: Colors.grey[800],
                                              child: const Icon(
                                                Icons.event,
                                                size: 48,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (event.description.isNotEmpty)
                                                  Text(
                                                    event.description,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                              ],
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