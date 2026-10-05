import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/assistant/data/build_json.dart';
import 'package:mh_wiki/features/assistant/domain/assistant_domain.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/dtos/json_reader.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads `assets/data/<game>/builds.json`, decoding off the UI isolate.
class AssetBuildRepository implements BuildRepository {
  AssetBuildRepository(this._bundle);

  final AssetBundle _bundle;
  final _cache = <Game, BuildCatalog>{};

  static String assetPath(Game game) =>
      'assets/data/${game.datasetKey}/builds.json';

  @override
  Future<Result<BuildCatalog>> loadCatalog(Game game) async {
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
        _cache[game] = readBuildsDataset(decoded, expectedGame: game),
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

/// Saved builds as one versioned JSON list in the preferences (research R5).
class PrefsSavedBuildsRepository implements SavedBuildsRepository {
  PrefsSavedBuildsRepository(this._prefs);

  static const key = 'assistant.savedBuilds.v1';

  final SharedPreferences _prefs;

  @override
  Future<List<SavedBuild>> load() async {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<Object?>;
      return [
        for (final (i, e) in list.indexed)
          () {
            final r = JsonReader(e! as Map<String, Object?>, 'saved[$i]');
            return SavedBuild(
              id: r.string('id'),
              name: r.string('name'),
              savedAt: DateTime.parse(r.string('savedAt')),
              build: readBuild(r.object('build')),
            );
          }(),
      ];
    } on Object {
      // A corrupt value must not break the area: start empty.
      return const [];
    }
  }

  @override
  Future<bool> store(List<SavedBuild> builds) => _prefs.setString(
    key,
    jsonEncode([
      for (final s in builds)
        {
          'id': s.id,
          'name': s.name,
          'savedAt': s.savedAt.toIso8601String(),
          'build': writeBuild(s.build),
        },
    ]),
  );
}

/// The progress and weapon type, in the preferences.
class PrefsAssistantPrefsRepository implements AssistantPrefsRepository {
  PrefsAssistantPrefsRepository(this._prefs);

  static const progressKey = 'assistant.progress.v1';
  static const typeKey = 'assistant.weaponType.v1';

  final SharedPreferences _prefs;

  @override
  Future<AssistantPrefs> load() async {
    var progress = Progress.first;
    final raw = _prefs.getString(progressKey);
    if (raw != null) {
      final [rank, step] = raw.split(':').length == 2
          ? raw.split(':')
          : ['low', '1'];
      try {
        progress = Progress.parse(rank, step);
      } on Object {
        progress = Progress.first;
      }
    }
    return (progress: progress, weaponType: _prefs.getString(typeKey));
  }

  @override
  Future<void> store(AssistantPrefs prefs) async {
    await _prefs.setString(
      progressKey,
      '${prefs.progress.rank.name}:${prefs.progress.step}',
    );
    if (prefs.weaponType case final type?) {
      await _prefs.setString(typeKey, type);
    }
  }
}
