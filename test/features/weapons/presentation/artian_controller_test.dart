import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/features/weapons/data/repositories/prefs_my_artian_repository.dart';
import 'package:mh_wiki/features/weapons/domain/entities/artian.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/artian_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 010 T014: saved Artian, on the device.
void main() {
  const build = ArtianBuild(
    type: 'great-sword',
    rarity: 8,
    element: 'ice',
    elementParts: 3,
    attackParts: 2,
    boosts: {ArtianBoost.attack: 4, ArtianBoost.affinity: 1},
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the repository keeps every field across a reload', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = PrefsMyArtianRepository(prefs);
    expect(await repo.load(), isEmpty);
    await repo.store([
      const MyArtian(id: 'a1', name: 'Gelo crítico', build: build),
    ]);
    final back = (await PrefsMyArtianRepository(prefs).load()).single;
    expect(back.id, 'a1');
    expect(back.name, 'Gelo crítico');
    expect(back.build.type, 'great-sword');
    expect(back.build.rarity, 8);
    expect(back.build.element, 'ice');
    expect(back.build.elementParts, 3);
    expect(back.build.attackParts, 2);
    expect(back.build.boosts, {ArtianBoost.attack: 4, ArtianBoost.affinity: 1});
  });

  test('corrupt data loads as empty', () async {
    SharedPreferences.setMockInitialValues({
      PrefsMyArtianRepository.key: '[{"id": 3}]',
    });
    final prefs = await SharedPreferences.getInstance();
    expect(await PrefsMyArtianRepository(prefs).load(), isEmpty);
  });

  test('save opens it; rename, update and delete', () async {
    final prefs = await SharedPreferences.getInstance();
    var tick = 0;
    final controller = ArtianController(
      repository: PrefsMyArtianRepository(prefs),
      clock: () => DateTime.fromMicrosecondsSinceEpoch(++tick),
    );
    await controller.ensureLoaded();
    controller.open('great-sword', 8);
    final saved = (await controller.save('Minha', build))!;
    expect(controller.selection?.myId, saved.id);
    expect(controller.mineOf('great-sword').single.name, 'Minha');
    expect(controller.mineOf('long-sword'), isEmpty);

    await controller.rename(saved.id, 'Outra');
    await controller.update(saved.id, build.copyWith(attackParts: 0));
    final reloaded = await PrefsMyArtianRepository(prefs).load();
    expect(reloaded.single.name, 'Outra');
    expect(reloaded.single.build.attackParts, 0);

    await controller.delete(saved.id);
    expect(controller.mine, isEmpty);
    expect(controller.selection, (
      type: 'great-sword',
      rarity: 8,
      myId: null,
    ), reason: 'back to the base');
    expect(await PrefsMyArtianRepository(prefs).load(), isEmpty);
  });
}
