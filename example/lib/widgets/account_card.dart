import 'package:flutter/material.dart';
import 'package:msal_auth/msal_auth.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final Widget? action;

  const AccountCard({
    super.key,
    required this.account,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Column(
            children: [
              ListTile(
                title: Text('ID'),
                subtitle: Text(account.id),
              ),
              ListTile(
                title: Text('Username'),
                subtitle: Text(account.username ?? 'N/A'),
              ),
              ListTile(
                title: Text('Name'),
                subtitle: Text(account.name ?? 'N/A'),
              ),
            ],
          ),
          if (action != null)
            Positioned(
              top: 0,
              right: 0,
              child: action!,
            ),
        ],
      ),
    );
  }
}
