import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyTicketsScreen extends StatelessWidget {
  final List<Ticket> tickets;

  const MyTicketsScreen({super.key, required this.tickets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        centerTitle: true,
      ),
      body: tickets.isEmpty
          ? const Center(
        child: Text(
          'No tickets found.',
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
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
                  Text(
                    'Date: ${ticket.date}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Team: ${ticket.teamName}',
                    style: const TextStyle(color: Colors.white70),
                  ),
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
}
