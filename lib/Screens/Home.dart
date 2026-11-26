import 'package:credd/Registry/SDUI_registry.dart';
import 'package:credd/Widgets/deck/InteractiveCardDeck.dart';
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
              return _buildSDUILayout(state.items);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSDUILayout(List<SDUIModel> items) {
    final linearWidgets = <Widget>[];
    final cards = <CreditCardModel>[];

    for (final item in items) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...linearWidgets,
        Expanded(
          child: cards.isEmpty
              ? const Center(child: Text('No cards added yet'))
              : InteractiveCardDeck(cards: cards),
        ),
      ],
    );
  }
}
