import 'package:flutter/services.dart';
import 'package:mh_wiki/features/monsters/data/datasources/asset_monster_datasource.dart';
import 'package:mh_wiki/features/monsters/data/repositories/monster_repository_impl.dart';
import 'package:mh_wiki/features/monsters/domain/repositories/monster_repository.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/filter_monsters.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/load_monster_catalog.dart';

/// Composition root (constitution Principle III): the only place that knows
/// concrete implementations. Everything else receives abstractions through
/// constructors.
final class AppDependencies {
  AppDependencies._({required this.monsterRepository});

  factory AppDependencies.create({AssetBundle? bundle}) {
    final datasource = AssetMonsterDatasource(bundle ?? rootBundle);
    return AppDependencies._(
      monsterRepository: MonsterRepositoryImpl(datasource),
    );
  }

  final MonsterRepository monsterRepository;

  LoadMonsterCatalog get loadMonsterCatalog =>
      LoadMonsterCatalog(monsterRepository);

  FilterMonsters get filterMonsters => const FilterMonsters();
}
