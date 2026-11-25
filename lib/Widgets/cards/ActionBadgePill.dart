import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:credd/Widgets/common/AmountText.dart';
import 'package:credd/core/utils/MarkupParser.dart';
import 'package:credd/models/CardPillModel.dart';
import 'package:flutter/material.dart';

class ActionBadgePill extends StatefulWidget {
  const ActionBadgePill({super.key, required this.pills});

  final List<CardPillModel> pills;

  @override
  State<ActionBadgePill> createState() => _ActionBadgePillState();
}

class _ActionBadgePillState extends State<ActionBadgePill> {
  static const _duration = Duration(milliseconds: 350);
  static const _textStyle = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
  static const _hPad = 10.0;
  static const _border = 0.8;
  static const _iconSize = 12.0;
  static const _iconGap = 5.0;
  static const _chevronSize = 14.0;

  Timer? _timer;
  int _index = 0;
  late List<CardPillModel> _pills;

  @override
  void initState() {
    super.initState();
    _syncPills();
    _scheduleNext();
  }

  @override
  void didUpdateWidget(covariant ActionBadgePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pills != oldWidget.pills) {
      _timer?.cancel();
      _index = 0;
      _syncPills();
      _scheduleNext();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncPills() {
    _pills = List<CardPillModel>.of(widget.pills)
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  void _scheduleNext() {
    if (_pills.length < 2) return;
    _timer = Timer(_pills[_index].duration * 2, () {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _pills.length);
      _scheduleNext();
    });
  }

  double _widthFor(BuildContext context, CardPillModel pill) {
    final span = TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: [
        MarkupParser.buildTextSpan(pill.title, defaultStyle: _textStyle),
      ],
    );
    final painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final icon = pill.iconUrl != null ? _iconSize + _iconGap : 0;
    return (painter.width +
            icon +
            2 * _hPad +
            2 * _border +
            _chevronSize)
        .ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (_pills.isEmpty) return const SizedBox.shrink();
    final pill = _pills[_index];
    final current = ValueKey(_index);

    return GestureDetector(
      onTap: () => showCtaFeedback(context, MarkupParser.toPlainText(pill.title)),
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeOutCubic,
        width: _widthFor(context, pill),
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
              child: AnimatedSwitcher(
                duration: _duration,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final fromBelow = child.key == current;
                  final slide = Tween(
                    begin: Offset(0, fromBelow ? 1.5 : -1.5),
                    end: Offset.zero,
                  ).animate(animation);
                  final opacity = Tween(begin: 0.0, end: 1.0).animate(animation);
                  return FadeTransition(
                    opacity: opacity,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: _PillContent(key: current, pill: pill),
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
  }
}

class _PillContent extends StatelessWidget {
  const _PillContent({super.key, required this.pill});

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
              width: _ActionBadgePillState._iconSize,
              height: _ActionBadgePillState._iconSize,
              errorWidget: (_, _, _) => const SizedBox(
                width: _ActionBadgePillState._iconSize,
                height: _ActionBadgePillState._iconSize,
              ),
            ),
            const SizedBox(width: _ActionBadgePillState._iconGap),
          ],
          Text.rich(
            MarkupParser.buildTextSpan(
              pill.title,
              defaultStyle: _ActionBadgePillState._textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
