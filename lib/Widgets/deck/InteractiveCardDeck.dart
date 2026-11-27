import 'dart:async';

import 'package:credd/Widgets/cards/ActionBadgePill.dart';
import 'package:credd/Widgets/cards/CreditCardItemView.dart';
import 'package:credd/Widgets/deck/DeckGeometryCalculator.dart';
import 'package:credd/Widgets/deck/DeckTransformFlowDelegate.dart';
import 'package:credd/Widgets/deck/QuickActionMatrix.dart';
import 'package:credd/models/CardPillModel.dart';
import 'package:credd/models/CreditCardModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CardLongPressCallback = void Function(int index, Rect globalRect);

class InteractiveCardDeck extends StatefulWidget {
  const InteractiveCardDeck({
    super.key,
    required this.cards,
    this.onCardLongPress,
    this.hiddenIndex,
  });

  final List<CreditCardModel> cards;
  final CardLongPressCallback? onCardLongPress;
  final int? hiddenIndex;

  @override
  State<InteractiveCardDeck> createState() => _InteractiveCardDeckState();
}

class _InteractiveCardDeckState extends State<InteractiveCardDeck>
    with TickerProviderStateMixin {
  static const _snapDuration = Duration(milliseconds: 320);

  final _scroll = ScrollController();
  late final AnimationController _pillFlip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    value: 1.0,
  );
  late final AnimationController _swipe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  )..addStatusListener(_onSwipeStatus);

  final _pillStep = ValueNotifier<int>(0);
  Timer? _pillTimer;
  DeckGeometryCalculator? _geometry;
  bool _swipeOpen = false;
  int _swipedIndex = 0;

  bool get _atRest => !_scroll.hasClients || _scroll.offset <= 0;

  bool _canSwipe(int index) {
    final geometry = _geometry;
    if (geometry == null) return false;
    if (_atRest) return index == 0;
    return geometry.expandProgress(_scroll.offset) >= 1;
  }

  @override
  void initState() {
    super.initState();
    _scheduleNextPill();
  }

  @override
  void didUpdateWidget(covariant InteractiveCardDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.cards, oldWidget.cards)) {
      _pillStep.value = 0;
      _pillFlip.value = 1.0;
      _swipedIndex = 0;
      _swipe.value = 0.0;
      _scheduleNextPill();
    }
  }

  @override
  void dispose() {
    _pillTimer?.cancel();
    _pillFlip.dispose();
    _swipe.dispose();
    _pillStep.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<CardPillModel>? _referencePills() {
    for (final card in widget.cards) {
      if (card.pills.length >= 2) return card.pills;
    }
    return null;
  }

  void _scheduleNextPill() {
    _pillTimer?.cancel();
    final pills = _referencePills();
    if (pills == null) return;
    final current = pills[_pillStep.value % pills.length];
    _pillTimer = Timer(current.duration * 2, () {
      if (!mounted) return;
      _pillStep.value += 1;
      _pillFlip.forward(from: 0.0);
      _scheduleNextPill();
    });
  }

  void _onSwipeStatus(AnimationStatus status) {
    final open = status != AnimationStatus.dismissed;
    if (open == _swipeOpen) return;
    setState(() {
      _swipeOpen = open;
    });
  }

  void _settleSwipe({required bool open}) {
    if (open) {
      _swipe.animateTo(1, curve: Curves.easeOut);
    } else {
      _swipe.animateBack(0, curve: Curves.easeOut);
    }
  }

  void _onSwipeStart(int index, DragStartDetails details) {
    if (!_canSwipe(index)) return;
    if (_swipe.value > 0 && _swipedIndex != index) return;
    if (_swipedIndex != index) {
      setState(() {
        _swipedIndex = index;
      });
    }
  }

  void _onSwipeUpdate(int index, DragUpdateDetails details) {
    final geometry = _geometry;
    if (geometry == null || !_canSwipe(index) || _swipedIndex != index) return;
    _swipe.value -= (details.primaryDelta ?? 0) / (geometry.cardWidth * 0.7);
  }

  void _onSwipeEnd(int index, DragEndDetails details) {
    if (!_canSwipe(index) || _swipedIndex != index) return;
    final velocity = details.primaryVelocity ?? 0;
    final open =
        velocity < -300 || (velocity.abs() <= 300 && _swipe.value > 0.4);
    _settleSwipe(open: open);
  }

  void _onSwipeCancel(int index) {
    if (_swipedIndex != index || _swipe.value <= 0 || _swipe.value >= 1) return;
    _settleSwipe(open: _swipe.value > 0.4);
  }

  void _onCardTap(int index) {
    final geometry = _geometry;
    if (geometry == null || !_scroll.hasClients) return;
    if (_swipe.value > 0) {
      _settleSwipe(open: false);
    } else if (index > 0 && geometry.expandProgress(_scroll.offset) == 0) {
      _scroll.animateTo(
        geometry.expandDistance,
        duration: _snapDuration,
        curve: Curves.easeOut,
      );
    }
  }

  void _onCardLongPress(int index) {
    final geometry = _geometry;
    if (geometry == null || _swipe.value > 0) return;
    final offset = _scroll.hasClients ? _scroll.offset : 0.0;
    if (index != 0 && geometry.expandProgress(offset) < 1) return;

    final box = context.findRenderObject()! as RenderBox;
    final slot = geometry.slotFor(index, offset);
    final topLeft = box.localToGlobal(
      Offset(DeckGeometryCalculator.horizontalPadding, slot.top),
    );
    HapticFeedback.mediumImpact();
    widget.onCardLongPress?.call(
      index,
      topLeft & Size(geometry.cardWidth, geometry.cardHeight),
    );
  }

  bool _onScrollEnd(ScrollEndNotification notification) {
    final geometry = _geometry;
    if (geometry == null || !_scroll.hasClients) return false;
    final offset = _scroll.offset;
    final distance = geometry.expandDistance;
    if (offset > 0 && offset < distance) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scroll.hasClients) return;
        _scroll.animateTo(
          offset < distance / 2 ? 0 : distance,
          duration: _snapDuration,
          curve: Curves.easeOut,
        );
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    return LayoutBuilder(
      builder: (context, constraints) {
        final geometry = DeckGeometryCalculator(
          width: constraints.maxWidth,
          viewportHeight: constraints.maxHeight,
          count: cards.length,
        );
        _geometry = geometry;

        return NotificationListener<ScrollEndNotification>(
          onNotification: _onScrollEnd,
          child: SingleChildScrollView(
            key: const Key('card_stack_scroll'),
            controller: _scroll,
            physics: _swipeOpen
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            child: RepaintBoundary(
              child: Flow(
                delegate: DeckTransformFlowDelegate(
                  geometry: geometry,
                  scroll: _scroll,
                  swipe: _swipe,
                  swipedIndex: _swipedIndex,
                  hiddenIndex: widget.hiddenIndex,
                ),
                children: [
                  for (var i = 0; i < cards.length; i++)
                    RepaintBoundary(
                      key: ValueKey('card_$i'),
                      child: GestureDetector(
                        onTap: () => _onCardTap(i),
                        onLongPress: () => _onCardLongPress(i),
                        onHorizontalDragStart: (d) => _onSwipeStart(i, d),
                        onHorizontalDragUpdate: (d) => _onSwipeUpdate(i, d),
                        onHorizontalDragEnd: (d) => _onSwipeEnd(i, d),
                        onHorizontalDragCancel: () => _onSwipeCancel(i),
                        child: CreditCardItemView(card: cards[i]),
                      ),
                    ),
                  for (var i = 0; i < cards.length; i++)
                    RepaintBoundary(
                      key: ValueKey('pill_$i'),
                      child: Center(
                        child: ActionBadgePill(
                          pills: cards[i].pills,
                          flipAnimation: _pillFlip,
                          step: _pillStep,
                        ),
                      ),
                    ),
                  RepaintBoundary(
                    key: const Key('action_grid'),
                    child: QuickActionMatrix(
                      swipe: _swipe,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
