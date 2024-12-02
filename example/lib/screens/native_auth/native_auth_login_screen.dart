import 'package:flutter/material.dart';

import '../../core/msal_auth_service.dart';
import '../../widgets/dialog/info_dialog.dart';
import '../single_account_screen.dart';

/// User logs in using Native Auth.
class NativeAuthLoginScreen extends StatefulWidget {
  const NativeAuthLoginScreen({super.key});

  static const route = '/native-auth-login';

  @override
  State<NativeAuthLoginScreen> createState() => _NativeAuthLoginScreenState();
}

class _NativeAuthLoginScreenState extends State<NativeAuthLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool get showPassword => _showPassword;
  set showPassword(bool value) {
    if (value == _showPassword) return;
    setState(() => _showPassword = value);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    if (value == _isLoading) return;
    setState(() => _isLoading = value);
  }

  Future<void> _login() async {
    isLoading = true;
    await MsalAuthService.instance.nativeAuthLogin(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  SizedBox get _sizedBox => const SizedBox(height: 16);

  @override
  void initState() {
    super.initState();
    MsalAuthService.instance.msalAuthWorker
      ..addListenerOnSignInSuccess((result) {
        isLoading = false;
        Navigator.of(context).pushNamed(
          SingleAccountScreen.route,
          arguments: true,
        );
        showInfoDialog(
          context: context,
          title: 'Native Auth Success ${result.account.username}',
          content: 'You have successfully logged in using Native Auth.',
        );
      })
      ..addListenerOnNativeAuthError(() {
        isLoading = false;
        showInfoDialog(
          context: context,
          title: 'Native Auth Error',
          content: 'Something went wrong',
        );
      });
  }

  @override
  void dispose() {
    MsalAuthService.instance.msalAuthWorker
      ..removeListenerOnSignInSuccess()
      ..removeListenerOnNativeAuthError();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Auth Login')),
      body: AutofillGroup(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              autofocus: true,
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              autofillHints: [AutofillHints.username],
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            _sizedBox,
            TextFormField(
              obscureText: !_showPassword,
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              autofillHints: [AutofillHints.password],
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => showPassword = !showPassword,
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            _sizedBox,
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
