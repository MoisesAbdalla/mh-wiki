import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_profile.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_state.dart';

import '../../../../fakes/monster_fixtures.dart';

void main() {
  group('WeaknessProfile.mostEffective (FR-008)', () {
    test('single 3-star element is the most effective', () {
      final profile = WeaknessProfile(
        general: weaknesses(
          dragon: Effectiveness.high,
          thunder: Effectiveness.medium,
        ),
      );
      expect(profile.mostEffective, {ElementType.dragon});
    });

    test('tie at 2 stars highlights both', () {
      final profile = WeaknessProfile(
        general: weaknesses(
          fire: Effectiveness.medium,
          ice: Effectiveness.medium,
        ),
      );
      expect(profile.mostEffective, {ElementType.fire, ElementType.ice});
    });

    test('max of 1 star highlights nothing', () {
      final profile = WeaknessProfile(
        general: weaknesses(fire: Effectiveness.low, water: Effectiveness.low),
      );
      expect(profile.mostEffective, isEmpty);
    });

    test('max of 0 stars highlights nothing', () {
      final profile = WeaknessProfile(general: weaknesses());
      expect(profile.mostEffective, isEmpty);
    });

    test('all immune highlights nothing', () {
      final profile = WeaknessProfile(
        general: {for (final e in ElementType.values) e: Effectiveness.immune},
      );
      expect(profile.mostEffective, isEmpty);
    });
  });

  test('Effectiveness is ordered immune < none < low < medium < high', () {
    expect(Effectiveness.values, [
      Effectiveness.immune,
      Effectiveness.none,
      Effectiveness.low,
      Effectiveness.medium,
      Effectiveness.high,
    ]);
    expect(Effectiveness.high.stars, 3);
    expect(Effectiveness.none.stars, 0);
    expect(Effectiveness.immune.stars, 0);
  });

  group('WeaknessProfile.primaryWeakness (002 FR-005)', () {
    test('is the single most effective element', () {
      final profile = WeaknessProfile(
        general: weaknesses(
          dragon: Effectiveness.high,
          thunder: Effectiveness.medium,
        ),
      );
      expect(profile.primaryWeakness, ElementType.dragon);
    });

    test(
      'a tie picks the first in fire, water, thunder, ice, dragon order',
      () {
        final profile = WeaknessProfile(
          general: weaknesses(
            ice: Effectiveness.high,
            water: Effectiveness.high,
          ),
        );
        expect(profile.primaryWeakness, ElementType.water);
      },
    );

    test('is null when nothing reaches 2 stars', () {
      final profile = WeaknessProfile(
        general: weaknesses(fire: Effectiveness.low),
      );
      expect(profile.primaryWeakness, isNull);
    });
  });

  group('WeaknessProfile.ranked (005 FR-010/FR-011)', () {
    List<(ElementType, Effectiveness, bool)> rows(WeaknessProfile p) => [
      for (final r in p.ranked) (r.element, r.effectiveness, r.best),
    ];

    test('orders best to worst, immune last, ties in element order', () {
      final profile = WeaknessProfile(
        general: weaknesses(
          fire: Effectiveness.immune,
          water: Effectiveness.low,
          thunder: Effectiveness.medium,
          ice: Effectiveness.low,
          dragon: Effectiveness.high,
        ),
      );
      expect(rows(profile), [
        (ElementType.dragon, Effectiveness.high, true),
        (ElementType.thunder, Effectiveness.medium, false),
        (ElementType.water, Effectiveness.low, false),
        (ElementType.ice, Effectiveness.low, false),
        (ElementType.fire, Effectiveness.immune, false),
      ]);
    });

    test('0 stars ranks above immune', () {
      final profile = WeaknessProfile(
        general: weaknesses(fire: Effectiveness.immune),
      );
      expect(profile.ranked.last.element, ElementType.fire);
      expect(profile.ranked.first.effectiveness, Effectiveness.none);
    });

    test('marks every tied best element with 2 stars or more', () {
      final profile = WeaknessProfile(
        general: weaknesses(
          water: Effectiveness.medium,
          ice: Effectiveness.medium,
        ),
      );
      expect(profile.ranked.where((r) => r.best).map((r) => r.element), [
        ElementType.water,
        ElementType.ice,
      ]);
    });

    test('marks nothing when no element reaches 2 stars', () {
      final profile = WeaknessProfile(
        general: weaknesses(ice: Effectiveness.low),
      );
      expect(profile.ranked.any((r) => r.best), isFalse);
    });

    test('always five entries; missing elements count as none', () {
      const profile = WeaknessProfile(
        general: {ElementType.dragon: Effectiveness.high},
      );
      expect(profile.ranked, hasLength(5));
      expect(profile.ranked.skip(1).map((r) => r.effectiveness).toSet(), {
        Effectiveness.none,
      });
    });

    test('states are ranked the same way, without a highlight', () {
      final state = WeaknessState(
        id: 'fire-active',
        name: const LocalizedText(en: 'Fire Active'),
        values: weaknesses(
          ice: Effectiveness.high,
          water: Effectiveness.medium,
        ),
      );
      expect(state.ranked.map((r) => r.element).take(2), [
        ElementType.ice,
        ElementType.water,
      ]);
      expect(state.ranked.any((r) => r.best), isFalse);
    });
  });
}
