import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';

abstract interface class WeaponRepository {
  /// Loads one game's weapons. Never throws: a broken dataset is an [Err],
  /// and it never affects the monsters (FR-016).
  Future<Result<WeaponCatalog>> loadCatalog(Game game);
}
