import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';

/// Typed access to a decoded JSON object that reports errors with their path
/// as [DatasetFormatException] instead of raw type errors.
final class JsonReader {
  JsonReader(this.json, this.path);

  final Map<String, Object?> json;
  final String path;

  Never fail(String message) => throw DatasetFormatException('$path: $message');

  bool has(String key) => json.containsKey(key) && json[key] != null;

  T _required<T>(String key) {
    final value = json[key];
    if (value == null) fail('missing "$key"');
    if (value is! T) fail('"$key" must be $T');
    return value as T;
  }

  String string(String key) {
    final value = _required<String>(key);
    if (value.isEmpty) fail('"$key" must not be empty');
    return value;
  }

  String? optionalString(String key) => has(key) ? string(key) : null;

  bool boolean(String key) => _required<bool>(key);

  num number(String key) => _required<num>(key);

  num? optionalNumber(String key) => has(key) ? number(key) : null;

  JsonReader object(String key) => JsonReader(
    _objectFrom(_required<Object>(key), '$path.$key'),
    '$path.$key',
  );

  JsonReader? optionalObject(String key) => has(key) ? object(key) : null;

  List<JsonReader> objects(String key) {
    final list = _required<List<Object?>>(key);
    return [
      for (var i = 0; i < list.length; i++)
        JsonReader(_objectFrom(list[i], '$path.$key[$i]'), '$path.$key[$i]'),
    ];
  }

  List<JsonReader> optionalObjects(String key) =>
      has(key) ? objects(key) : const [];

  List<String> strings(String key) {
    final list = _required<List<Object?>>(key);
    return [
      for (final item in list)
        if (item is String) item else fail('"$key" must contain strings'),
    ];
  }

  /// Parses a value into one of [values] by its enum `name`.
  T enumValue<T extends Enum>(String key, List<T> values) {
    final raw = string(key);
    for (final value in values) {
      if (value.name == raw) return value;
    }
    fail('"$key" has unknown value "$raw"');
  }

  Map<String, Object?> _objectFrom(Object? value, String at) {
    if (value is Map<String, Object?>) return value;
    throw DatasetFormatException('$at: must be an object');
  }
}
