import 'package:credd/Widgets/BalanceHeaderWidget.dart';
import 'package:credd/Widgets/PromoBannerWidget.dart';
import 'package:credd/Widgets/TopBarWidget.dart';
import 'package:credd/models/SDUI_model.dart';
import 'package:flutter/cupertino.dart';

class SDUIRegistry {
  static Widget buildComponent(SDUIModel component) {
    switch (component.templateName) {
      case 'cm_top_bar':
        return TopBarWidget(data: component.templateProperties);
      case 'unbilled_statement_info_section_v2':
        return BalanceHeaderWidget(data: component.templateProperties);
      case 'unbilled_statement_info_section_offer_2':
        return PromoBannerWidget(data: component.templateProperties);
    // cm_card_instrument is deliberately omitted here. See Step 3.
      default:
        return const SizedBox.shrink(); // Fallback for unknown templates
    }
  }
}