import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final _collegeController = TextEditingController();
  final _secretCodeController = TextEditingController();
  // New: Controllers for the new fields
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
    _prefillData(email);
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

  Future<void> _prefillData(String email) async {
    // This function remains the same
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (doc.exists && mounted) {
      final data = doc.data();
      _memberNameController.text = data?['name'] ?? '';
      _collegeController.text = data?['college'] ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
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
    // Modified: Default team name is now "GDG" for non-team events
    final String teamName = _isTeamBasedEvent == true
        ? _teamNameController.text.trim()
        : "GDG";

    final collegeName = _collegeController.text.trim();
    // New: Get data from new controllers
    final rollNumber = _rollNumberController.text.trim();
    final className = _classController.text.trim();
    // Modified: Update QR code string to include new data
    final qrCodeData = "${eventName}_${memberName}_${teamName}_${collegeName}_${rollNumber}_${className}";
    final registrationDate = DateTime.now().toIso8601String();

    final eventDocRef = FirebaseFirestore.instance.collection('tickets').doc(eventName);
    final teamDocRef = eventDocRef.collection('teams').doc(teamName);
    final memberRef = teamDocRef.collection('members').doc(memberName);

    final memberDoc = await memberRef.get();
    if (memberDoc.exists) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already registered in this event/team.")),
      );
      return;
    }

    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.set(eventDocRef, {'eventName': eventName}, SetOptions(merge: true));
    batch.set(teamDocRef, {'teamName': teamName}, SetOptions(merge: true));
    // Modified: Add new fields to Firestore document
    batch.set(memberRef, {
      'eventName': eventName,
      'teamName': teamName,
      'memberName': memberName,
      'email': email,
      'collegeName': collegeName,
      'rollNumber': rollNumber, // New
      'class': className,       // New
      'qrCode': qrCodeData,
      'date': registrationDate,
    });
    await batch.commit();

    // Modified: Update Ticket object for local cache
    final newTicket = Ticket(
      eventName: eventName,
      teamName: teamName,
      date: registrationDate,
      qrCodeData: qrCodeData,
      rollNumber: rollNumber, // New
      className: className,   // New
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

              // New: Added Roll Number and Class TextFormFields
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