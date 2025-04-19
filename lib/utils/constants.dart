import 'package:flutter/material.dart';

class AppConstants {
  // Event names
  static const String eventCheckIn = 'Check-In';
  static const String eventLunch = 'Lunch';
  static const String eventSnacks = 'Snacks';
  static const String eventDinner = 'Dinner';
  static const String eventBreakfast = 'Breakfast';
  static const String eventCheckOut = 'Check-Out';

  // Secret code for team registration (mocked)
  static const String teamSecretCode = 'ABC123456789XYZ0';

  // Error messages
  static const String invalidCodeMessage = 'Invalid team secret code.';
  static const String registrationSuccessMessage =
      'Team successfully registered!';
  static const String attendanceSuccessMessage =
      'Attendance successfully marked!';
  static const String qrScanErrorMessage = 'Invalid QR format!';

  // App theme colors
  static const Color primaryColor = Color(0xFF121212); // Dark theme color
  static const Color accentColor = Color(
    0xFF6200EE,
  ); // Purple accent for app buttons

  // Other constants
  static const String appTitle = 'Event Management App';
  static const String registrationTitle = 'Team Registration';
  static const String attendanceTitle = 'Scan Attendance';
}
