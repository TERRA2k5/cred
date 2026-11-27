import 'package:flutter/material.dart';

class CircleIconBadge extends StatelessWidget {
  const CircleIconBadge({
    super.key,
    required this.icon,
    this.diameter = 44,
    this.iconSize = 20,
  });

  final IconData icon;
  final double diameter;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Icon(icon, size: iconSize, color: Colors.black87),
    );
  }
}
