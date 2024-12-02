import 'package:flutter/material.dart';

import '../../core/msal_auth_service.dart';
import '../../widgets/dialog/info_dialog.dart';

/// User signs up using Native Auth.
class NativeAuthSignUpScreen extends StatefulWidget {
  const NativeAuthSignUpScreen({super.key});

  static const route = '/native-auth-sign-up';

  @override
  State<NativeAuthSignUpScreen> createState() => _NativeAuthSignUpScreenState();
}

class _NativeAuthSignUpScreenState extends State<NativeAuthSignUpScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

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

  Future<void> _signUp() async {
    isLoading = true;
    await MsalAuthService.instance.nativeAuthSignUp(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      attributes: {'name': _nameController.text.trim()},
      signInAfterSignUp: true,
    );
  }

  SizedBox get _sizedBox => const SizedBox(height: 16);

  @override
  void initState() {
    super.initState();
    MsalAuthService.instance.msalAuthWorker
        .addListenerOnSignInSuccess((result) {
      isLoading = false;
      showInfoDialog(
        context: context,
        title: 'Native Auth Success ${result.account.username}',
        content: 'You have successfully logged in using Native Auth.',
      );
    });
  }

  @override
  void dispose() {
    MsalAuthService.instance.msalAuthWorker.removeListenerOnSignInSuccess();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Auth Sign Up')),
      body: AutofillGroup(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              autofocus: true,
              controller: _nameController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              autofillHints: [AutofillHints.name],
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            _sizedBox,
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              autofillHints: [AutofillHints.newUsername],
              decoration: const InputDecoration(labelText: 'Username (Email)'),
            ),
            _sizedBox,
            TextFormField(
              obscureText: !_showPassword,
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.visiblePassword,
              autofillHints: [AutofillHints.newPassword],
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
              onPressed: isLoading ? null : _signUp,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
