import 'dart:io';

import 'package:flutter/material.dart';
import 'package:msal_auth/msal_auth.dart';

import '../environment.dart';
import '../widgets/custom_drop_down.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _clientId = Environment.aadClientId;

  final _scopes = [
    'https://graph.microsoft.com/user.read',
    // Add other scopes here if required.
  ];

  var _selectedAccountMode = AccountMode.single;
  var _selectedPrompt = Prompt.whenRequired;
  final _loginHintController = TextEditingController();

  var _selectedBroker = Broker.msAuthenticator;
  var _selectedAuthorityType = AuthorityType.aad;

  late PublicClientApplication _publicClientApplication;
  late SingleAccountPca _singleAccountPca;
  late MultipleAccountPca _multipleAccountPca;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          CustomDropdown<AccountMode>(
            value: _selectedAccountMode,
            items: AccountMode.values,
            label: 'Account Mode',
            onChanged: (value) => setState(
              () => _selectedAccountMode = value ?? AccountMode.single,
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
                'Set your b2c authority URL in the "_authority" variable.',
                style: TextStyle(fontSize: 12),
              ),
          ],
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await _createPublicClientApplication();
              _publicClientApplication.acquireToken(
                scopes: _scopes,
                // loginHint: _loginHintController.text.trim(),
                prompt: _selectedPrompt,
              );
            },
            child: const Text('Acquire Token (Login)'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              _singleAccountPca.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPublicClientApplication() async {
    final androidConfig = AndroidConfig(
      configFilePath: 'assets/msal_config.json',
      redirectUri: Environment.aadAndroidRedirectUri,
    );

    final iOsConfig = IosConfig(
      // authority: Environment.aadiOSAuthority,
      authority: null,
      broker: _selectedBroker,
      authorityType: AuthorityType.aad,
    );

    print('Client id====> $_clientId');

    if (_selectedAccountMode == AccountMode.single) {
      _singleAccountPca = await SingleAccountPca.create(
        clientId: _clientId,
        androidConfig: androidConfig,
        iosConfig: iOsConfig,
      );
      _publicClientApplication = _singleAccountPca;
    } else {
      _multipleAccountPca = await MultipleAccountPca.create(
        clientId: _clientId,
        androidConfig: androidConfig,
        iosConfig: iOsConfig,
      );
      _publicClientApplication = _multipleAccountPca;
    }
  }
}
