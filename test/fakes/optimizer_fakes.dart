import 'dart:async';

import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/assistant/data/optimizer_repositories.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_search.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_repositories.dart';

import 'optimizer_fixtures.dart';

class FakeOptimizerRepository implements OptimizerRepository {
  FakeOptimizerRepository({OptimizerCatalog? catalog, this.failure})
    : catalog = catalog ?? fixtureCatalog();

  OptimizerCatalog catalog;
  Failure? failure;
  int loadCount = 0;

  @override
  Future<Result<OptimizerCatalog>> loadCatalog(Game game) async {
    loadCount++;
    final f = failure;
    return f != null ? Err(f) : Success(catalog);
  }
}

class FakeTalismanRepository implements TalismanRepository {
  List<UserTalisman> talismans = [];

  @override
  Future<List<UserTalisman>> load() async => [...talismans];

  @override
  Future<bool> store(List<UserTalisman> list) async {
    talismans = [...list];
    return true;
  }
}

class FakeRequestRepository implements RequestRepository {
  StoredRequest stored = PrefsRequestRepository.empty;

  @override
  Future<StoredRequest> load() async => stored;

  @override
  Future<void> store(StoredRequest request) async => stored = request;
}

/// Runs the search inline; with [hold] set, it waits for [release] first so
/// tests can see "procurando…" and cancel.
class FakeBuildSearcher implements BuildSearcher {
  bool hold = false;
  Completer<void>? _gate;
  bool _cancelled = false;
  BuildRequest? lastRequest;
  List<UserTalisman>? lastTalismans;

  void release() => _gate?.complete();

  @override
  Future<List<BuildSet>?> search(
    OptimizerCatalog catalog,
    BuildRequest request,
    List<UserTalisman> talismans, {
    SearchProgress? onProgress,
  }) async {
    _cancelled = false;
    lastRequest = request;
    lastTalismans = talismans;
    onProgress?.call(1234);
    if (hold) {
      _gate = Completer<void>();
      await _gate!.future;
    }
    if (_cancelled) return null;
    return searchBuilds(catalog, request, talismans);
  }

  @override
  void cancel() {
    _cancelled = true;
    if (_gate case final g? when !g.isCompleted) g.complete();
  }
}
