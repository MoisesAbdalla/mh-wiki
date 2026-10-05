import 'package:mh_wiki/features/assistant/data/build_searcher_inline.dart'
    if (dart.library.isolate) 'package:mh_wiki/features/assistant/data/build_searcher_isolate.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_repositories.dart';

/// The searcher for this platform: a background isolate where there are
/// isolates (mobile, desktop), the calling one on the web (plan.md).
BuildSearcher createBuildSearcher() => PlatformBuildSearcher();
