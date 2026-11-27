import 'package:credd/core/utils/JsonExt.dart';
import 'package:equatable/equatable.dart';

class StatementSummaryModel extends Equatable {
  final String label;
  final String title;
  final String amountText;
  final double amount;
  final int badgeCount;
  final String ctaTitle;

  const StatementSummaryModel({
    required this.label,
    required this.title,
    required this.amountText,
    required this.amount,
    required this.badgeCount,
    required this.ctaTitle,
  });

  factory StatementSummaryModel.fromJson(
    Map<String, dynamic> json, {
    String fallbackLabel = '',
    String fallbackTitle = '',
    String fallbackAmountText = '₹0.00',
    String fallbackCtaTitle = '',
  }) {
    return StatementSummaryModel(
      label: json.str('text_3', fallbackLabel),
      title: json.str('text_1', fallbackTitle),
      amountText: json.str('text_2', fallbackAmountText),
      amount: json.numDouble('amount'),
      badgeCount: json.integer('due_count'),
      ctaTitle: json.nested('cta_2').str('title', fallbackCtaTitle),
    );
  }

  @override
  List<Object?> get props =>
      [label, title, amountText, amount, badgeCount, ctaTitle];
}

class StatementHeaderModel extends Equatable {
  final StatementSummaryModel statement;
  final StatementSummaryModel unbilled;
  final String leftIconUrl;
  final String rightIconUrl;
  final String backgroundUrl;
  final Map<String, dynamic>? offerProperties;

  const StatementHeaderModel({
    required this.statement,
    required this.unbilled,
    required this.leftIconUrl,
    required this.rightIconUrl,
    required this.backgroundUrl,
    this.offerProperties,
  });

  factory StatementHeaderModel.fromJson(Map<String, dynamic> data) {
    final body = data.bodyOrSelf;

    Map<String, dynamic>? offerProps;
    final childList =
        data['child_list'] is List ? data.list('child_list') : body.list('child_list');
    for (final child in childList) {
      if (child is Map<String, dynamic> &&
          child['template_name'] == 'unbilled_statement_info_section_offer_2') {
        offerProps = child['template_properties'] is Map<String, dynamic>
            ? child['template_properties'] as Map<String, dynamic>
            : null;
        break;
      }
    }

    return StatementHeaderModel(
      statement: StatementSummaryModel.fromJson(
        body.nested('statement'),
        fallbackLabel: 'TOTAL DUE',
        fallbackTitle: 'STATEMENT DUE FOR 1 CARD',
        fallbackAmountText: '₹50,000.00',
        fallbackCtaTitle: 'PAY BILL',
      ),
      unbilled: StatementSummaryModel.fromJson(
        body.nested('unbilled'),
        fallbackLabel: 'RECENT SPENDS',
        fallbackTitle: 'RECENT SPENDS',
        fallbackAmountText: '₹0.00',
        fallbackCtaTitle: 'View transactions',
      ),
      leftIconUrl: body.nested('cta_1').assetUrl('asset'),
      rightIconUrl: body.nested('cta_2').assetUrl('asset'),
      backgroundUrl: body.assetUrl('asset_1'),
      offerProperties: offerProps,
    );
  }

  @override
  List<Object?> get props => [
        statement,
        unbilled,
        leftIconUrl,
        rightIconUrl,
        backgroundUrl,
        offerProperties,
      ];
}
