import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isEmailVerified = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isEmailVerified = user?.emailVerified ?? false;
    });

    if (_isEmailVerified) {
      Navigator.pushReplacementNamed(context, '/profile-setup');
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      setState(() => _isSending = true);
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email sent ✅")),
      );
    } catch (e) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send verification: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_read, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                "Check your email 📩",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "We've sent a verification link to your email. Please verify it to continue.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _isSending
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: _resendVerificationEmail,
                icon: const Icon(Icons.refresh),
                label: const Text("Resend Verification"),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _checkVerificationStatus,
                icon: const Icon(Icons.check),
                label: const Text("I've Verified"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
