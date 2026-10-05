import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';

/// Every curated build of one game.
final class BuildCatalog {
  const BuildCatalog({required this.game, required this.builds});

  final Game game;
  final List<CuratedBuild> builds;
}

abstract interface class BuildRepository {
  /// Never throws: a broken dataset is an `Err` that only the Assistente
  /// shows (008 FR-009).
  Future<Result<BuildCatalog>> loadCatalog(Game game);
}

/// The builds the user saved, on the device.
abstract interface class SavedBuildsRepository {
  Future<List<SavedBuild>> load();

  /// Writes the whole list; returns `false` when the device refused.
  Future<bool> store(List<SavedBuild> builds);
}

/// The progress and weapon type chosen in the Assistente.
typedef AssistantPrefs = ({Progress progress, String? weaponType});

abstract interface class AssistantPrefsRepository {
  Future<AssistantPrefs> load();

  Future<void> store(AssistantPrefs prefs);
}

final class LoadBuildCatalog {
  const LoadBuildCatalog(this._repository);

  final BuildRepository _repository;

  Future<Result<BuildCatalog>> call(Game game) => _repository.loadCatalog(game);
}

/// The builds of [weaponType] for [progress] (008 FR-005): `now` holds the
/// stages up to the progress, latest first; `next` the later ones, nearest
/// first.
({List<CuratedBuild> now, List<CuratedBuild> next}) splitBuilds(
  Iterable<CuratedBuild> builds,
  Progress progress,
  String weaponType,
) {
  final ofType = [
    for (final b in builds)
      if (b.weaponType == weaponType) b,
  ];
  final now = [
    for (final b in ofType)
      if (b.stage <= progress) b,
  ]..sort((a, b) => b.stage.compareTo(a.stage));
  final next = [
    for (final b in ofType)
      if (!(b.stage <= progress)) b,
  ]..sort((a, b) => a.stage.compareTo(b.stage));
  return (now: now, next: next);
}
