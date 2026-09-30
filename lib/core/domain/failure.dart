import 'package:mh_wiki/core/domain/game.dart';

/// Expected failures, modeled explicitly instead of reaching the UI as exceptions.
sealed class Failure {
  const Failure();
}

final class DatasetUnavailable extends Failure {
  const DatasetUnavailable(this.game);

  final Game game;
}

final class DatasetFormatInvalid extends Failure {
  const DatasetFormatInvalid(this.game, this.detail);

  final Game game;
  final String detail;
}

final class UnsupportedSchemaVersion extends Failure {
  const UnsupportedSchemaVersion(this.game, this.found);

  final Game game;
  final int found;
}

final class MonsterNotFound extends Failure {
  const MonsterNotFound(this.game, this.slug);

  final Game game;
  final String slug;
}

final class PreferenceStorageFailure extends Failure {
  const PreferenceStorageFailure(this.detail);

  final String detail;
}
