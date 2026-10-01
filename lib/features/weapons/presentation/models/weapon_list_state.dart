import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_query.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_tree.dart';

/// Screen state of the weapon list (the "Model" in MVC).
sealed class WeaponListState {
  const WeaponListState();
}

final class WeaponListLoading extends WeaponListState {
  const WeaponListLoading();
}

final class WeaponListLoaded extends WeaponListState {
  const WeaponListLoaded({
    required this.catalog,
    required this.query,
    required this.trees,
    this.selectedId,
  });

  final WeaponCatalog catalog;
  final WeaponQuery query;

  /// The tree cards to show, already filtered.
  final List<WeaponTree> trees;
  final WeaponId? selectedId;

  bool get isEmpty => trees.isEmpty;

  int get weaponCount => trees.fold(0, (n, t) => n + t.entries.length);
}

/// The weapon dataset failed; only the Armas area shows it (FR-016).
final class WeaponListFailed extends WeaponListState {
  const WeaponListFailed(this.failure);

  final Failure failure;
}
