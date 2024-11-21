import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/multi_account_screen.dart';
import 'screens/single_account_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: LoginScreen.route,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case LoginScreen.route:
            final addAccount = settings.arguments as bool? ?? false;
            return MaterialPageRoute(
              builder: (context) => LoginScreen(addAccount: addAccount),
            );
          case SingleAccountScreen.route:
            return MaterialPageRoute(
              builder: (context) => const SingleAccountScreen(),
            );
          case MultiAccountScreen.route:
            return MaterialPageRoute(
              builder: (context) => const MultiAccountScreen(),
            );
          default:
            return null;
        }
      },
    );
  }
}
