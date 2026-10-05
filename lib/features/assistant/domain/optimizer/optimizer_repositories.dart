import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_search.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';

abstract interface class OptimizerRepository {
  /// Never throws: a broken dataset is an `Err` that only Montar build shows.
  Future<Result<OptimizerCatalog>> loadCatalog(Game game);
}

/// The user's talismans, on the device (009 US3).
abstract interface class TalismanRepository {
  Future<List<UserTalisman>> load();

  /// Writes the whole list; returns `false` when the device refused.
  Future<bool> store(List<UserTalisman> talismans);
}

/// The parts of a request kept between sessions; the progress and weapon
/// type come from the Assistente's own preferences.
typedef StoredRequest = ({
  Map<String, int> skills,
  String? fixedWeaponId,
  bool useTalismans,
  bool onlyMyProgress,
});

abstract interface class RequestRepository {
  Future<StoredRequest> load();

  Future<void> store(StoredRequest request);
}

/// Runs [searchBuilds] away from the UI (009 FR-010).
abstract interface class BuildSearcher {
  /// Completes with the results, or `null` when [cancel] was called.
  Future<List<BuildSet>?> search(
    OptimizerCatalog catalog,
    BuildRequest request,
    List<UserTalisman> talismans, {
    SearchProgress? onProgress,
  });

  void cancel();
}

final class LoadOptimizerCatalog {
  const LoadOptimizerCatalog(this._repository);

  final OptimizerRepository _repository;

  Future<Result<OptimizerCatalog>> call(Game game) =>
      _repository.loadCatalog(game);
}
