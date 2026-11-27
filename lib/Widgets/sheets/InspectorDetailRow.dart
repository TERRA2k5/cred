import 'package:credd/Widgets/common/CircleIconBadge.dart';
import 'package:credd/Widgets/common/CtaFeedback.dart';
import 'package:flutter/material.dart';

class InspectorDetailRow extends StatelessWidget {
  const InspectorDetailRow({
    super.key,
    required this.icon,
    required this.caption,
    required this.value,
  });

  final IconData icon;
  final String caption;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showCtaFeedback(context, caption),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            CircleIconBadge(icon: icon, diameter: 36, iconSize: 17),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caption,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
