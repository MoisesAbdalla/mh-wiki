import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_profile.dart';

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
}
