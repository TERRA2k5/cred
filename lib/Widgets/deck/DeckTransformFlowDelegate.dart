import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:credd/Widgets/deck/DeckGeometryCalculator.dart';
import 'package:flutter/widgets.dart';

class DeckTransformFlowDelegate extends FlowDelegate {
  DeckTransformFlowDelegate({
    required this.geometry,
    this.scroll,
    this.swipe = kAlwaysDismissedAnimation,
    this.swipedIndex = 0,
    this.hiddenIndex,
  }) : super(
          repaint: Listenable.merge([
            if (scroll != null) scroll,
            swipe,
          ]),
        );

  final DeckGeometryCalculator geometry;
  final ScrollController? scroll;
  final Animation<double> swipe;
  final int swipedIndex;
  final int? hiddenIndex;

  static const _perspective = 0.0012;

  @override
  Size getSize(BoxConstraints constraints) =>
      Size(geometry.width, geometry.contentHeight);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    final n = geometry.count;
    if (i < n) {
      return BoxConstraints.tight(Size(geometry.cardWidth, geometry.cardHeight));
    }
    if (i < 2 * n) {
      return BoxConstraints.tight(
        Size(geometry.cardWidth, DeckGeometryCalculator.pillHeight),
      );
    }
    return BoxConstraints.tight(Size(geometry.gridWidth, geometry.gridHeight));
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final n = geometry.count;
    final currentScroll = scroll;
    final offset =
        currentScroll != null && currentScroll.hasClients ? currentScroll.offset : 0.0;
    final swipeValue = swipe.value;
    final progress = geometry.expandProgress(offset);
    final activeSwipeIndex = n > 0 ? swipedIndex.clamp(0, n - 1) : 0;
    final swipedSlot = n > 0 ? geometry.slotFor(activeSwipeIndex, offset) : null;
    final collapsedDeckShift = swipeValue * geometry.swipeDeckShift * (1 - progress);
    final expandedShift = swipeValue *
        math.max(0.0, geometry.gridHeight + 12 - geometry.itemExtent) *
        progress;

    // Paint the action grid first so it always sits behind the cards.
    if (swipeValue > 0 && swipedSlot != null && context.childCount > 2 * n) {
      final opacity = ((swipeValue - 0.35) / 0.65).clamp(0.0, 1.0);
      if (opacity > 0) {
        context.paintChild(
          2 * n,
          transform: Matrix4.translationValues(
            geometry.gridLeft,
            swipedSlot.top + offset,
            0,
          ),
          opacity: opacity,
        );
      }
    }

    // Paint back-to-front so lower indices sit on top of the deck.
    for (var i = n - 1; i >= 0; i--) {
      if (i == hiddenIndex) continue;
      final slot = geometry.slotFor(i, offset);
      if (slot.opacity <= 0) continue;
      final extraShift = i > activeSwipeIndex ? collapsedDeckShift + expandedShift : 0.0;
      final top = slot.top + offset + extraShift;
      final transform = i == activeSwipeIndex && swipeValue > 0
          ? _swipeTransform(top, swipeValue)
          : _slotTransform(top, slot.scale);

      // Paint pill before its card so the flip transition slides behind the card.
      final pillOpacity =
          geometry.pillOpacity(i, offset) * (i == activeSwipeIndex ? 1 - swipeValue : 1);
      if (pillOpacity > 0) {
        context.paintChild(
          n + i,
          transform: Matrix4.translationValues(
            DeckGeometryCalculator.horizontalPadding,
            top + geometry.cardHeight,
            0,
          ),
          opacity: pillOpacity,
        );
      }

      context.paintChild(i, transform: transform, opacity: slot.opacity);
    }
  }

  Matrix4 _slotTransform(double top, double scale) {
    final left = DeckGeometryCalculator.horizontalPadding +
        geometry.cardWidth * (1 - scale) / 2;
    return Matrix4.translationValues(left, top, 0)
      ..multiply(Matrix4.diagonal3Values(scale, scale, 1));
  }

  // Card slides left and swings on its Y axis (right edge recedes).
  Matrix4 _swipeTransform(double top, double t) {
    final w = geometry.cardWidth;
    final h = geometry.cardHeight;
    final centerX =
        lerpDouble(geometry.width / 2, geometry.width * 0.42 - w * 0.42, t)!;
    final centerY = top + h / 2 + h * 0.12 * t;
    final scale = 1 + 0.12 * t;
    return Matrix4.translationValues(centerX, centerY, 0)
      ..multiply(Matrix4.identity()..setEntry(3, 2, _perspective))
      ..multiply(Matrix4.rotationY(-0.5 * t))
      ..multiply(Matrix4.diagonal3Values(scale, scale, 1))
      ..multiply(Matrix4.translationValues(-w / 2, -h / 2, 0));
  }

  @override
  bool shouldRepaint(DeckTransformFlowDelegate oldDelegate) =>
      oldDelegate.geometry != geometry ||
      oldDelegate.swipedIndex != swipedIndex ||
      oldDelegate.hiddenIndex != hiddenIndex ||
      oldDelegate.scroll != scroll ||
      oldDelegate.swipe != swipe;

  @override
  bool shouldRelayout(DeckTransformFlowDelegate oldDelegate) =>
      oldDelegate.geometry != geometry;
}
