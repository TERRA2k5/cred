import 'dart:math' as math;

import 'package:credd/Widgets/cards/CreditCardItemView.dart';
import 'package:credd/Widgets/deck/DeckGeometryCalculator.dart';
import 'package:credd/Widgets/sheets/InspectorSheet.dart';
import 'package:credd/models/CreditCardModel.dart';
import 'package:flutter/material.dart';

/// Long-press inspector overlay: lifts the pressed card to the top with a
/// mid-flight 3D X-axis tilt while revealing [InspectorSheet] underneath.
class CardInspectorModal extends StatefulWidget {
  const CardInspectorModal({
    super.key,
    required this.card,
    required this.sourceRect,
    required this.animation,
    required this.onDismiss,
  });

  final CreditCardModel card;

  /// Starting bounds of the card in this overlay's coordinate space.
  final Rect sourceRect;
  final Animation<double> animation;
  final VoidCallback onDismiss;

  @override
  State<CardInspectorModal> createState() => _CardInspectorModalState();
}

class _CardInspectorModalState extends State<CardInspectorModal> {
  static const _scrimColor = Color(0xFF111111);
  static const _scrimMaxAlpha = 0.88;
  static const _perspective = 0.0012;

  late CurvedAnimation _flight;
  late CurvedAnimation _scrim;
  late CurvedAnimation _sheet;
  late CurvedAnimation _cardDetailsCurve;
  late Animation<double> _cardDetails;

  @override
  void initState() {
    super.initState();
    _bind();
  }

  @override
  void didUpdateWidget(CardInspectorModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _disposeCurves();
      _bind();
    }
  }

  void _bind() {
    final parent = widget.animation;
    _flight = CurvedAnimation(
      parent: parent,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _scrim = CurvedAnimation(
      parent: parent,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _sheet = CurvedAnimation(
      parent: parent,
      curve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
    );
    _cardDetailsCurve = CurvedAnimation(
      parent: parent,
      curve: const Interval(0, 0.4),
    );
    _cardDetails = ReverseAnimation(_cardDetailsCurve);
  }

  void _disposeCurves() {
    _flight.dispose();
    _scrim.dispose();
    _sheet.dispose();
    _cardDetailsCurve.dispose();
  }

  @override
  void dispose() {
    _disposeCurves();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.sourceRect;
    final target = Rect.fromLTWH(
      DeckGeometryCalculator.horizontalPadding,
      MediaQuery.viewPaddingOf(context).top + 24,
      source.width,
      source.height,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            key: const Key('detail_scrim'),
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: AnimatedBuilder(
              animation: _scrim,
              builder: (context, _) => ColoredBox(
                color: _scrimColor.withValues(
                  alpha: _scrim.value * _scrimMaxAlpha,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SizeTransition(
            sizeFactor: _sheet,
            axisAlignment: -1,
            child: RepaintBoundary(
              child: InspectorSheet(
                card: widget.card,
                topInset: target.bottom + 8,
              ),
            ),
          ),
        ),
        Positioned.fromRect(
          rect: target,
          child: AnimatedBuilder(
            animation: _flight,
            builder: (context, child) {
              final t = _flight.value;
              final delta = (source.topLeft - target.topLeft) * (1 - t);
              final tilt = math.sin(math.pi * t) * 0.55;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.translationValues(delta.dx, delta.dy, 0)
                  ..multiply(Matrix4.identity()..setEntry(3, 2, _perspective))
                  ..multiply(Matrix4.rotationX(tilt)),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: RepaintBoundary(
                child: CreditCardItemView(
                  card: widget.card,
                  detailsOpacity: _cardDetails,
                  showShadow: false,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
