import 'package:flutter/material.dart';

class AuthService {
  // Mock user data for authentication
  final _users = <String, String>{
    'test@example.com': 'password123', // email: password
  };

  // Method for login
  Future<bool> login({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    if (_users.containsKey(email) && _users[email] == password) {
      return true;
    } else {
      return false;
    }
  }

  // Method for registration
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    if (password != confirmPassword) {
      return false; // Passwords do not match
    }

    if (_users.containsKey(email)) {
      return false; // Email already registered
    }

    _users[email] = password; // Register the new user
    return true;
  }

  // Method to check if the user is already logged in (mocked here)
  Future<bool> isUserLoggedIn() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return false; // No user logged in (for mock purposes)
  }

  // Mock logout method
  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    // Implement any logout logic (e.g., clear session or token)
  }
}
