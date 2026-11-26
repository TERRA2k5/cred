import 'dart:async';

import 'package:credd/Widgets/cards/ActionBadgePill.dart';
import 'package:credd/Widgets/cards/CreditCardItemView.dart';
import 'package:credd/Widgets/deck/DeckGeometryCalculator.dart';
import 'package:credd/Widgets/deck/DeckTransformFlowDelegate.dart';
import 'package:credd/models/CardPillModel.dart';
import 'package:credd/models/CreditCardModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InteractiveCardDeck extends StatefulWidget {
  const InteractiveCardDeck({
    super.key,
    required this.cards,
  });

  final List<CreditCardModel> cards;

  @override
  State<InteractiveCardDeck> createState() => _InteractiveCardDeckState();
}

class _InteractiveCardDeckState extends State<InteractiveCardDeck>
    with SingleTickerProviderStateMixin {
  static const _snapDuration = Duration(milliseconds: 320);

  final _scroll = ScrollController();
  late final AnimationController _pillFlip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    value: 1.0,
  );
  final _pillStep = ValueNotifier<int>(0);
  Timer? _pillTimer;
  DeckGeometryCalculator? _geometry;

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
      _scheduleNextPill();
    }
  }

  @override
  void dispose() {
    _pillTimer?.cancel();
    _pillFlip.dispose();
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

  void _onCardTap(int index) {
    final geometry = _geometry;
    if (geometry == null || !_scroll.hasClients) return;
    if (index > 0 && geometry.expandProgress(_scroll.offset) == 0) {
      _scroll.animateTo(
        geometry.expandDistance,
        duration: _snapDuration,
        curve: Curves.easeOut,
      );
    }
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
            physics: const ClampingScrollPhysics(),
            child: RepaintBoundary(
              child: Flow(
                delegate: DeckTransformFlowDelegate(
                  geometry: geometry,
                  scroll: _scroll,
                ),
                children: [
                  for (var i = 0; i < cards.length; i++)
                    RepaintBoundary(
                      key: ValueKey('card_$i'),
                      child: GestureDetector(
                        onTap: () => _onCardTap(i),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
