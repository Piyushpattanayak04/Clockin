import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<Ticket> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    debugPrint("✅ Fetching tickets for user: $email");

    final List<Ticket> fetchedTickets = [];
    const eventName = 'hack-o-clock';

    final teamsSnapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .doc(eventName)
        .collection('teams')
        .get();

    for (final teamDoc in teamsSnapshot.docs) {
      final teamName = teamDoc.id;

      final membersSnapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(eventName)
          .collection('teams')
          .doc(teamName)
          .collection('members')
          .get();

      for (final memberDoc in membersSnapshot.docs) {
        final data = memberDoc.data();
        if ((data['email'] ?? '').toLowerCase().trim() == email.toLowerCase().trim()) {
          fetchedTickets.add(Ticket.fromJson(data));
        }
      }
    }

    setState(() {
      _tickets = fetchedTickets;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('My Tickets')),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchTickets,
          child: _tickets.isEmpty
              ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 150),
              Center(
                child: Text(
                  'No tickets found.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          )
              : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _tickets.length,
            itemBuilder: (context, index) {
              final ticket = _tickets[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.eventName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Team: ${ticket.teamName}',
                          style: const TextStyle(color: Colors.white70)),
                      Text('Date: ${ticket.date}',
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      Center(
                        child: QrImageView(
                          data: ticket.qrCodeData,
                          version: QrVersions.auto,
                          size: 150,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Ticket {
  final String eventName;
  final String date;
  final String teamName;
  final String qrCodeData;

  Ticket({
    required this.eventName,
    required this.date,
    required this.teamName,
    required this.qrCodeData,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    eventName: json['eventName'] ?? '',
    date: json['date'] ?? '',
    teamName: json['teamName'] ?? '',
    qrCodeData: json['qrCode'] ?? '',
  );
}
