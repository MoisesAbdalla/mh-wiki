import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_search.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_repositories.dart';

/// Runs [searchBuilds] on the calling isolate (web, where there are no
/// isolates). It yields once first, so "procurando…" can show.
class PlatformBuildSearcher implements BuildSearcher {
  bool _cancelled = false;

  @override
  Future<List<BuildSet>?> search(
    OptimizerCatalog catalog,
    BuildRequest request,
    List<UserTalisman> talismans, {
    SearchProgress? onProgress,
  }) async {
    _cancelled = false;
    await Future<void>.delayed(const Duration(milliseconds: 16));
    if (_cancelled) return null;
    try {
      return searchBuilds(
        catalog,
        request,
        talismans,
        onProgress: onProgress,
        cancelled: () => _cancelled,
      );
    } on SearchCancelled {
      return null;
    }
  }

  @override
  void cancel() => _cancelled = true;
}
