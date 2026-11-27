import 'package:credd/core/utils/JsonExt.dart';
import 'package:credd/core/utils/MarkupParser.dart';
import 'package:equatable/equatable.dart';

enum PillType { pendingAction, viewDetails, unknown }

class CardPillModel extends Equatable {
  const CardPillModel({
    required this.type,
    required this.title,
    required this.priority,
    required this.duration,
    this.iconUrl,
  });

  final PillType type;
  final List<TextSpanSegment> title;
  final int priority;
  final Duration duration;
  final String? iconUrl;

  factory CardPillModel.fromJson(Map<String, dynamic> json) {
    final cta = json.nested('cta_1');
    final rawTitle = cta.str('title');
    final durationMs = json.integer('duration');
    final priority = json.integer('priority');

    final type = switch (json['type']) {
      'pending_action' => PillType.pendingAction,
      'view_details' => PillType.viewDetails,
      _ => PillType.unknown,
    };

    return CardPillModel(
      type: type,
      title: MarkupParser.parse(rawTitle),
      priority: priority,
      duration: Duration(milliseconds: durationMs > 0 ? durationMs : 1000),
      iconUrl: cta.nested('asset').strOrNull('url'),
    );
  }

  @override
  List<Object?> get props => [type, title, priority, duration, iconUrl];
}
