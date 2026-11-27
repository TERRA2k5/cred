import 'dart:ui' show lerpDouble;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:credd/Widgets/common/CtaFeedback.dart';
import 'package:credd/core/utils/MarkupParser.dart';
import 'package:credd/models/CardPillModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _textStyle = TextStyle(
  fontSize: 10.5,
  fontWeight: FontWeight.w500,
  color: Colors.black87,
);
const _hPad = 10.0;
const _border = 0.8;
const _iconSize = 12.0;
const _iconGap = 5.0;
const _chevronSize = 14.0;

class ActionBadgePill extends StatelessWidget {
  const ActionBadgePill({
    super.key,
    required this.pills,
    required this.flipAnimation,
    required this.step,
  });

  final List<CardPillModel> pills;
  final Animation<double> flipAnimation;
  final ValueListenable<int> step;

  double _widthFor(BuildContext context, CardPillModel pill) {
    final span = TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: [MarkupParser.buildTextSpan(pill.title, defaultStyle: _textStyle)],
    );
    final painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final icon = pill.iconUrl != null ? _iconSize + _iconGap : 0;
    return (painter.width + icon + 2 * _hPad + 2 * _border + _chevronSize)
        .ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (pills.isEmpty) return const SizedBox.shrink();

    final sortedPills = List<CardPillModel>.of(pills)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, _) {
        final currentStep = step.value;
        final currPill = sortedPills[currentStep % sortedPills.length];
        final currWidth = _widthFor(context, currPill);

        final t = sortedPills.length < 2 ? 1.0 : flipAnimation.value;
        final inT = Curves.easeOutCubic.transform(t).clamp(0.0, 1.0);
        final outT = Curves.easeInCubic.transform(t).clamp(0.0, 1.0);

        final prevPill = t < 1.0
            ? sortedPills[(currentStep - 1) % sortedPills.length]
            : null;
        final width = prevPill != null
            ? lerpDouble(_widthFor(context, prevPill), currWidth, inT)!
            : currWidth;

        return GestureDetector(
          onTap: () =>
              showCtaFeedback(context, MarkupParser.toPlainText(currPill.title)),
          child: Container(
            width: width,
            height: 26,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFE2E2E2), width: _border),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  left: _hPad,
                  right: _hPad + _chevronSize,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (prevPill != null)
                        Opacity(
                          opacity: (1.0 - outT).clamp(0.0, 1.0),
                          child: FractionalTranslation(
                            translation: const Offset(0, -1.5),
                            child: _PillContent(pill: prevPill),
                          ),
                        ),
                      Opacity(
                        opacity: inT,
                        child: FractionalTranslation(
                          translation: Offset(0, 1.5 * (1.0 - inT)),
                          child: _PillContent(pill: currPill),
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  right: _hPad,
                  top: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: _chevronSize,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PillContent extends StatelessWidget {
  const _PillContent({required this.pill});

  final CardPillModel pill;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      alignment: Alignment.center,
      minWidth: 0,
      maxWidth: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pill.iconUrl != null) ...[
            CachedNetworkImage(
              imageUrl: pill.iconUrl!,
              width: _iconSize,
              height: _iconSize,
              errorWidget: (_, _, _) => const SizedBox(
                width: _iconSize,
                height: _iconSize,
              ),
            ),
            const SizedBox(width: _iconGap),
          ],
          Text.rich(
            MarkupParser.buildTextSpan(pill.title, defaultStyle: _textStyle),
          ),
        ],
      ),
    );
  }
}
