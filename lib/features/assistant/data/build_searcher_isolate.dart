import 'dart:async';
import 'dart:isolate';

import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_search.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_repositories.dart';

/// Runs [searchBuilds] in a background isolate, streaming the checked count;
/// [cancel] kills it (009 research R4, step 5).
class PlatformBuildSearcher implements BuildSearcher {
  Isolate? _isolate;
  ReceivePort? _port;
  Completer<List<BuildSet>?>? _done;

  @override
  Future<List<BuildSet>?> search(
    OptimizerCatalog catalog,
    BuildRequest request,
    List<UserTalisman> talismans, {
    SearchProgress? onProgress,
  }) async {
    cancel();
    final done = _done = Completer<List<BuildSet>?>();
    final port = _port = ReceivePort();
    port.listen((message) {
      switch (message) {
        case final int checked:
          onProgress?.call(checked);
        case final List<BuildSet> sets:
          _finish(sets);
        case _:
          _finish(null, error: message);
      }
    });
    _isolate = await Isolate.spawn(
      _run,
      (port.sendPort, catalog, request, talismans),
      onError: port.sendPort,
      errorsAreFatal: true,
    );
    return done.future;
  }

  static void _run(
    (SendPort, OptimizerCatalog, BuildRequest, List<UserTalisman>) args,
  ) {
    final (port, catalog, request, talismans) = args;
    var last = 0;
    final sets = searchBuilds(
      catalog,
      request,
      talismans,
      onProgress: (n) {
        // At most a few messages per second's worth of work.
        if (n - last >= 20000) {
          last = n;
          port.send(n);
        }
      },
    );
    port.send(sets);
  }

  void _finish(List<BuildSet>? sets, {Object? error}) {
    final done = _done;
    _done = null;
    _port?.close();
    _port = null;
    _isolate = null;
    if (done == null || done.isCompleted) return;
    if (error != null) {
      done.completeError(StateError('build search failed: $error'));
    } else {
      done.complete(sets);
    }
  }

  @override
  void cancel() {
    _isolate?.kill(priority: Isolate.immediate);
    _finish(null);
  }
}
