import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_query.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_tree.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/filter_weapons.dart';

import '../../../../fakes/weapon_fixtures.dart';

/// 006 FR-006/FR-007: type, rank and search filters over tree cards.
void main() {
  final filter = FilterWeapons(weaponCatalog());

  List<String> slugs(List<WeaponTree> trees) => [
    for (final t in trees)
      for (final e in t.entries) e.weapon.id.slug,
  ];

  test('shows the trees of the chosen type only', () {
    final trees = filter(const WeaponQuery(typeId: 'bow'));
    expect(slugs(trees), ['hunters-bow']);
  });

  test('a rank keeps the tree order and drops empty trees', () {
    final trees = filter(
      const WeaponQuery(typeId: 'great-sword', rank: Rank.master),
    );
    expect(trees.map((t) => t.id), ['anjanath-tree']);
    expect(slugs(trees), [
      'gnashing-flammenzahn-plus',
      'lohenzahn-alt',
      'lohenzahn',
    ]);
  });

  test('searches en and pt-BR names, ignoring case and accents', () {
    expect(
      slugs(filter(const WeaponQuery(typeId: 'great-sword', text: 'LOHEN'))),
      ['lohenzahn'],
    );
    expect(
      slugs(
        filter(const WeaponQuery(typeId: 'great-sword', text: 'presardente')),
      ),
      ['gnashing-flammenzahn-plus'],
    );
  });

  test('keeps the depth of a matching weapon', () {
    final entry = filter(
      const WeaponQuery(typeId: 'great-sword', text: 'lohenzahn'),
    ).single.entries.single;
    expect(entry.depth, 4);
  });

  test('an unmatched query gives no trees', () {
    expect(
      filter(const WeaponQuery(typeId: 'great-sword', text: 'xyz')),
      isEmpty,
    );
  });

  test('only ids restricts to a set of weapons across types', () {
    final trees = filter(
      WeaponQuery(
        typeId: 'great-sword',
        onlyIds: {wid('lohenzahn'), wid('hunters-bow')},
      ),
    );
    // In the catalog's type order: Great Sword, then Bow.
    expect(slugs(trees), ['lohenzahn', 'hunters-bow']);
  });
}
