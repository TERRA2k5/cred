import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart';

class CardSlot {
  const CardSlot({
    required this.top,
    required this.scale,
    required this.opacity,
  });

  final double top;
  final double scale;
  final double opacity;
}

class DeckGeometryCalculator {
  const DeckGeometryCalculator({
    required this.width,
    required this.viewportHeight,
    required this.count,
  });

  final double width;
  final double viewportHeight;
  final int count;

  static const horizontalPadding = 24.0;
  static const topPadding = 20.0;
  static const pillHeight = 44.0;
  static const listGap = 16.0;
  static const cardAspectRatio = 1.7;
  static const visibleDeckDepth = 4;
  static const gridRowHeight = 96.0;

  static const _deckOffsets = [0.1, -0.20, -0.35, -0.42];
  static const _deckScales = [1.05, 0.95, 0.88, 0.8];

  double get cardWidth => width - horizontalPadding * 2;
  double get cardHeight => cardWidth / cardAspectRatio;
  double get itemExtent => cardHeight + pillHeight + listGap;
  double get expandDistance => count > 1 ? cardHeight * 0.6 : 0;
  double get maxScroll => math.max(
        expandDistance,
        topPadding + count * itemExtent + listGap - viewportHeight,
      );
  double get contentHeight => viewportHeight + maxScroll;

  double get deckTop =>
      topPadding + cardHeight + pillHeight - _deckOffsets.last * cardHeight + 8;

  double get gridLeft => width * 0.46;
  double get gridWidth => width - gridLeft - 12;
  double get gridHeight => gridRowHeight * 3;

  double get swipeDeckShift {
    final deckHighestPoint = deckTop + _deckOffsets.last * cardHeight;
    return math.max(0, topPadding + gridHeight + 16 - deckHighestPoint);
  }

  double expandProgress(double scrollOffset) {
    if (expandDistance == 0) return 0;
    return Curves.ease.transform((scrollOffset / expandDistance).clamp(0.0, 1.0));
  }

  CardSlot slotFor(int index, double scrollOffset) {
    final progress = expandProgress(scrollOffset);
    final expandedTop = topPadding + index * itemExtent - scrollOffset;

    if (index == 0) {
      return CardSlot(
        top: lerpDouble(topPadding, expandedTop, progress)!,
        scale: 1,
        opacity: 1,
      );
    }

    final depth = index - 1;
    final clamped = math.min(depth, _deckOffsets.length - 1);
    final collapsedTop = deckTop + _deckOffsets[clamped] * cardHeight;
    final collapsedOpacity = depth < visibleDeckDepth ? 1.0 : 0.0;
    return CardSlot(
      top: lerpDouble(collapsedTop, expandedTop, progress)!,
      scale: lerpDouble(_deckScales[clamped], 1, progress)!,
      opacity: lerpDouble(collapsedOpacity, 1, progress)!,
    );
  }

  double pillOpacity(int index, double scrollOffset) {
    if (index == 0) return 1;
    return ((expandProgress(scrollOffset) - 0.5) * 2).clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) =>
      other is DeckGeometryCalculator &&
      other.width == width &&
      other.viewportHeight == viewportHeight &&
      other.count == count;

  @override
  int get hashCode => Object.hash(width, viewportHeight, count);
}
