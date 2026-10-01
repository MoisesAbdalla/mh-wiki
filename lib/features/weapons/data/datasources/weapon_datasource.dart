import 'package:mh_wiki/core/domain/game.dart';

/// Source of raw weapon datasets; swappable local ↔ remote (Principle IV).
abstract interface class WeaponDatasource {
  /// Returns the decoded JSON map of one game's weapon dataset.
  ///
  /// Throws `DatasetUnavailableException` or `DatasetFormatException`.
  Future<Map<String, Object?>> fetchDataset(Game game);
}
