import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin/qr_scanner_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/team_registration_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/my_tickets_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/profile_setup_screen.dart';
import 'utils/constants.dart';
import 'theme/dark_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.containsKey('email'); // 🔐 Login persisted
  final isProfileSet = prefs.containsKey('name');

  String initialRoute = '/login';
  if (isLoggedIn && isProfileSet) {
    initialRoute = '/home';
  } else if (isLoggedIn && !isProfileSet) {
    initialRoute = '/profile-setup';
  }

  runApp(MyApp(startRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String startRoute;

  const MyApp({super.key, required this.startRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      themeMode: ThemeMode.dark,
      theme: ThemeData.light(),
      darkTheme: AppDarkTheme.theme,
      initialRoute: startRoute,
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),
        '/qrScanner': (context) => QRScannerScreen(),
        '/adminDashboard': (context) => const AdminDashboardScreen(),
        '/team-registration': (context) => const TeamRegistrationScreen(),
        '/my-tickets': (context) => const MyTicketsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
