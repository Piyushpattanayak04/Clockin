import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_tickets_screen.dart';

// Note: Ensure you have the Ticket class defined and imported correctly.
// I'm assuming it's available from your my_tickets_screen.dart file or a model file.
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

  Map<String, dynamic> toJson() => {
    'eventName': eventName,
    'date': date,
    'teamName': teamName,
    'qrCode': qrCodeData,
    'rollNumber': rollNumber,
    'class': className,
  };
}


class TeamRegistrationScreen extends StatefulWidget {
  const TeamRegistrationScreen({super.key});

  @override
  State<TeamRegistrationScreen> createState() => _TeamRegistrationScreenState();
}

class _TeamRegistrationScreenState extends State<TeamRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _memberNameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _secretCodeController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _classController = TextEditingController();

  bool _isLoading = false;
  late String eventId;
  late String eventName;
  late String email;
  bool? _isTeamBasedEvent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    eventId = args['eventId']!;
    eventName = args['eventName']!;
    final user = FirebaseAuth.instance.currentUser;
    email = user?.email ?? '';
    _prefillData();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('skeleton')
          .doc(eventId)
          .get();

      if (mounted) {
        if (doc.exists) {
          final data = doc.data();
          setState(() {
            _isTeamBasedEvent = data?['isTeamBasedEvent'] as bool? ?? false;
          });
        } else {
          setState(() {
            _isTeamBasedEvent = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTeamBasedEvent = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching event details: $e")),
        );
      }
    }
  }

  Future<void> _prefillData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && mounted) {
      final data = doc.data();
      _memberNameController.text = data?['name'] ?? '';
      _collegeController.text = data?['college'] ?? '';
    }
  }

  // ### MODIFIED SUBMIT LOGIC ###
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Should not happen if user is on this screen, but good practice to check
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication error. Please log in again.")),
      );
      return;
    }
    final String userId = user.uid;

    final codeEntered = _secretCodeController.text.trim();
    final codeDoc = await FirebaseFirestore.instance
        .collection('codes')
        .doc(eventName)
        .get();

    if (!codeDoc.exists || codeDoc.data()?[email] != codeEntered) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid secret code for this event.")),
      );
      return;
    }

    final memberName = _memberNameController.text.trim();
    final String teamName = _isTeamBasedEvent == true
        ? _teamNameController.text.trim()
        : "GDG";
    final collegeName = _collegeController.text.trim();
    final rollNumber = _rollNumberController.text.trim();
    final className = _classController.text.trim();
    final qrCodeData = "${eventName}_${memberName}_${teamName}_${collegeName}_${rollNumber}_${className}";
    final registrationDate = DateTime.now().toIso8601String();

    // Define references for the batch write
    final eventDocRef = FirebaseFirestore.instance.collection('tickets').doc(eventName);
    final teamDocRef = eventDocRef.collection('teams').doc(teamName);
    final memberRef = teamDocRef.collection('members').doc(memberName);

    // **NEW**: Reference to the user-specific ticket index for fast lookups
    final userTicketRef = FirebaseFirestore.instance
        .collection('userTickets')
        .doc(userId)
        .collection('tickets')
        .doc(); // Using .doc() generates a unique ID

    final memberDoc = await memberRef.get();
    if (memberDoc.exists) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already registered in this event/team.")),
      );
      return;
    }

    // Create a map with all the ticket data once
    final ticketData = {
      'eventName': eventName,
      'teamName': teamName,
      'memberName': memberName,
      'email': email,
      'collegeName': collegeName,
      'rollNumber': rollNumber,
      'class': className,
      'qrCode': qrCodeData,
      'date': registrationDate,
    };

    // Use a batch to perform multiple writes atomically
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // 1. Original write for event management
    batch.set(eventDocRef, {'eventName': eventName}, SetOptions(merge: true));
    batch.set(teamDocRef, {'teamName': teamName}, SetOptions(merge: true));
    batch.set(memberRef, ticketData);

    // 2. **NEW**: Write to the user's personal ticket index
    batch.set(userTicketRef, ticketData);

    await batch.commit();

    // Update local cache
    final newTicket = Ticket(
      eventName: eventName,
      teamName: teamName,
      date: registrationDate,
      qrCodeData: qrCodeData,
      rollNumber: rollNumber,
      className: className,
    );

    final prefs = await SharedPreferences.getInstance();
    final existingTicketsJson = prefs.getStringList('myTickets') ?? [];
    existingTicketsJson.add(jsonEncode(newTicket.toJson()));
    await prefs.setStringList('myTickets', existingTicketsJson);

    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Registration successful!")),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... Your build method remains exactly the same ...
    return Scaffold(
      appBar: AppBar(title: Text("Register for $eventName")),
      body: _isTeamBasedEvent == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_isTeamBasedEvent == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TextFormField(
                    controller: _teamNameController,
                    decoration: const InputDecoration(labelText: 'Team Name'),
                    validator: (value) =>
                    value!.isEmpty ? 'Enter team name' : null,
                  ),
                ),
              TextFormField(
                controller: _memberNameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _collegeController,
                decoration: const InputDecoration(labelText: 'College Name'),
                validator: (value) => value!.isEmpty ? 'Enter your college' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rollNumberController,
                decoration: const InputDecoration(labelText: 'Roll Number'),
                validator: (value) => value!.isEmpty ? 'Enter your Roll Number' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(labelText: 'Class'),
                validator: (value) => value!.isEmpty ? 'Enter your Class' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _secretCodeController,
                decoration: const InputDecoration(labelText: '7-Digit Secret Code'),
                validator: (value) =>
                value!.length == 7 ? null : 'Must be 7 characters',
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