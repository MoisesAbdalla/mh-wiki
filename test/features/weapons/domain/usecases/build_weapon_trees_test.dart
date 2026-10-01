import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/build_weapon_trees.dart';

import '../../../../fakes/weapon_fixtures.dart';

/// 006 research R4: trees ordered from the roots, depth first.
void main() {
  const build = BuildWeaponTrees();

  List<(String, int)> rows(String treeId) => [
    for (final e in build(
      anjanathWeapons().where((w) => w.type == greatSword),
    ).singleWhere((t) => t.id == treeId).entries)
      (e.weapon.id.slug, e.depth),
  ];

  test('walks a tree from its root, depth first, siblings by rarity', () {
    expect(rows('anjanath-tree'), [
      ('flammenzahn-i', 0),
      ('flammenzahn-ii', 1),
      ('gnashing-flammenzahn', 2),
      ('gnashing-flammenzahn-plus', 3),
      ('lohenzahn-alt', 4), // same rarity: by name ("Aardzahn" first)
      ('lohenzahn', 4),
    ]);
  });

  test('orders trees by their root rarity then name', () {
    final trees = build(anjanathWeapons().where((w) => w.type == greatSword));
    expect(trees.map((t) => t.id), ['bone-tree', 'anjanath-tree']);
    expect(trees.first.name.en, 'Bone Tree');
  });

  test('a weapon whose previous one is in another tree is a root there', () {
    final trees = build([
      buildWeapon('a', next: ['b']),
      buildWeapon('b', previous: 'a', tree: 'other', treeEn: 'Other Tree'),
    ]);
    final other = trees.singleWhere((t) => t.id == 'other');
    expect(other.entries.single.weapon.id.slug, 'b');
    expect(other.entries.single.depth, 0);
  });

  test('a cycle is an error', () {
    expect(
      () => build([
        buildWeapon('a', previous: 'b', next: ['b']),
        buildWeapon('b', previous: 'a', next: ['a']),
      ]),
      throwsA(isA<WeaponTreeCycleException>()),
    );
  });
}
