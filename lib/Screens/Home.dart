import 'package:credd/Registry/SDUI_registry.dart';
import 'package:credd/Widgets/deck/InteractiveCardDeck.dart';
import 'package:credd/Widgets/sheets/CardInspectorModal.dart';
import 'package:credd/bloc/SDUIBloc.dart';
import 'package:credd/bloc/SDUIEvent.dart';
import 'package:credd/bloc/SDUIState.dart';
import 'package:credd/models/CreditCardModel.dart';
import 'package:credd/models/SDUI_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<SDUIBloc, SDUIState>(
          builder: (context, state) {
            if (state is SDUILoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black87),
              );
            } else if (state is SDUIError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load SDUI data:\n${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<SDUIBloc>().add(const FetchSDUIData()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is SDUILoaded) {
              return _SDUIContentView(items: state.items);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SDUIContentView extends StatefulWidget {
  const _SDUIContentView({required this.items});

  final List<SDUIModel> items;

  @override
  State<_SDUIContentView> createState() => _SDUIContentViewState();
}

class _SDUIContentViewState extends State<_SDUIContentView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _detail;
  final _rootKey = GlobalKey();

  int? _detailIndex;
  Rect? _detailSource;

  @override
  void initState() {
    super.initState();
    _detail = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      reverseDuration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  void _openDetail(int index, Rect globalRect) {
    final root = _rootKey.currentContext?.findRenderObject() as RenderBox?;
    if (root == null) return;
    setState(() {
      _detailIndex = index;
      _detailSource = root.globalToLocal(globalRect.topLeft) & globalRect.size;
    });
    _detail.forward(from: 0);
  }

  Future<void> _closeDetail() async {
    if (_detailIndex == null || _detail.status == AnimationStatus.reverse) {
      return;
    }
    await _detail.reverse();
    if (mounted) {
      setState(() {
        _detailIndex = null;
        _detailSource = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final linearWidgets = <Widget>[];
    final cards = <CreditCardModel>[];

    for (final item in widget.items) {
      if (item.templateName == 'cm_card_instrument') {
        cards.add(
          CreditCardModel.fromJson(
            item.templateProperties,
            fallbackId: 'card_${cards.length}',
          ),
        );
      } else {
        linearWidgets.add(SDUIRegistry.buildComponent(item));
      }
    }

    final activeDetailIndex =
        _detailIndex != null && _detailIndex! < cards.length
            ? _detailIndex
            : null;

    return PopScope(
      canPop: activeDetailIndex == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeDetail();
      },
      child: Stack(
        key: _rootKey,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...linearWidgets,
              Expanded(
                child: cards.isEmpty
                    ? const Center(child: Text('No cards added yet'))
                    : InteractiveCardDeck(
                        cards: cards,
                        hiddenIndex: activeDetailIndex,
                        onCardLongPress: _openDetail,
                      ),
              ),
            ],
          ),
          if (activeDetailIndex != null && _detailSource != null)
            Positioned.fill(
              child: CardInspectorModal(
                card: cards[activeDetailIndex],
                sourceRect: _detailSource!,
                animation: _detail,
                onDismiss: _closeDetail,
              ),
            ),
        ],
      ),
    );
  }
}
