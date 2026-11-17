import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TextSpanSegment extends Equatable {
  const TextSpanSegment(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  List<Object?> get props => [text, color];
}

abstract final class MarkupParser {
  static final _wrapper = RegExp(r'</?format>');
  static final _textTag = RegExp(r'<text([^>]*)>(.*?)</text>', dotAll: true);
  static final _fgColor = RegExp(r'''fgClr\s*=\s*["']#?([0-9a-fA-F]{6}|[0-9a-fA-F]{8})["']''');
  static final _amountRegex = RegExp(r'₹\s?\d[\d,]*(\.\d+)?');

  static List<TextSpanSegment> parse(String raw) {
    if (raw.isEmpty) return const [];
    final source = raw.replaceAll(_wrapper, '');
    final segments = <TextSpanSegment>[];
    var cursor = 0;
    for (final match in _textTag.allMatches(source)) {
      if (match.start > cursor) {
        segments.add(TextSpanSegment(source.substring(cursor, match.start)));
      }
      segments.add(TextSpanSegment(match.group(2)!, color: _color(match.group(1)!)));
      cursor = match.end;
    }
    if (cursor < source.length) {
      segments.add(TextSpanSegment(source.substring(cursor)));
    }
    return segments.where((s) => s.text.isNotEmpty).toList(growable: false);
  }

  static String toPlainText(List<TextSpanSegment> segments) =>
      segments.map((s) => s.text).join();

  static TextSpan buildTextSpan(
    List<TextSpanSegment> segments, {
    TextStyle? defaultStyle,
    bool boldAmounts = false,
  }) {
    final spans = <InlineSpan>[];

    for (final segment in segments) {
      final baseStyle = (defaultStyle ?? const TextStyle()).copyWith(
        color: segment.color ?? defaultStyle?.color,
      );

      if (!boldAmounts) {
        spans.add(TextSpan(text: segment.text, style: baseStyle));
      } else {
        var cursor = 0;
        for (final match in _amountRegex.allMatches(segment.text)) {
          if (match.start > cursor) {
            spans.add(
              TextSpan(
                text: segment.text.substring(cursor, match.start),
                style: baseStyle,
              ),
            );
          }
          spans.add(
            TextSpan(
              text: match.group(0),
              style: baseStyle.copyWith(fontWeight: FontWeight.w800),
            ),
          );
          cursor = match.end;
        }
        if (cursor < segment.text.length) {
          spans.add(
            TextSpan(
              text: segment.text.substring(cursor),
              style: baseStyle,
            ),
          );
        }
      }
    }

    return TextSpan(children: spans, style: defaultStyle);
  }

  static Color? _color(String attributes) {
    final hex = _fgColor.firstMatch(attributes)?.group(1);
    if (hex == null) return null;
    final value = int.parse(hex, radix: 16);
    return Color(hex.length == 6 ? 0xFF000000 | value : value);
  }
}
