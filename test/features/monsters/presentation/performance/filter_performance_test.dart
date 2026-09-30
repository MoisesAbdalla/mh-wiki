import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/presentation/models/monster_list_state.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/fake_monster_repository.dart';
import '../../../../fakes/monster_fixtures.dart';

/// SC-002: search and filter results in < 0.5 s with the full catalog.
/// Uses 200 monsters (the size the plan is designed for), well above v1.
void main() {
  test(
    'search and game filter respond in under 500 ms for 200 monsters',
    () async {
      final monsters = [
        for (var i = 0; i < 200; i++)
          richMonster(game: Game.values[i % 3]).copyForTest(i),
      ];
      final controller = buildController(
        FakeMonsterRepository(monsters: monsters),
      );
      await controller.load();

      final stopwatch = Stopwatch()..start();
      for (final text in ['r', 'ra', 'rat', 'rath', 'ratha', 'rathalos-1']) {
        controller.setSearchText(text);
      }
      controller
        ..setGame(Game.wilds)
        ..setGame(null)
        ..setSearchText('');
      stopwatch.stop();

      // Nine full re-filters must together stay under the per-change budget.
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      expect((controller.state as MonsterListLoaded).sections, hasLength(3));
      controller.dispose();
    },
  );
}
