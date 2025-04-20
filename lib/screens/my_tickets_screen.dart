// ✅ my_tickets_screen.dart with deletion
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  _MyTicketsScreenState createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<Ticket> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTickets = prefs.getStringList('tickets') ?? [];

    setState(() {
      _tickets = storedTickets.map((ticketJson) {
        try {
          final decoded = jsonDecode(ticketJson);
          return Ticket.fromJson(decoded);
        } catch (e) {
          print("Failed to decode ticket: $e");
          return null;
        }
      }).whereType<Ticket>().toList();
    });
  }

  Future<void> _deleteTicket(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tickets.removeAt(index);
    });
    final updated = _tickets.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('tickets', updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets'), centerTitle: true),
      body: _tickets.isEmpty
          ? const Center(
        child: Text(
          'No tickets found.',
          style: TextStyle(color: Colors.white70),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticket.eventName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteTicket(index),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Date: ${ticket.date}', style: const TextStyle(color: Colors.white70)),
                  Text('Team: ${ticket.teamName}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  ticket.qrCodeData.isNotEmpty
                      ? Center(
                    child: QrImageView(
                      data: ticket.qrCodeData,
                      version: QrVersions.auto,
                      size: 150,
                      backgroundColor: Colors.white,
                    ),
                  )
                      : const Center(child: Text('QR Code not available', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          );
        },
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

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'date': date,
    'teamName': teamName,
    'qrCodeData': qrCodeData,
  };

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    eventName: json['eventName'],
    date: json['date'],
    teamName: json['teamName'],
    qrCodeData: json['qrCodeData'],
  );
}