import 'dart:io';

import 'package:flutter/material.dart';
import 'package:msal_auth/msal_auth.dart';

import '../core/msal_auth_service.dart';
import '../widgets/custom_drop_down.dart';
import '../widgets/dialog/info_dialog.dart';
import 'multi_account_screen.dart';
import 'single_account_screen.dart';

/// Login screen with provided all the available features of the MSAL plugin.
///
/// Developer does not need to create this kind of dynamic configuration
/// unless it is required for your Flutter app.
class LoginScreen extends StatefulWidget {
  static const route = '/login';
  final bool addAccount;

  const LoginScreen({super.key, this.addAccount = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _selectedAccountMode = AccountMode.single;
  var _selectedPrompt = Prompt.whenRequired;
  final _loginHintController = TextEditingController();

  var _selectedBroker = Broker.msAuthenticator;
  var _selectedAuthorityType = AuthorityType.aad;

  @override
  void initState() {
    super.initState();
    if (widget.addAccount) {
      _selectedAccountMode = AccountMode.multiple;
      setState(() {});
    }
  }

  /// This method creates public client application based on the given
  /// account mode & then calls "acquireToken" method.
  Future<void> _login() async {
    final service = MsalAuthService.instance;
    final (created, exception) = await service.createPublicClientApplication(
      accountMode: _selectedAccountMode,
      broker: _selectedBroker,
      authorityType: _selectedAuthorityType,
    );
    if (created) {
      final (result, exception) = await service.acquireToken(
        prompt: _selectedPrompt,
        loginHint: _loginHintController.text,
      );
      if (result != null) {
        // If login screen opens using "Add Account" option from multiple
        // account screen, we need to close the screen with "true" value.
        if (widget.addAccount) {
          Navigator.of(context).pop(true);
          return;
        }

        // Navigate to next screen based on the selected account mode.
        Navigator.of(context).pushNamed(
          _selectedAccountMode == AccountMode.single
              ? SingleAccountScreen.route
              : MultiAccountScreen.route,
        );
      } else if (mounted) {
        showInfoDialog(
          context: context,
          title: exception!.runtimeType.toString(),
          content: exception.message,
        );
      }
    } else if (mounted) {
      showInfoDialog(
        context: context,
        title: exception!.runtimeType.toString(),
        content: exception.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          AbsorbPointer(
            absorbing: widget.addAccount,
            child: CustomDropdown<AccountMode>(
              value: _selectedAccountMode,
              items: AccountMode.values,
              label: 'Account Mode',
              onChanged: (value) => setState(
                () => _selectedAccountMode = value ?? AccountMode.single,
              ),
            ),
          ),
          SizedBox(height: 16),
          CustomDropdown<Prompt>(
            value: _selectedPrompt,
            items: Prompt.values,
            label: 'Prompt',
            onChanged: (value) => setState(
              () => _selectedPrompt = value ?? Prompt.whenRequired,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _loginHintController,
            decoration: InputDecoration(
              labelText: 'Login hint',
              hintText: 'Login hint (Optional)',
            ),
          ),
          if (Platform.isIOS) ...[
            SizedBox(height: 24),
            Text(
              'iOS Specific',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CustomDropdown<Broker>(
              value: _selectedBroker,
              items: Broker.values,
              label: 'Broker',
              onChanged: (value) => setState(
                () => _selectedBroker = value ?? Broker.msAuthenticator,
              ),
            ),
            SizedBox(height: 16),
            CustomDropdown<AuthorityType>(
              value: _selectedAuthorityType,
              items: AuthorityType.values,
              label: 'Authority Type',
              onChanged: (value) => setState(
                () => _selectedAuthorityType = value ?? AuthorityType.aad,
              ),
            ),
            if (_selectedAuthorityType == AuthorityType.b2c)
              Text(
                'Set your b2c authority URL in the "AAD_IOS_AUTHORITY" variable of environment.',
                style: TextStyle(fontSize: 12),
              ),
          ],
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _login,
            child: const Text('Acquire Token (Login)'),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
