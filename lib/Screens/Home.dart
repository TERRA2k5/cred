import 'package:credd/Registry/SDUI_registry.dart';
import 'package:credd/Widgets/cards/ActionBadgePill.dart';
import 'package:credd/Widgets/cards/CreditCardItemView.dart';
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
    final cardStackData = <SDUIModel>[];

    for (final item in items) {
      if (item.templateName == 'cm_card_instrument') {
        cardStackData.add(item);
      } else {
        linearWidgets.add(SDUIRegistry.buildComponent(item));
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...linearWidgets,
          const SizedBox(height: 12),
          for (var i = 0; i < cardStackData.length; i++)
            _buildCardItem(cardStackData[i], i),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCardItem(SDUIModel item, int index) {
    final card = CreditCardModel.fromJson(
      item.templateProperties,
      fallbackId: 'card_$index',
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1244 / 716,
            child: CreditCardItemView(card: card),
          ),
          if (index == 0 && card.pills.isNotEmpty)
            SizedBox(
              height: 44.0,
              child: Center(
                child: ActionBadgePill(pills: card.pills),
              ),
            ),
        ],
      ),
    );
  }
}
