import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_piece.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';
import 'package:mh_wiki/features/armor/domain/usecases/armor_queries.dart';

import '../../../fakes/armor_fixtures.dart';

/// 007 data-model › Use cases.
void main() {
  final catalog = armorCatalog();

  test('a set sums defense, max defense and resistances', () {
    final set = catalog.set('rathalos-x')!;
    expect(set.defense, 570);
    expect(set.maxDefense, 870);
    final r = set.resistances;
    expect([r.fire, r.water, r.thunder, r.ice, r.dragon], [15, 5, -10, 5, -15]);
    expect(catalog.set('leather')!.maxDefense, isNull);
  });

  test('set skills are summed, highest first', () {
    final totals = sumSetSkills(catalog, catalog.set('rathalos-x')!);
    expect(
      [for (final t in totals) (t.skill.id, t.level)],
      [
        ('attack-boost', 7),
        ('earplugs', 5),
        ('partbreaker', 3),
        ('windproof', 3),
        ('critical-boost', 2),
      ],
    );
    expect(totals.first.overflow, 0);
  });

  test('a sum above the max reports the overflow', () {
    final set = ArmorSet(
      id: 'x',
      name: rathalosX().name,
      rarity: 9,
      pieces: [
        buildPiece(
          'a',
          'A',
          BodyPart.head,
          skills: const [SkillLevel('partbreaker', 2)],
        ),
        buildPiece(
          'b',
          'B',
          BodyPart.chest,
          skills: const [SkillLevel('partbreaker', 2)],
        ),
      ],
    );
    expect(sumSetSkills(catalog, set).single.overflow, 1);
  });

  group('FilterSets', () {
    final filter = FilterSets(catalog);

    List<String> ids(SetQuery q) => [for (final s in filter(q)) s.id];

    test('by rank, rarity order', () {
      expect(ids(const SetQuery()), ['leather', 'rathalos-x']);
      expect(ids(const SetQuery(rank: Rank.master)), ['rathalos-x']);
    });

    test('by set or piece name in en and pt-BR, without accents', () {
      expect(ids(const SetQuery(text: 'COURO')), ['leather']);
      expect(ids(const SetQuery(text: 'grevas')), ['rathalos-x']);
      expect(ids(const SetQuery(text: 'xyz')), isEmpty);
    });

    test('by skill', () {
      expect(ids(const SetQuery(skillId: 'windproof')), ['rathalos-x']);
      expect(ids(const SetQuery(skillId: 'attack-boost')), hasLength(2));
    });

    test('suggests skills by name', () {
      expect(filter.matchingSkills('reforco').map((s) => s.id), [
        'attack-boost',
        'critical-boost',
      ]);
      expect(filter.matchingSkills('r'), isEmpty);
    });
  });

  test('skill sources: decorations by slot, pieces master first', () {
    final sources = skillSources(catalog, 'attack-boost');
    expect(
      [for (final d in sources.decorations) (d.decoration.id, d.level)],
      [('attack-jewel-2', 1), ('attack-jewel-plus-4', 2)],
    );
    expect(sources.pieces.keys, [Rank.master, Rank.low]);
    expect(sources.pieces[Rank.master]!.first.level, 2);
    expect(sources.pieceCount, 6);
  });
}
