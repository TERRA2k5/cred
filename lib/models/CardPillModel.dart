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
    final cta = json['cta_1'] is Map<String, dynamic>
        ? json['cta_1'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final asset = cta['asset'] is Map<String, dynamic>
        ? cta['asset'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final rawTitle = cta['title'] is String ? cta['title'] as String : '';
    final rawIconUrl = asset['url'] is String ? asset['url'] as String : '';
    final durationMs = json['duration'] is num ? (json['duration'] as num).toInt() : 0;
    final priority = json['priority'] is num ? (json['priority'] as num).toInt() : 0;

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
      iconUrl: rawIconUrl.isEmpty ? null : rawIconUrl,
    );
  }

  @override
  List<Object?> get props => [type, title, priority, duration, iconUrl];
}
