import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';
import 'package:mh_wiki/features/weapons/data/datasources/weapon_datasource.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_dto.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_mapper.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/repositories/weapon_repository.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/build_weapon_trees.dart';

class WeaponRepositoryImpl implements WeaponRepository {
  WeaponRepositoryImpl(this._datasource);

  final WeaponDatasource _datasource;
  final _cache = <Game, WeaponCatalog>{};

  @override
  Future<Result<WeaponCatalog>> loadCatalog(Game game) async {
    final cached = _cache[game];
    if (cached != null) return Success(cached);
    try {
      final json = await _datasource.fetchDataset(game);
      final dataset = WeaponDatasetDto.fromJson(json, expectedGame: game);
      final catalog = WeaponDatasetMapper.toCatalog(dataset);
      // A cycle in the upgrade graph is bad data: reject it at load time.
      const BuildWeaponTrees()(catalog.weapons);
      return Success(_cache[game] = catalog);
    } on DatasetUnavailableException {
      return Err(DatasetUnavailable(game));
    } on UnsupportedSchemaVersionException catch (e) {
      return Err(UnsupportedSchemaVersion(game, e.found));
    } on DatasetFormatException catch (e) {
      return Err(DatasetFormatInvalid(game, e.message));
    } on WeaponTreeCycleException catch (e) {
      return Err(DatasetFormatInvalid(game, '$e'));
    } on Object catch (e) {
      return Err(DatasetFormatInvalid(game, '$e'));
    }
  }
}
