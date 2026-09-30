import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';

/// Reads datasets bundled as assets: `assets/data/<game>/monsters.json`.
class AssetMonsterDatasource implements MonsterDatasource {
  AssetMonsterDatasource(this._bundle);

  final AssetBundle _bundle;

  static String assetPath(Game game) =>
      'assets/data/${game.datasetKey}/monsters.json';

  @override
  Future<Map<String, Object?>> fetchDataset(Game game) async {
    final String raw;
    try {
      raw = await _bundle.loadString(assetPath(game));
    } on Object catch (error) {
      throw DatasetUnavailableException('${assetPath(game)}: $error');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      throw DatasetFormatException('${assetPath(game)}: ${error.message}');
    }
    if (decoded is! Map<String, Object?>) {
      throw DatasetFormatException(
        '${assetPath(game)}: root must be an object',
      );
    }
    return decoded;
  }
}
