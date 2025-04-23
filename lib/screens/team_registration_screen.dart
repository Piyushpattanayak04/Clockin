import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  bool _isLoading = false;
  late String eventId;
  late String eventName;
  late String email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    eventId = args['eventId']!;
    eventName = args['eventName']!;
    final user = FirebaseAuth.instance.currentUser;
    email = user?.email ?? '';
    _prefillData(email);
  }

  Future<void> _prefillData(String email) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final data = doc.data();
    if (data != null) {
      _memberNameController.text = data['name'] ?? '';
      _collegeController.text = data['college'] ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final codeEntered = _secretCodeController.text.trim();

    final codeDoc = await FirebaseFirestore.instance.collection('codes').doc(email).get();
    if (!codeDoc.exists || codeDoc['code'] != codeEntered) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid code or email combination")),
      );
      return;
    }

    final teamName = _teamNameController.text.trim();
    final memberName = _memberNameController.text.trim();
    final collegeName = _collegeController.text.trim();
    final qrCodeData = "${eventName}_${memberName}_${teamName}_$collegeName";

    final eventDocRef = FirebaseFirestore.instance.collection('tickets').doc(eventName);
    await eventDocRef.set({'eventName': eventName}, SetOptions(merge: true)); // ✅ Add eventName field

    final teamDocRef = eventDocRef.collection('teams').doc(teamName);
    await teamDocRef.set({'teamName': teamName}, SetOptions(merge: true)); // ✅ Add teamName field

    final memberRef = teamDocRef.collection('members').doc(memberName);
    final memberDoc = await memberRef.get();
    if (memberDoc.exists) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already registered in this team.")),
      );
      return;
    }

    await memberRef.set({
      'eventName': eventName,
      'teamName': teamName,
      'memberName': memberName,
      'email': email,
      'collegeName': collegeName,
      'qrCode': qrCodeData,
      'date': DateTime.now().toIso8601String(),
    });

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(labelText: 'Team Name'),
                validator: (value) => value!.isEmpty ? 'Enter team name' : null,
              ),
              const SizedBox(height: 12),
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
