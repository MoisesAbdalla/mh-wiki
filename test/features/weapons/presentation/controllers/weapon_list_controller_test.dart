import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/load_weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/models/weapon_list_state.dart';

import '../../../../fakes/fake_weapon_repository.dart';
import '../../../../fakes/weapon_fixtures.dart';

/// 006 data-model "Presentation state": loading → loaded / failed.
void main() {
  late FakeWeaponRepository repository;
  late WeaponListController controller;

  setUp(() {
    repository = FakeWeaponRepository();
    controller = WeaponListController(
      loadCatalog: LoadWeaponCatalog(repository),
    );
  });

  WeaponListLoaded loaded() => controller.state as WeaponListLoaded;

  List<String> slugs() => [
    for (final t in loaded().trees)
      for (final e in t.entries) e.weapon.id.slug,
  ];

  test('loading, then loaded with the first type selected', () async {
    repository.completer = Completer();
    final future = controller.ensureLoaded();
    expect(controller.state, isA<WeaponListLoading>());

    repository.completer!.complete();
    await future;
    expect(loaded().query.typeId, 'great-sword');
    expect(loaded().trees.map((t) => t.id), ['bone-tree', 'anjanath-tree']);
  });

  test('loads once on first visit', () async {
    await controller.ensureLoaded();
    await controller.ensureLoaded();
    expect(repository.loadCount, 1);
  });

  test('a failure can be retried', () async {
    repository.failure = const DatasetUnavailable(Game.riseSunbreak);
    await controller.ensureLoaded();
    expect(controller.state, isA<WeaponListFailed>());

    repository.failure = null;
    await controller.load();
    expect(controller.state, isA<WeaponListLoaded>());
  });

  test('type, rank and search recompute the trees', () async {
    await controller.ensureLoaded();

    controller.setType('bow');
    expect(slugs(), ['hunters-bow']);

    controller
      ..setType('great-sword')
      ..setRank(Rank.master);
    expect(slugs(), [
      'gnashing-flammenzahn-plus',
      'lohenzahn-alt',
      'lohenzahn',
    ]);

    controller.setSearchText('aard');
    expect(slugs(), ['lohenzahn-alt']);

    controller.clearFilters();
    expect(loaded().query.hasFilters, isFalse);
    expect(loaded().query.typeId, 'great-sword');
  });

  test('the query and selection survive a reload', () async {
    await controller.ensureLoaded();
    controller
      ..setType('bow')
      ..setSearchText('hunter');
    await controller.select(wid('hunters-bow'));

    await controller.load();
    expect(loaded().query.typeId, 'bow');
    expect(loaded().query.text, 'hunter');
    expect(controller.selectedWeapon?.id, wid('hunters-bow'));
  });

  test('selecting a weapon of another type switches to it', () async {
    await controller.ensureLoaded();
    await controller.select(wid('hunters-bow'));
    expect(loaded().query.typeId, 'bow');
    expect(loaded().selectedId, wid('hunters-bow'));
  });

  test('show only a set of weapons, then clear it', () async {
    await controller.showOnly({
      wid('lohenzahn'),
      wid('hunters-bow'),
    }, 'Armas de Anjanath');
    expect(slugs(), ['lohenzahn', 'hunters-bow']);
    expect(loaded().query.onlyLabel, 'Armas de Anjanath');

    controller.clearOnly();
    expect(loaded().query.onlyIds, isNull);
    expect(slugs(), hasLength(7)); // every Great Sword
  });
}
