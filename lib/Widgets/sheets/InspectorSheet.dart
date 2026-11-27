import 'package:credd/Widgets/common/CtaFeedback.dart';
import 'package:credd/Widgets/common/DashedLinePainter.dart';
import 'package:credd/Widgets/sheets/InspectorDetailRow.dart';
import 'package:credd/models/CreditCardModel.dart';
import 'package:flutter/material.dart';

class InspectorSheet extends StatelessWidget {
  const InspectorSheet({
    super.key,
    required this.card,
    required this.topInset,
  });

  final CreditCardModel card;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (
        Icons.description_outlined,
        'latest statement',
        card.amountText == null
            ? 'no statement generated yet'
            : '${card.amountText} bill generated on 28 Aug',
      ),
      (
        Icons.currency_rupee_rounded,
        'recent spends',
        'no spends since last statement',
      ),
      (Icons.percent_rounded, 'card offers', 'verify card to unlock'),
    ];

    return Container(
      key: const Key('card_detail_sheet'),
      padding: EdgeInsets.fromLTRB(16, topInset, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(
                child: _SheetQuickAction(
                  icon: Icons.check_circle_outline,
                  label: 'mark as paid',
                ),
              ),
              SizedBox(
                height: 24,
                child: VerticalDivider(width: 1, color: Color(0xFFE5E5E5)),
              ),
              Expanded(
                child: _SheetQuickAction(
                  icon: Icons.receipt_long_outlined,
                  label: 'payment history',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const DashedDivider(
            dashWidth: 4,
            thickness: 1.5,
            color: Color(0xFFEEEEEE),
          ),
          const SizedBox(height: 18),
          const Text(
            'SEPTEMBER 7TH',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.6,
              color: Color(0xFF8A8A8A),
            ),
          ),
          const SizedBox(height: 6),
          Column(
            children: [
              for (final row in rows)
                InspectorDetailRow(
                  icon: row.$1,
                  caption: row.$2,
                  value: row.$3,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetQuickAction extends StatelessWidget {
  const _SheetQuickAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showCtaFeedback(context, label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
