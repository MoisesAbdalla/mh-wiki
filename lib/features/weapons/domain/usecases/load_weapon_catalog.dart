import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/repositories/weapon_repository.dart';

final class LoadWeaponCatalog {
  const LoadWeaponCatalog(this._repository);

  final WeaponRepository _repository;

  Future<Result<WeaponCatalog>> call(Game game) =>
      _repository.loadCatalog(game);
}
