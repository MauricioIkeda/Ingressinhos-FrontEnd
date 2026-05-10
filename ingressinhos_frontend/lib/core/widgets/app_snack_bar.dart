import 'package:flutter/material.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';

void showErrorSnackBar(BuildContext context, String message, bool isError) {
  final messenger = ScaffoldMessenger.of(context);

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Center(child: Text(message)),
      backgroundColor: isError ? AppColors.errorColor : AppColors.successColor,
      duration: const Duration(seconds: 4),
    ),
  );
}
