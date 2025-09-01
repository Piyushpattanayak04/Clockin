import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    // First, try loading from the local cache
    await _loadTicketsFromCache();
    // If cache is empty, fetch from Firestore
    if (_tickets.isEmpty) {
      await _fetchTicketsFromFirestore();
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTicketsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ticketJsonList = prefs.getStringList('myTickets') ?? [];
    if (ticketJsonList.isNotEmpty) {
      final List<Ticket> cachedTickets = ticketJsonList
          .map((jsonString) => Ticket.fromJson(jsonDecode(jsonString)))
          .toList();
      if (mounted) {
        setState(() {
          _tickets = cachedTickets;
        });
      }
    }
  }

  // ### MODIFIED AND IMPROVED FETCH LOGIC ###
  Future<void> _fetchTicketsFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return; // Not logged in, no tickets to fetch
    }

    try {
      // Direct, efficient query to the user's personal ticket collection
      final userTicketsSnapshot = await FirebaseFirestore.instance
          .collection('userTickets')
          .doc(user.uid)
          .collection('tickets')
          .get();

      final List<Ticket> fetchedTickets = userTicketsSnapshot.docs
          .map((doc) => Ticket.fromJson(doc.data()))
          .toList();

      // Cache the newly fetched tickets
      final prefs = await SharedPreferences.getInstance();
      final List<String> ticketJsonList =
      fetchedTickets.map((ticket) => jsonEncode(ticket.toJson())).toList();
      await prefs.setStringList('myTickets', ticketJsonList);

      if (mounted) {
        setState(() {
          _tickets = fetchedTickets;
        });
      }
    } catch (e) {
      // Handle potential errors, e.g., network issues
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch tickets: $e")),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    // Refreshing will always hit Firestore for the latest data
    await _fetchTicketsFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    // ... Your build method remains exactly the same ...
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
          onRefresh: _handleRefresh,
          child: _tickets.isEmpty
              ? LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints:
                BoxConstraints(minHeight: constraints.maxHeight),
                child: const Center(
                  child: Text(
                    'No tickets found.\nPull down to refresh.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
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
                          style: const TextStyle(
                              color: Colors.white70)),
                      Text('Roll No: ${ticket.rollNumber}',
                          style: const TextStyle(
                              color: Colors.white70)),
                      Text('Class: ${ticket.className}',
                          style: const TextStyle(
                              color: Colors.white70)),
                      Text('Date: ${ticket.date.split('T').first}',
                          style: const TextStyle(
                              color: Colors.white70)),
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

// Your Ticket class remains the same
class Ticket {
  final String eventName;
  final String date;
  final String teamName;
  final String qrCodeData;
  final String rollNumber;
  final String className;

  Ticket({
    required this.eventName,
    required this.date,
    required this.teamName,
    required this.qrCodeData,
    required this.rollNumber,
    required this.className,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    eventName: json['eventName'] ?? '',
    date: json['date'] ?? '',
    teamName: json['teamName'] ?? '',
    qrCodeData: json['qrCode'] ?? '',
    rollNumber: json['rollNumber'] ?? '',
    className: json['class'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'date': date,
    'teamName': teamName,
    'qrCode': qrCodeData,
    'rollNumber': rollNumber,
    'class': className,
  };
}