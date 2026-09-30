import 'package:mh_wiki/core/domain/rank.dart';

/// Supported games, declared in display order.
enum Game {
  worldIceborne('world_iceborne', [Rank.low, Rank.high, Rank.master]),
  riseSunbreak('rise_sunbreak', [Rank.low, Rank.high, Rank.master]),
  wilds('wilds', [Rank.low, Rank.high]);

  const Game(this.datasetKey, this.allowedRanks);

  /// Asset folder name and value of the dataset `game` field.
  final String datasetKey;

  /// Ranks that exist in this game.
  final List<Rank> allowedRanks;

  int get displayOrder => index;

  static Game? fromDatasetKey(String key) {
    for (final game in values) {
      if (game.datasetKey == key) return game;
    }
    return null;
  }
}
