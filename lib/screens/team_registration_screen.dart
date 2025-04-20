// ✅ team_registration_screen.dart with duplicate prevention
// Place this content in team_registration_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'my_tickets_screen.dart';

class TeamRegistrationScreen extends StatefulWidget {
  const TeamRegistrationScreen({super.key});

  @override
  State<TeamRegistrationScreen> createState() => _TeamRegistrationScreenState();
}

class _TeamRegistrationScreenState extends State<TeamRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _teamNameController = TextEditingController();
  final _memberNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _collegeController = TextEditingController();
  final _secretCodeController = TextEditingController();

  bool _isLoading = false;
  late String eventId;
  late String eventName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    eventId = args['eventId']!;
    eventName = args['eventName']!;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));

      bool isCodeValid = _secretCodeController.text.trim() == 'ABC123456789XYZ0';
      setState(() => _isLoading = false);

      if (isCodeValid) {
        final ticket = Ticket(
          eventName: eventName,
          date: "2025-04-20",
          teamName: _teamNameController.text.trim(),
          qrCodeData: "${_teamNameController.text.trim()}|${_memberNameController.text.trim()}|${_collegeController.text.trim()}",
        );

        final success = await _saveTicketToPreferences(ticket);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Team registered successfully!")),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyTicketsScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid secret code")),
        );
      }
    }
  }

  Future<bool> _saveTicketToPreferences(Ticket ticket) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedTickets = prefs.getStringList('tickets') ?? [];

    // Check for duplicates
    bool alreadyRegistered = storedTickets.any((t) {
      final decoded = jsonDecode(t);
      return decoded['teamName'] == ticket.teamName && decoded['eventName'] == ticket.eventName;
    });

    if (alreadyRegistered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You already registered this team for this event.")),
      );
      return false;
    }

    storedTickets.add(jsonEncode(ticket.toJson()));
    await prefs.setStringList('tickets', storedTickets);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register for $eventName")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(labelText: 'Team Name'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Enter team name',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memberNameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Enter your name',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value != null && value.length == 10 ? null : 'Enter valid contact number',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _collegeController,
                decoration: const InputDecoration(labelText: 'College Name'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Enter college name',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _secretCodeController,
                decoration: const InputDecoration(labelText: '16-Digit Secret Code'),
                validator: (value) => value != null && value.length == 16 ? null : 'Enter valid 16-digit code',
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Submit"),
              ),
            ],
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


