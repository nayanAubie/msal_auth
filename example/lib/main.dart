import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/multi_account_screen.dart';
import 'screens/native_auth/native_auth_login_screen.dart';
import 'screens/native_auth/native_auth_options_screen.dart';
import 'screens/native_auth/native_auth_sign_up_screen.dart';
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
        late final Widget target;

        switch (settings.name) {
          case LoginScreen.route:
            final addAccount = settings.arguments as bool? ?? false;
            target = LoginScreen(addAccount: addAccount);
          case SingleAccountScreen.route:
            final isFromNativeAuth = settings.arguments as bool? ?? false;
            target = SingleAccountScreen(isFromNativeAuth: isFromNativeAuth);
          case MultiAccountScreen.route:
            target = const MultiAccountScreen();
          case NativeAuthOptionsScreen.route:
            target = const NativeAuthOptionsScreen();
          case NativeAuthLoginScreen.route:
            target = const NativeAuthLoginScreen();
          case NativeAuthSignUpScreen.route:
            target = const NativeAuthSignUpScreen();
          default:
            target = const LoginScreen();
        }

        return MaterialPageRoute(builder: (context) => target);
      },
    );
  }
}
