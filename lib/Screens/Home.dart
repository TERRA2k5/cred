import 'package:credd/Registry/SDUI_registry.dart';
import 'package:credd/bloc/SDUIBloc.dart';
import 'package:credd/bloc/SDUIState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:credd/models/SDUI_model.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SDUIBloc, SDUIState>(
          builder: (context, state) {
            if (state is SDUILoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (state is SDUIError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
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
    List<Widget> linearWidgets = [];
    List<SDUIModel> cardStackData = [];

    for (var item in items) {
      if (item.templateName == 'cm_card_instrument') {
        cardStackData.add(item);
      } else {
        linearWidgets.add(SDUIRegistry.buildComponent(item));
      }
    }

    return Column(
      children: [
        ...linearWidgets,

        if (cardStackData.isNotEmpty)
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'Interactive Card Stack Goes Here',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
      ],
    );
  }
}