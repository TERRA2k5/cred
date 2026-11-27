import 'package:flutter/material.dart';

/// Displays a floating snackbar confirming a tapped CTA label.
void showCtaFeedback(BuildContext context, String label) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '"$label" tapped',
          style: const TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
}
