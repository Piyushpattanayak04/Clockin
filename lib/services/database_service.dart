import 'dart:async';

class DatabaseService {
  // Mock databases for team registrations and attendance
  final List<Map<String, String>> _registrations = [];
  final List<Map<String, String>> _attendance = [];

  // Get all registered teams
  Future<List<Map<String, String>>> getAllRegistrations() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay
    return _registrations;
  }

  // Add a team registration
  Future<bool> addTeamRegistration({
    required String teamName,
    required String memberName,
    required String contact,
    required String college,
    required String secretCode,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay

    // Validate secret code (mock validation)
    if (secretCode != 'ABC123456789XYZ0') {
      return false; // Invalid code
    }

    final registration = {
      'teamName': teamName,
      'memberName': memberName,
      'contact': contact,
      'college': college,
      'secretCode': secretCode,
    };

    _registrations.add(registration); // Store in mock database

    return true; // Successfully added
  }

  // Get attendance of all members
  Future<List<Map<String, String>>> getAllAttendance() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay
    return _attendance;
  }

  // Mark attendance of a member
  Future<bool> markAttendance({
    required String memberName,
    required String teamName,
    required String college,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay

    final attendance = {
      'memberName': memberName,
      'teamName': teamName,
      'college': college,
      'timestamp': DateTime.now().toString(),
    };

    _attendance.add(attendance); // Store in attendance database

    return true; // Successfully marked attendance
  }

  // Filter registrations by team name
  Future<List<Map<String, String>>> getRegistrationsByTeam(String teamName) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate delay
    return _registrations
        .where((registration) => registration['teamName'] == teamName)
        .toList();
  }
}
