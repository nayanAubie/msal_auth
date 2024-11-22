import 'package:flutter/material.dart';

Future<bool?> showInfoDialog({
  required BuildContext context,
  required String title,
  required String content,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}