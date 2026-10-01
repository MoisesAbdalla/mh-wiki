import 'dart:async';

import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/repositories/weapon_repository.dart';

import 'weapon_fixtures.dart';

/// Returns [catalog], or [failure] when set; [completer] holds the load open.
class FakeWeaponRepository implements WeaponRepository {
  FakeWeaponRepository({WeaponCatalog? catalog, this.failure})
    : catalog = catalog ?? weaponCatalog();

  WeaponCatalog catalog;
  Failure? failure;
  Completer<void>? completer;
  int loadCount = 0;

  @override
  Future<Result<WeaponCatalog>> loadCatalog(Game game) async {
    loadCount++;
    await completer?.future;
    final f = failure;
    return f != null ? Err(f) : Success(catalog);
  }
}
