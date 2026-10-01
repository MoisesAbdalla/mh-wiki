import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/armor/data/armor_dataset_dto.dart';
import 'package:mh_wiki/features/armor/data/asset_armor_datasource.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/repositories/armor_repository.dart';
import 'package:mh_wiki/features/monsters/data/datasources/monster_datasource.dart';

class ArmorRepositoryImpl implements ArmorRepository {
  ArmorRepositoryImpl(this._datasource);

  final ArmorDatasource _datasource;
  final _cache = <Game, ArmorCatalog>{};

  @override
  Future<Result<ArmorCatalog>> loadCatalog(Game game) async {
    final cached = _cache[game];
    if (cached != null) return Success(cached);
    try {
      final json = await _datasource.fetchDataset(game);
      return Success(_cache[game] = readArmorDataset(json, expectedGame: game));
    } on DatasetUnavailableException {
      return Err(DatasetUnavailable(game));
    } on UnsupportedSchemaVersionException catch (e) {
      return Err(UnsupportedSchemaVersion(game, e.found));
    } on DatasetFormatException catch (e) {
      return Err(DatasetFormatInvalid(game, e.message));
    } on Object catch (e) {
      return Err(DatasetFormatInvalid(game, '$e'));
    }
  }
}
