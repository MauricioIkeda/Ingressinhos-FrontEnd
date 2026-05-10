import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, String message, bool isError) {
  final messenger = ScaffoldMessenger.of(context);

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Center(child: Text(message)),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 4),
    ),
  );
}
