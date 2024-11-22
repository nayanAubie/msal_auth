import 'package:flutter/material.dart';
import 'package:msal_auth/msal_auth.dart';

import '../core/msal_auth_service.dart';
import '../widgets/account_card.dart';
import '../widgets/dialog/confirmation_dialog.dart';
import '../widgets/dialog/info_dialog.dart';

/// User lands on this screen once the user acquired a token with
/// a single account mode.
class SingleAccountScreen extends StatefulWidget {
  static const route = '/single-account';

  const SingleAccountScreen({super.key});

  @override
  State<SingleAccountScreen> createState() => _SingleAccountScreenState();
}

class _SingleAccountScreenState extends State<SingleAccountScreen> {
  Account? _account;

  @override
  void initState() {
    super.initState();
    _getCurrentAccount();
  }

  Future<void> _getCurrentAccount() async {
    final (account, exception) =
        await MsalAuthService.instance.getCurrentAccount();
    if (account != null) {
      _account = account;
      setState(() {});
    } else {
      showInfoDialog(
        context: context,
        title: exception!.runtimeType.toString(),
        content: exception.message,
      );
    }
  }

  Future<void> _signOut() async {
    final result = await showConfirmationDialog(
      context: context,
      title: 'Sign Out Current Account',
      content: 'Are you sure to want to logout?',
      okText: 'Sign Out',
    );
    if (result ?? false) {
      final (success, exception) = await MsalAuthService.instance.signOut();
      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
      } else {
        showInfoDialog(
          context: context,
          title: exception!.runtimeType.toString(),
          content: exception.message,
        );
      }
    }
  }

  Future<void> _acquireTokenSilent() async {
    final (result, exception) =
        await MsalAuthService.instance.acquireTokenSilent();
    if (exception != null) {
      showInfoDialog(
        context: context,
        title: exception.runtimeType.toString(),
        content: exception.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Single Account'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: _account == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                AccountCard(account: _account!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _acquireTokenSilent,
                  child: Text('Acquire Token Silently'),
                ),
              ],
            ),
    );
  }
}
