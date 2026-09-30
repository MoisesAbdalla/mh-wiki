import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
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

  group('Monster.dropsByMethod', () {
    final scale = material('scale', 'Rathalos Scale');
    final plate = material('plate', 'Rathalos Plate');
    final ruby = material('ruby', 'Rathalos Ruby');
    final ticket = material('ticket', 'Rathalos Ticket');
    const questA = LocalizedText(en: 'Quest reward: A');
    const questB = LocalizedText(en: 'Quest reward: B');

    final monster = buildMonster(
      drops: [
        drop(scale, Rank.high, DropMethod.carve, rate: 32),
        drop(ruby, Rank.high, DropMethod.breakPart, partId: 'head', rate: 3),
        drop(plate, Rank.high, DropMethod.carve, rate: 5),
        drop(ruby, Rank.high, DropMethod.breakPart, partId: 'wing', rate: 2),
        drop(ticket, Rank.high, DropMethod.other, methodLabel: questA),
        drop(ticket, Rank.high, DropMethod.other, methodLabel: questB),
        drop(scale, Rank.low, DropMethod.carve, rate: 40),
      ],
    );

    test('groups a rank by method in first-appearance order', () {
      final groups = monster.dropsByMethod(Rank.high);
      expect(groups.map((g) => g.method), [
        DropMethod.carve,
        DropMethod.breakPart,
        DropMethod.breakPart,
        DropMethod.other,
        DropMethod.other,
      ]);
      expect(groups.first.drops.map((d) => d.material.id), ['scale', 'plate']);
    });

    test('splits part breaks by part and other methods by label', () {
      final groups = monster.dropsByMethod(Rank.high);
      expect(groups[1].partId, 'head');
      expect(groups[2].partId, 'wing');
      expect(groups[3].methodLabel, questA);
      expect(groups[4].methodLabel, questB);
    });

    test('keeps ranks apart and is empty for a rank without drops', () {
      expect(
        monster.dropsByMethod(Rank.low).single.drops.single.ratePercent,
        40,
      );
      expect(monster.dropsByMethod(Rank.master), isEmpty);
    });
  });
}
