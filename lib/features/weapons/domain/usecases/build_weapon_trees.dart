import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_tree.dart';

/// The upgrade graph has a cycle (bad data).
class WeaponTreeCycleException implements Exception {
  WeaponTreeCycleException(this.weapon);

  final WeaponId weapon;

  @override
  String toString() => 'WeaponTreeCycleException: $weapon';
}

/// Groups weapons by tree and orders each tree from its roots, depth first;
/// siblings and trees by rarity, then name (006 research R4).
class BuildWeaponTrees {
  const BuildWeaponTrees();

  List<WeaponTree> call(Iterable<Weapon> weapons) {
    final byTree = <String, List<Weapon>>{};
    for (final weapon in weapons) {
      byTree.putIfAbsent(weapon.treeId, () => []).add(weapon);
    }

    final trees = <WeaponTree>[];
    for (final members in byTree.values) {
      final inTree = {for (final w in members) w.id: w};
      final children = <WeaponId, List<Weapon>>{};
      final roots = <Weapon>[];
      for (final weapon in members) {
        final parent = weapon.previous;
        if (parent != null && inTree.containsKey(parent)) {
          children.putIfAbsent(parent, () => []).add(weapon);
        } else {
          roots.add(weapon);
        }
      }
      if (roots.isEmpty) throw WeaponTreeCycleException(members.first.id);

      final entries = <WeaponTreeEntry>[];
      final visited = <WeaponId>{};
      void walk(Weapon weapon, int depth) {
        if (!visited.add(weapon.id)) throw WeaponTreeCycleException(weapon.id);
        entries.add(WeaponTreeEntry(weapon, depth));
        for (final child in _sorted(children[weapon.id] ?? const [])) {
          walk(child, depth + 1);
        }
      }

      for (final root in _sorted(roots)) {
        walk(root, 0);
      }
      if (visited.length != members.length) {
        // Members never reached from a root sit on a cycle.
        throw WeaponTreeCycleException(
          members.firstWhere((w) => !visited.contains(w.id)).id,
        );
      }
      trees.add(
        WeaponTree(
          id: members.first.treeId,
          name: members.first.treeName,
          entries: entries,
        ),
      );
    }

    trees.sort(
      (a, b) => _compare(a.entries.first.weapon, b.entries.first.weapon),
    );
    return trees;
  }

  static List<Weapon> _sorted(List<Weapon> weapons) =>
      [...weapons]..sort(_compare);

  static int _compare(Weapon a, Weapon b) {
    final byRarity = a.rarity.compareTo(b.rarity);
    return byRarity != 0 ? byRarity : a.name.en.compareTo(b.name.en);
  }
}
