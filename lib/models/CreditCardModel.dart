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
    this.isLight = false,
  });

  factory CreditCardModel.fromJson(Map<String, dynamic> json, {String? fallbackId}) {
    final body = json['body'] is Map<String, dynamic>
        ? json['body'] as Map<String, dynamic>
        : json;

    final asset1 = body['asset_1'] is Map<String, dynamic>
        ? body['asset_1'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final artUrl = asset1['url'] is String ? asset1['url'] as String : '';

    final asset3 = body['asset_3'] is Map<String, dynamic>
        ? body['asset_3'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final miniArtUrl = asset3['url'] is String ? asset3['url'] as String : '';

    final asset2 = body['asset_2'] is Map<String, dynamic>
        ? body['asset_2'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final logoUrl = asset2['url'] is String ? asset2['url'] as String : '';

    final statement = body['statement'] is Map<String, dynamic>
        ? body['statement'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final statementCta = statement['cta_1'] is Map<String, dynamic>
        ? statement['cta_1'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final payTitle = statementCta['title'] is String && (statementCta['title'] as String).isNotEmpty
        ? statementCta['title'] as String
        : 'Pay now';

    final id = body['instrument_id'] is String && (body['instrument_id'] as String).isNotEmpty
        ? body['instrument_id'] as String
        : (fallbackId ?? 'card_0');

    final masked = body['text_3'] is String ? body['text_3'] as String : '';
    final holder = body['text_4'] is String ? body['text_4'] as String : '';

    final amount = statement['text_1'] is String && (statement['text_1'] as String).isNotEmpty
        ? statement['text_1'] as String
        : null;

    final due = statement['text_2'] is String && (statement['text_2'] as String).isNotEmpty
        ? statement['text_2'] as String
        : null;

    return CreditCardModel(
      id: id,
      artUrl: artUrl,
      miniArtUrl: miniArtUrl,
      networkLogoUrl: logoUrl.isNotEmpty ? logoUrl : null,
      maskedNumber: masked,
      holderName: holder,
      amountText: amount,
      dueText: due,
      payCtaTitle: payTitle,
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
        isLight,
      ];
}
