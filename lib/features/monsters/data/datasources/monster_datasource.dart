import 'package:mh_wiki/core/domain/game.dart';

/// Source of raw monster datasets; swappable local ↔ remote (Principle IV).
abstract interface class MonsterDatasource {
  /// Returns the decoded JSON map of one game's dataset.
  ///
  /// Throws [DatasetUnavailableException] or [DatasetFormatException].
  Future<Map<String, Object?>> fetchDataset(Game game);
}

class DatasetUnavailableException implements Exception {
  DatasetUnavailableException(this.message);

  final String message;

  @override
  String toString() => 'DatasetUnavailableException: $message';
}

class DatasetFormatException implements Exception {
  DatasetFormatException(this.message);

  final String message;

  @override
  String toString() => 'DatasetFormatException: $message';
}

class UnsupportedSchemaVersionException implements Exception {
  UnsupportedSchemaVersionException(this.found);

  final int found;

  @override
  String toString() => 'UnsupportedSchemaVersionException: $found';
}
