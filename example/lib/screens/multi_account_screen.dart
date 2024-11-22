import 'package:flutter/material.dart';
import 'package:msal_auth/msal_auth.dart';

import '../core/msal_auth_service.dart';
import '../widgets/account_card.dart';
import '../widgets/dialog/info_dialog.dart';
import 'login_screen.dart';

/// User lands on this screen once the user acquired a token with
/// a multiple account mode.
class MultiAccountScreen extends StatefulWidget {
  static const route = '/multi-account';

  const MultiAccountScreen({super.key});

  @override
  State<MultiAccountScreen> createState() => _MultiAccountScreenState();
}

class _MultiAccountScreenState extends State<MultiAccountScreen> {
  final _accountOptions = ['Acquire Token Silently', 'Remove'];
  List<Account>? _accounts;

  @override
  void initState() {
    super.initState();
    _getAccounts();
  }

  Future<void> _getAccounts() async {
    final (accounts, exception) = await MsalAuthService.instance.getAccounts();
    if (accounts != null) {
      _accounts = accounts;
      setState(() {});
    } else {
      showInfoDialog(
        context: context,
        title: exception!.runtimeType.toString(),
        content: exception.message,
      );
    }
  }

  Future<void> _acquireTokenSilent(String identifier) async {
    final (result, exception) = await MsalAuthService.instance
        .acquireTokenSilent(identifier: identifier);
    if (exception != null) {
      showInfoDialog(
        context: context,
        title: exception.runtimeType.toString(),
        content: exception.message,
      );
    }
  }

  Future<void> _removeAccount(String identifier) async {
    final (success, exception) =
        await MsalAuthService.instance.removeAccount(identifier: identifier);
    if (success) {
      showInfoDialog(
        context: context,
        title: 'Success',
        content: 'Account has been removed successfully',
      );
      _getAccounts();
    } else {
      showInfoDialog(
        context: context,
        title: exception!.runtimeType.toString(),
        content: exception.message,
      );
    }
  }

  Future<void> _addNewAccount() async {
    final result = await Navigator.of(context)
        .pushNamed(LoginScreen.route, arguments: true);
    if (result == true) {
      _getAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiple Account'),
        actions: [
          IconButton(
            tooltip: 'Add another account',
            icon: Icon(Icons.add),
            onPressed: _addNewAccount,
          ),
        ],
      ),
      body: () {
        if (_accounts == null) {
          return Center(child: CircularProgressIndicator());
        } else if (_accounts!.isEmpty) {
          return Center(child: Text('No Accounts'));
        } else {
          return ListView.separated(
            itemCount: _accounts!.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) => AccountCard(
              account: _accounts![index],
              action: PopupMenuButton<int>(
                onSelected: (value) async {
                  final identifier = _accounts![index].id;
                  switch (value) {
                    case 0:
                      _acquireTokenSilent(identifier);
                      break;
                    case 1:
                      _removeAccount(identifier);
                      break;
                  }
                },
                itemBuilder: (context) {
                  return _accountOptions.map((choice) {
                    return PopupMenuItem<int>(
                      value: _accountOptions.indexOf(choice),
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ),
            separatorBuilder: (context, i) => SizedBox(height: 16),
          );
        }
      }(),
    );
  }
}
