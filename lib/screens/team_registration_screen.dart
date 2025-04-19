import 'package:flutter/material.dart';

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

  // Get event details from the arguments passed via navigation
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    eventId = args['eventId']!;
    eventName = args['eventName']!;
  }

  // Form submission logic
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // TODO: Validate the secret code from backend/database
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay

      bool isCodeValid = _secretCodeController.text.trim() == 'ABC123456789XYZ0'; // Mock validation

      setState(() => _isLoading = false);

      if (isCodeValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Team registered successfully!")),
        );

        // TODO: Generate QR & save ticket

        // Navigate to 'My Tickets' screen with registration details
        Navigator.pushNamed(
          context,
          '/my-tickets',
          arguments: {
            'teamName': _teamNameController.text.trim(),
            'memberName': _memberNameController.text.trim(),
            'college': _collegeController.text.trim(),
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid secret code")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register for $eventName"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _teamNameController,
                decoration: const InputDecoration(labelText: 'Team Name'),
                validator: (value) =>
                value != null && value.isNotEmpty ? null : 'Enter team name',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memberNameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
                validator: (value) =>
                value != null && value.isNotEmpty ? null : 'Enter your name',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value != null && value.length == 10 ? null : 'Enter valid contact number',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _collegeController,
                decoration: const InputDecoration(labelText: 'College Name'),
                validator: (value) =>
                value != null && value.isNotEmpty ? null : 'Enter college name',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _secretCodeController,
                decoration: const InputDecoration(
                  labelText: '16-Digit Secret Code',
                ),
                validator: (value) =>
                value != null && value.length == 16 ? null : 'Enter valid 16-digit code',
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
