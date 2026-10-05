import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/assistant/data/optimizer_json.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_repositories.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads `assets/data/<game>/optimizer.json` once, decoding off the UI
/// isolate.
class AssetOptimizerRepository implements OptimizerRepository {
  AssetOptimizerRepository(this._bundle);

  final AssetBundle _bundle;
  final _cache = <Game, OptimizerCatalog>{};

  static String assetPath(Game game) =>
      'assets/data/${game.datasetKey}/optimizer.json';

  @override
  Future<Result<OptimizerCatalog>> loadCatalog(Game game) async {
    final cached = _cache[game];
    if (cached != null) return Success(cached);
    final String raw;
    try {
      raw = await _bundle.loadString(assetPath(game));
    } on Object {
      return Err(DatasetUnavailable(game));
    }
    try {
      final decoded = await compute(jsonDecode, raw);
      if (decoded is! Map<String, Object?>) {
        return Err(DatasetFormatInvalid(game, 'root must be an object'));
      }
      return Success(
        _cache[game] = readOptimizerDataset(decoded, expectedGame: game),
      );
    } on UnsupportedSchemaVersionException catch (e) {
      return Err(UnsupportedSchemaVersion(game, e.found));
    } on DatasetFormatException catch (e) {
      return Err(DatasetFormatInvalid(game, e.message));
    } on Object catch (e) {
      return Err(DatasetFormatInvalid(game, '$e'));
    }
  }
}

/// The talismans as one versioned JSON list in the preferences (research R6).
class PrefsTalismanRepository implements TalismanRepository {
  PrefsTalismanRepository(this._prefs);

  static const key = 'assistant.talismans.v1';

  final SharedPreferences _prefs;

  @override
  Future<List<UserTalisman>> load() async {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    try {
      return [
        for (final e in jsonDecode(raw) as List<Object?>)
          () {
            final m = e! as Map<String, Object?>;
            return UserTalisman(
              id: m['id']! as String,
              skills: _skills(m['skills']),
              slots: [for (final s in m['slots']! as List<Object?>) s! as int],
            );
          }(),
      ];
    } on Object {
      // A corrupt value must not break Montar build: start empty.
      return const [];
    }
  }

  @override
  Future<bool> store(List<UserTalisman> talismans) => _prefs.setString(
    key,
    jsonEncode([
      for (final t in talismans)
        {'id': t.id, 'skills': _writeSkills(t.skills), 'slots': t.slots},
    ]),
  );
}

/// The request's skills and options (research R6).
class PrefsRequestRepository implements RequestRepository {
  PrefsRequestRepository(this._prefs);

  static const key = 'assistant.optimizer.request.v1';

  static const StoredRequest empty = (
    skills: <String, int>{},
    fixedWeaponId: null,
    useTalismans: true,
    onlyMyProgress: true,
  );

  final SharedPreferences _prefs;

  @override
  Future<StoredRequest> load() async {
    final raw = _prefs.getString(key);
    if (raw == null) return empty;
    try {
      final m = jsonDecode(raw) as Map<String, Object?>;
      return (
        skills: _skills(m['skills']),
        fixedWeaponId: m['fixedWeapon'] as String?,
        useTalismans: m['useTalismans'] as bool? ?? true,
        onlyMyProgress: m['onlyMyProgress'] as bool? ?? true,
      );
    } on Object {
      return empty;
    }
  }

  @override
  Future<void> store(StoredRequest request) => _prefs.setString(
    key,
    jsonEncode({
      'skills': _writeSkills(request.skills),
      'fixedWeapon': ?request.fixedWeaponId,
      'useTalismans': request.useTalismans,
      'onlyMyProgress': request.onlyMyProgress,
    }),
  );
}

/// Skills as an ordered list, so the user's order survives.
Map<String, int> _skills(Object? raw) => {
  for (final e in raw! as List<Object?>)
    (e! as Map<String, Object?>)['skill']! as String:
        (e as Map<String, Object?>)['level']! as int,
};

List<Map<String, Object>> _writeSkills(Map<String, int> skills) => [
  for (final e in skills.entries) {'skill': e.key, 'level': e.value},
];
