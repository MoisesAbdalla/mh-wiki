import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';

abstract interface class ArmorRepository {
  /// Loads one game's armor. Never throws: a broken dataset is an `Err`,
  /// and it never affects monsters or weapons (007 FR-011).
  Future<Result<ArmorCatalog>> loadCatalog(Game game);
}
