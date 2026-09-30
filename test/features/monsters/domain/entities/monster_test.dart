import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';

import '../../../../fakes/monster_fixtures.dart';

void main() {
  group('Monster.dropsByRank', () {
    final scale = material('rathalos-scale', 'Rathalos Scale');
    final plate = material('rathalos-plate', 'Rathalos Plate');
    final marrow = material('rathalos-marrow', 'Rathalos Marrow');

    final monster = buildMonster(
      drops: [
        drop(marrow, Rank.master, DropMethod.carve, rate: 10),
        drop(scale, Rank.low, DropMethod.carve, rate: 32),
        drop(plate, Rank.low, DropMethod.capture, rate: 5),
        drop(scale, Rank.low, DropMethod.tailCarve),
      ],
    );

    test(
      'orders ranks low -> high -> master and omits ranks without drops',
      () {
        expect(monster.dropsByRank.keys, [Rank.low, Rank.master]);
      },
    );

    test('groups by material keeping every method row', () {
      final low = monster.dropsByRank[Rank.low]!;
      expect(low.map((g) => g.material.id), [
        'rathalos-scale',
        'rathalos-plate',
      ]);
      final scaleGroup = low.first;
      expect(scaleGroup.drops.map((d) => d.method), [
        DropMethod.carve,
        DropMethod.tailCarve,
      ]);
      expect(scaleGroup.drops.last.ratePercent, isNull);
    });

    test('is empty when the monster has no drops', () {
      expect(buildMonster().dropsByRank, isEmpty);
    });
  });
}
