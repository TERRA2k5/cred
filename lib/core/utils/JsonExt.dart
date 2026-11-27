/// Safe typed lookup helpers for loosely structured SDUI JSON maps.
extension JsonMapExt on Map<String, dynamic> {
  /// Returns `this['body']` when it is a map, otherwise returns `this`.
  Map<String, dynamic> get bodyOrSelf =>
      this['body'] is Map<String, dynamic>
          ? this['body'] as Map<String, dynamic>
          : this;

  /// Returns a nested map at [key], or an empty map if absent or mistyped.
  Map<String, dynamic> nested(String key) =>
      this[key] is Map<String, dynamic>
          ? this[key] as Map<String, dynamic>
          : const <String, dynamic>{};

  /// Returns a nested list at [key], or an empty list if absent or mistyped.
  List<dynamic> list(String key) =>
      this[key] is List ? this[key] as List<dynamic> : const <dynamic>[];

  /// Returns a non-empty string at [key], or [fallback].
  String str(String key, [String fallback = '']) {
    final value = this[key];
    return value is String && value.isNotEmpty ? value : fallback;
  }

  /// Returns a non-empty string at [key], or `null`.
  String? strOrNull(String key) {
    final value = this[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  /// Returns an integer value at [key], or [fallback].
  int integer(String key, [int fallback = 0]) {
    final value = this[key];
    return value is num ? value.toInt() : fallback;
  }

  /// Returns a double value at [key], or [fallback].
  double numDouble(String key, [double fallback = 0.0]) {
    final value = this[key];
    return value is num ? value.toDouble() : fallback;
  }

  /// Reads the `url` string from a nested asset map at [key].
  String assetUrl(String key) => nested(key).str('url');
}
