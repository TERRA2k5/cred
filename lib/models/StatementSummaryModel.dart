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
    final cta2 = json['cta_2'] is Map<String, dynamic>
        ? json['cta_2'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return StatementSummaryModel(
      label: json['text_3'] is String && (json['text_3'] as String).isNotEmpty
          ? json['text_3'] as String
          : fallbackLabel,
      title: json['text_1'] is String && (json['text_1'] as String).isNotEmpty
          ? json['text_1'] as String
          : fallbackTitle,
      amountText: json['text_2'] is String && (json['text_2'] as String).isNotEmpty
          ? json['text_2'] as String
          : fallbackAmountText,
      amount: json['amount'] is num ? (json['amount'] as num).toDouble() : 0.0,
      badgeCount: json['due_count'] is num ? (json['due_count'] as num).toInt() : 0,
      ctaTitle: cta2['title'] is String && (cta2['title'] as String).isNotEmpty
          ? cta2['title'] as String
          : fallbackCtaTitle,
    );
  }

  @override
  List<Object?> get props => [label, title, amountText, amount, badgeCount, ctaTitle];
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
    final body = data['body'] is Map<String, dynamic>
        ? data['body'] as Map<String, dynamic>
        : data;

    final asset1 = body['asset_1'] is Map<String, dynamic>
        ? body['asset_1'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final bgUrl = asset1['url'] is String ? asset1['url'] as String : '';

    final cta1 = body['cta_1'] is Map<String, dynamic>
        ? body['cta_1'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final cta1Asset = cta1['asset'] is Map<String, dynamic>
        ? cta1['asset'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final leftUrl = cta1Asset['url'] is String ? cta1Asset['url'] as String : '';

    final cta2 = body['cta_2'] is Map<String, dynamic>
        ? body['cta_2'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final cta2Asset = cta2['asset'] is Map<String, dynamic>
        ? cta2['asset'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final rightUrl = cta2Asset['url'] is String ? cta2Asset['url'] as String : '';

    final statementJson = body['statement'] is Map<String, dynamic>
        ? body['statement'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final unbilledJson = body['unbilled'] is Map<String, dynamic>
        ? body['unbilled'] as Map<String, dynamic>
        : const <String, dynamic>{};

    Map<String, dynamic>? offerProps;
    final childList = data['child_list'] is List
        ? data['child_list'] as List
        : (body['child_list'] is List ? body['child_list'] as List : const []);
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
        statementJson,
        fallbackLabel: 'TOTAL DUE',
        fallbackTitle: 'STATEMENT DUE FOR 1 CARD',
        fallbackAmountText: '₹50,000.00',
        fallbackCtaTitle: 'PAY BILL',
      ),
      unbilled: StatementSummaryModel.fromJson(
        unbilledJson,
        fallbackLabel: 'RECENT SPENDS',
        fallbackTitle: 'RECENT SPENDS',
        fallbackAmountText: '₹0.00',
        fallbackCtaTitle: 'View transactions',
      ),
      leftIconUrl: leftUrl,
      rightIconUrl: rightUrl,
      backgroundUrl: bgUrl,
      offerProperties: offerProps,
    );
  }

  @override
  List<Object?> get props => [statement, unbilled, leftIconUrl, rightIconUrl, backgroundUrl, offerProperties];
}
