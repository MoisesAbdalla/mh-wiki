import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/repositories/armor_repository.dart';

final class LoadArmorCatalog {
  const LoadArmorCatalog(this._repository);

  final ArmorRepository _repository;

  Future<Result<ArmorCatalog>> call(Game game) => _repository.loadCatalog(game);
}
