import 'package:flutter/material.dart';

class AmountText extends StatelessWidget {
  const AmountText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final dot = text.lastIndexOf('.');
    if (dot < 0) return Text(text, style: style);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, dot)),
          TextSpan(text: text.substring(dot)),
        ],
      ),
    );
  }
}

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
