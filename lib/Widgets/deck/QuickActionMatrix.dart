import 'package:credd/Widgets/common/AmountText.dart';
import 'package:credd/Widgets/deck/DeckGeometryCalculator.dart';
import 'package:flutter/material.dart';

class QuickActionMatrix extends StatelessWidget {
  const QuickActionMatrix({
    super.key,
    required this.swipe,
  });

  final Animation<double> swipe;

  static const actions = <(IconData, String)>[
    (Icons.check_circle_outline, 'mark\nas paid'),
    (Icons.description_outlined, 'smart\nstatement'),
    (Icons.receipt_long_outlined, 'payment\nhistory'),
    (Icons.percent_rounded, 'card\noffers'),
    (Icons.currency_rupee_rounded, 'recent\nspends'),
    (Icons.apps_rounded, 'more\nactions'),
  ];

  static const _rowTuck = 0.45;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < 3; row++)
          Expanded(
            child: AnimatedBuilder(
              animation: swipe,
              builder: (context, child) {
                final t = swipe.value;
                return Opacity(
                  opacity: ((t - row * 0.1) / 0.8).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      -row *
                          DeckGeometryCalculator.gridRowHeight *
                          _rowTuck *
                          (1 - t),
                    ),
                    child: child,
                  ),
                );
              },
              child: Row(
                children: [
                  for (var col = 0; col < 2; col++)
                    Expanded(
                      child: _ActionItem(
                        icon: actions[row * 2 + col].$1,
                        label: actions[row * 2 + col].$2,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showCtaFeedback(context, label.replaceAll('\n', ' ')),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Icon(icon, size: 20, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              height: 1.25,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}
