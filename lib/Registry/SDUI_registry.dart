import 'package:credd/Widgets/BalanceHeaderWidget.dart';
import 'package:credd/Widgets/PromoBannerWidget.dart';
import 'package:credd/Widgets/TopBarWidget.dart';
import 'package:credd/models/CreditCardModel.dart';
import 'package:credd/models/SDUI_model.dart';
import 'package:flutter/widgets.dart';

/// Partitioned SDUI screen payload separating linear header components from cards.
class SDUIScreenPartition {
  const SDUIScreenPartition({
    required this.headerItems,
    required this.cards,
  });

  final List<SDUIModel> headerItems;
  final List<CreditCardModel> cards;
}

class SDUIRegistry {
  static const cardInstrumentTemplate = 'cm_card_instrument';

  static SDUIScreenPartition partition(List<SDUIModel> items) {
    final headerItems = <SDUIModel>[];
    final cards = <CreditCardModel>[];

    for (final item in items) {
      if (item.templateName == cardInstrumentTemplate) {
        cards.add(
          CreditCardModel.fromJson(
            item.templateProperties,
            fallbackId: 'card_${cards.length}',
          ),
        );
      } else {
        headerItems.add(item);
      }
    }

    return SDUIScreenPartition(
      headerItems: List.unmodifiable(headerItems),
      cards: List.unmodifiable(cards),
    );
  }

  static Widget buildComponent(SDUIModel component) {
    switch (component.templateName) {
      case 'cm_top_bar':
        return TopBarWidget(data: component.templateProperties);
      case 'unbilled_statement_info_section_v2':
        return BalanceHeaderWidget(data: component.templateProperties);
      case 'unbilled_statement_info_section_offer_2':
        return PromoBannerWidget(data: component.templateProperties);
      default:
        return const SizedBox.shrink(); // Fallback for unknown templates
    }
  }
}
