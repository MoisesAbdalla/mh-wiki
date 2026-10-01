import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/weapons/data/datasources/weapon_datasource.dart';

/// Reads `assets/data/<game>/weapons.json`.
class AssetWeaponDatasource implements WeaponDatasource {
  AssetWeaponDatasource(this._bundle);

  final AssetBundle _bundle;

  static String assetPath(Game game) =>
      'assets/data/${game.datasetKey}/weapons.json';

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
      // ~5 MB of JSON: decode off the UI isolate (SC-004).
      decoded = await compute(jsonDecode, raw);
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
