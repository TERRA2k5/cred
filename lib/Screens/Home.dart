import 'package:credd/Registry/SDUI_registry.dart';
import 'package:credd/bloc/SDUIBloc.dart';
import 'package:credd/bloc/SDUIEvent.dart';
import 'package:credd/bloc/SDUIState.dart';
import 'package:credd/models/SDUI_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: BlocBuilder<SDUIBloc, SDUIState>(
          builder: (context, state) {
            if (state is SDUILoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
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
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<SDUIBloc>().add(const FetchSDUIData()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
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

  // The Interceptor Logic
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
          if (cardStackData.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(24.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'Interactive Card Stack (${cardStackData.length} cards received)',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }
}
