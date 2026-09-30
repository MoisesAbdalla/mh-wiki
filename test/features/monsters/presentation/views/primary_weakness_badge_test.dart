import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/widgets/element_icon.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/fake_monster_repository.dart';
import '../../../../fakes/monster_fixtures.dart';
import '../../../../helpers/pump_app.dart';

/// 002 FR-005: each list item shows the monster's primary weakness.
void main() {
  testWidgets('list item shows primary weakness; none below 2 stars', (
    tester,
  ) async {
    final controller = buildController(
      FakeMonsterRepository(
        monsters: [
          buildMonster(
            slug: 'anjanath',
            en: 'Anjanath',
            general: weaknesses(water: Effectiveness.high),
          ),
          buildMonster(
            slug: 'weakless',
            en: 'Weakless',
            general: weaknesses(fire: Effectiveness.low),
          ),
        ],
      ),
    );
    await controller.load();
    setWindowSize(tester, const Size(400, 800));
    await pumpApp(tester, MonstersPage(controller: controller));

    final anjanath = find.ancestor(
      of: find.text('Anjanath'),
      matching: find.byType(InkWell),
    );
    expect(
      find.descendant(of: anjanath, matching: find.text('Água')),
      findsOneWidget,
    );
    final icon = tester.widget<ElementIcon>(
      find.descendant(of: anjanath, matching: find.byType(ElementIcon)),
    );
    expect(icon.element, ElementType.water);
    expect(elementColor(ElementType.water), HunterPalette.water);

    final weakless = find.ancestor(
      of: find.text('Weakless'),
      matching: find.byType(InkWell),
    );
    expect(
      find.descendant(of: weakless, matching: find.byType(ElementIcon)),
      findsNothing,
    );
    controller.dispose();
  });
}
