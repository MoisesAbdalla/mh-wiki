import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_query.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/filter_monsters.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/fake_monster_repository.dart';
import '../../../../fakes/monster_fixtures.dart';
import '../../../../helpers/pump_app.dart';

/// 004 SC-004/SC-005 with a catalog larger than the full roster:
/// 100 base monsters with 2 versions each (300 entries) in one game.
List<Monster> _catalog() => [
  for (var i = 0; i < 100; i++)
    ...() {
      final base = richMonster().copyForTest(i);
      return [
        base,
        buildVersion(
          base,
          VersionKind.tempered,
          slug: 'tempered-${base.id.slug}',
          en: 'Tempered ${base.name.en}',
        ),
        buildVersion(
          base,
          VersionKind.archTempered,
          slug: 'arch-tempered-${base.id.slug}',
          en: 'Arch-Tempered ${base.name.en}',
          ptBr: '${base.name.en} Arquitemperado',
        ),
      ];
    }(),
];

void main() {
  test('filtering 300 entries stays under 50 ms per keystroke', () {
    const filter = FilterMonsters();
    final all = _catalog();
    filter(all, const MonsterQuery()); // warm-up (JIT)

    for (final text in ['a', 'ar', 'arq', 'arqu', 'arquitemperado', '']) {
      final stopwatch = Stopwatch()..start();
      final sections = filter(all, MonsterQuery(text: text));
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(50), reason: text);
      expect(sections.single.entries, hasLength(100), reason: text);
    }
  });

  testWidgets('the list with 300 entries builds and switches games', (
    tester,
  ) async {
    final controller = buildController(
      FakeMonsterRepository(monsters: _catalog()),
    );
    await controller.load();
    setWindowSize(tester, const Size(400, 800));
    await pumpApp(tester, MonstersPage(controller: controller));

    expect(tester.takeException(), isNull);
    controller.setGame(Game.worldIceborne);
    await tester.pumpAndSettle();
    controller.setGame(null);
    await tester.pumpAndSettle();
    expect(find.text('2 versões'), findsWidgets);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });
}
