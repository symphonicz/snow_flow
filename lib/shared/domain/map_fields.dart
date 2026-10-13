/// Helpers for `fromMap`: a missing field or a field of the wrong type is a
/// broken box, reported as [FormatException] so the app can show the problem
/// screen instead of deleting data (ADR 0002).
library;

/// The value of [key], which must be a [T].
T requireField<T>(Map<dynamic, dynamic> map, String key) {
  final value = map[key];
  if (value is T) return value;
  throw FormatException('Field "$key" must be $T, got ${value.runtimeType}');
}

/// The value of [key], or [fallback] when the field is missing or null.
T optionalField<T>(Map<dynamic, dynamic> map, String key, T fallback) =>
    map[key] == null ? fallback : requireField<T>(map, key);

/// The result of [parse] on the text in [key]; throws when it gives null.
T parseField<T>(
  Map<dynamic, dynamic> map,
  String key,
  T? Function(String) parse,
) {
  final text = requireField<String>(map, key);
  return parse(text) ??
      (throw FormatException('Field "$key" has an unknown value "$text"'));
}

/// Like [parseField], but [fallback] when the field is missing or null.
T parseOptionalField<T>(
  Map<dynamic, dynamic> map,
  String key,
  T? Function(String) parse,
  T fallback,
) => map[key] == null ? fallback : parseField(map, key, parse);
