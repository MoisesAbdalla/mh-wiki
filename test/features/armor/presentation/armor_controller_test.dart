import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';

import '../../../fakes/fake_armor_repository.dart';

/// 007 data-model › Presentation state.
void main() {
  late FakeArmorRepository repository;
  late ArmorController controller;

  setUp(() {
    repository = FakeArmorRepository();
    controller = buildArmorController(repository);
  });

  ArmorLoaded loaded() => controller.state as ArmorLoaded;

  test('loading, then the sets tab with every set', () async {
    repository.completer = Completer();
    final future = controller.ensureLoaded();
    expect(controller.state, isA<ArmorLoading>());
    repository.completer!.complete();
    await future;
    expect(loaded().tab, ArmorTab.sets);
    expect(loaded().sets.map((s) => s.id), ['leather', 'rathalos-x']);
    await controller.ensureLoaded();
    expect(repository.loadCount, 1);
  });

  test('a failure can be retried', () async {
    repository.failure = const DatasetUnavailable(Game.riseSunbreak);
    await controller.ensureLoaded();
    expect(controller.state, isA<ArmorFailed>());
    repository.failure = null;
    await controller.load();
    expect(controller.state, isA<ArmorLoaded>());
  });

  test('rank, text and a chosen skill filter the sets', () async {
    await controller.ensureLoaded();
    controller.setRank(Rank.master);
    expect(loaded().sets.map((s) => s.id), ['rathalos-x']);

    controller
      ..setRank(null)
      ..setSetText('antiv');
    expect(controller.skillSuggestions.map((s) => s.id), ['windproof']);

    controller.chooseSkill('windproof');
    expect(loaded().setQuery.text, '');
    expect(loaded().setQuery.skillId, 'windproof');
    expect(loaded().sets.map((s) => s.id), ['rathalos-x']);
    expect(controller.skillSuggestions, isEmpty);

    controller.clearSkill();
    expect(loaded().sets, hasLength(2));
  });

  test(
    'skills and decorations have their own search; filters per tab',
    () async {
      await controller.ensureLoaded();
      controller
        ..setTab(ArmorTab.skills)
        ..setSkillText('tampoes');
      expect(loaded().skills.map((s) => s.id), ['earplugs']);

      controller
        ..setTab(ArmorTab.decorations)
        ..setDecorationSlot(4);
      expect(loaded().decorations.map((d) => d.id), ['attack-jewel-plus-4']);
      controller
        ..setDecorationSlot(null)
        ..setDecorationText('ataque');
      expect(loaded().decorations, hasLength(2)); // by skill name too

      // The skills tab kept its search.
      controller.setTab(ArmorTab.skills);
      expect(loaded().skillText, 'tampoes');
    },
  );

  test('selecting opens the item and switches to its tab', () async {
    await controller.ensureLoaded();
    await controller.select(ArmorTab.skills, 'attack-boost');
    expect(loaded().tab, ArmorTab.skills);
    expect(controller.selectedSkill?.id, 'attack-boost');
    expect(controller.selectedSet, isNull);

    await controller.select(ArmorTab.sets, 'rathalos-x');
    expect(controller.selectedSet?.defense, 570);
    controller.clearSelection();
    expect(controller.selection, isNull);
  });
}
