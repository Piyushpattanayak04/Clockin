import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/team_registration_screen.dart';
import 'screens/my_tickets_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'utils/constants.dart';
import 'theme/dark_theme.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable analytics collection
  await analytics.setAnalyticsCollectionEnabled(true);

  final user = FirebaseAuth.instance.currentUser;
  final String startRoute = user != null ? '/home' : '/login';

  runApp(MyApp(startRoute: startRoute));
}

class MyApp extends StatelessWidget {
  final String startRoute;

  const MyApp({super.key, required this.startRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      themeMode: ThemeMode.dark,
      theme: ThemeData.light(),
      darkTheme: AppDarkTheme.theme,
      initialRoute: startRoute,
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/team-registration': (context) => const TeamRegistrationScreen(),
        '/my-tickets': (context) => const MyTicketsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
