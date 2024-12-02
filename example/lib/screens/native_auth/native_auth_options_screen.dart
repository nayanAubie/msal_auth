import 'package:flutter/material.dart';

import '../../core/msal_auth_service.dart';
import '../login_screen.dart';
import 'native_auth_login_screen.dart';
import 'native_auth_sign_up_screen.dart';

/// Native Auth options screen.
class NativeAuthOptionsScreen extends StatelessWidget {
  const NativeAuthOptionsScreen({super.key});

  static const route = '/native-auth-options';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Auth')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(
              NativeAuthSignUpScreen.route,
            ),
            child: const Text('Sign up'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(
              NativeAuthLoginScreen.route,
            ),
            child: const Text('Login'),
          ),
          ElevatedButton(
            onPressed: () {
              MsalAuthService.instance.nativeAuthPca = null;
              Navigator.of(context).pushReplacementNamed(LoginScreen.route);
            },
            child: const Text('Switch to Single/Multiple account mode'),
          ),
        ],
      ),
    );
  }
}
