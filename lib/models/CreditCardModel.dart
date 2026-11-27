import 'package:credd/core/utils/JsonExt.dart';
import 'package:credd/models/CardPillModel.dart';
import 'package:equatable/equatable.dart';

class CreditCardModel extends Equatable {
  final String id;
  final String artUrl;
  final String miniArtUrl;
  final String? networkLogoUrl;
  final String maskedNumber;
  final String holderName;
  final String? amountText;
  final String? dueText;
  final String payCtaTitle;
  final List<CardPillModel> pills;
  final bool isLight;

  const CreditCardModel({
    required this.id,
    required this.artUrl,
    required this.miniArtUrl,
    this.networkLogoUrl,
    required this.maskedNumber,
    required this.holderName,
    this.amountText,
    this.dueText,
    this.payCtaTitle = 'Pay now',
    this.pills = const [],
    this.isLight = false,
  });

  factory CreditCardModel.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    final body = json.bodyOrSelf;
    final statement = body.nested('statement');

    final pills = body
        .list('flipper_pill')
        .whereType<Map<String, dynamic>>()
        .map(CardPillModel.fromJson)
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return CreditCardModel(
      id: body.str('instrument_id', fallbackId ?? 'card_0'),
      artUrl: body.assetUrl('asset_1'),
      miniArtUrl: body.assetUrl('asset_3'),
      networkLogoUrl: body.nested('asset_2').strOrNull('url'),
      maskedNumber: body.str('text_3'),
      holderName: body.str('text_4'),
      amountText: statement.strOrNull('text_1'),
      dueText: statement.strOrNull('text_2'),
      payCtaTitle: statement.nested('cta_1').str('title', 'Pay now'),
      pills: List.unmodifiable(pills),
      isLight: body['is_light'] == true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        artUrl,
        miniArtUrl,
        networkLogoUrl,
        maskedNumber,
        holderName,
        amountText,
        dueText,
        payCtaTitle,
        pills,
        isLight,
      ];
}
