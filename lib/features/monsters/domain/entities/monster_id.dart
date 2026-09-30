import 'package:mh_wiki/core/domain/game.dart';

/// Identity of a monster: unique per (game, slug) (constitution Principle V).
final class MonsterId {
  const MonsterId(this.game, this.slug);

  final Game game;
  final String slug;

  @override
  bool operator ==(Object other) =>
      other is MonsterId && other.game == game && other.slug == slug;

  @override
  int get hashCode => Object.hash(game, slug);

  @override
  String toString() => '${game.datasetKey}/$slug';
}
