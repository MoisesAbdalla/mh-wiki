import 'package:mh_wiki/features/monsters/domain/entities/monster_catalog.dart';
import 'package:mh_wiki/features/monsters/domain/repositories/monster_repository.dart';

final class LoadMonsterCatalog {
  const LoadMonsterCatalog(this._repository);

  final MonsterRepository _repository;

  Future<MonsterCatalog> call() => _repository.loadCatalog();
}
