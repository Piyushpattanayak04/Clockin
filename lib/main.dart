import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart'; // Import the login screen
import 'screens/home_screen.dart'; // Import the home screen
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin/qr_scanner_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/team_registration_screen.dart';
import 'screens/auth/register_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(), // The login screen route
        '/home': (context) => HomeScreen(), // The home screen route
        '/register': (context) => RegisterScreen(), // Registration screen route
        '/qrScanner': (context) => QRScannerScreen(), // QR scanner route
        '/adminDashboard': (context) => AdminDashboardScreen(), // Admin dashboard route
        '/team-registration': (context) => TeamRegistrationScreen(), // Team registration screen route
      },
    );
  }
}
