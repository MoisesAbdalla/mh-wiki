import 'package:mh_wiki/core/domain/search_normalizer.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_query.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_tree.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/build_weapon_trees.dart';

/// The tree cards for a query (006 FR-006/FR-007). Trees are built once per
/// type and names normalized once per catalog, so each query only filters.
class FilterWeapons {
  FilterWeapons(
    this.catalog, {
    BuildWeaponTrees build = const BuildWeaponTrees(),
  }) : _trees = {
         for (final type in catalog.types)
           type.id: build(
             // Gogma Artian (010) and World specials (011) have their own groups.
             catalog.weapons.where(
               (w) =>
                   w.type.id == type.id &&
                   w.gogma == null &&
                   w.worldSpecial == null,
             ),
           ),
       },
       _names = {
         for (final w in catalog.weapons)
           w:
               '${normalizeForSearch(w.name.en)}\n'
               '${normalizeForSearch(w.name.ptBr ?? '')}',
       };

  final WeaponCatalog catalog;
  final Map<String, List<WeaponTree>> _trees;
  final Map<Weapon, String> _names;

  List<WeaponTree> call(WeaponQuery query) {
    final needle = normalizeForSearch(query.text);
    final only = query.onlyIds;
    final source = only == null
        ? _trees[query.typeId] ?? const <WeaponTree>[]
        : [for (final type in catalog.types) ...?_trees[type.id]];

    final result = <WeaponTree>[];
    for (final tree in source) {
      final entries = [
        for (final entry in tree.entries)
          if ((only == null || only.contains(entry.weapon.id)) &&
              (query.rank == null || entry.weapon.rank == query.rank) &&
              (needle.isEmpty || _names[entry.weapon]!.contains(needle)))
            entry,
      ];
      if (entries.isNotEmpty) {
        result.add(WeaponTree(id: tree.id, name: tree.name, entries: entries));
      }
    }
    return result;
  }
}
