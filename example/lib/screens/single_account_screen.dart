import 'package:flutter/material.dart';
import 'package:msal_auth/msal_auth.dart';

class SingleAccountScreen extends StatefulWidget {
  final SingleAccountPca singleAccountPca;

  const SingleAccountScreen({super.key, required this.singleAccountPca});

  @override
  State<SingleAccountScreen> createState() => _SingleAccountScreenState();
}

class _SingleAccountScreenState extends State<SingleAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Single Account'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure to want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Yes'),
                    )
                  ],
                ),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(),
    );
  }
}
