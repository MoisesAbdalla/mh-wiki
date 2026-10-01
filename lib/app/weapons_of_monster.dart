import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/presentation/material_sources.dart';

/// Joins monsters and weapons through their materials (006 research R7).
/// Lives in the app layer, so neither feature imports the other.
final class MonsterMaterialIndex {
  MonsterMaterialIndex(
    Iterable<Monster> monsters, {
    this.game = Game.riseSunbreak,
  }) : _bases = [
         for (final m in monsters)
           if (m.id.game == game && m.versionOf == null) m,
       ] {
    for (final monster in _bases) {
      for (final drop in monster.drops) {
        final list = _byMaterial.putIfAbsent(drop.material.id, () => []);
        if (!list.contains(monster)) list.add(monster);
      }
    }
  }

  final Game game;
  final List<Monster> _bases;
  final _byMaterial = <String, List<Monster>>{};
  final _byPoints = <String, List<Monster>>{};

  /// The base monsters that drop [materialId]. A points requirement such as
  /// "Anjanath Material(s)" (`anjanath-material-s`, `mr-…`, `…-plus-…`)
  /// points to its monster by name.
  List<Monster> droppersOf(String materialId) {
    final direct = _byMaterial[materialId];
    if (direct != null) return direct;
    return _byPoints.putIfAbsent(materialId, () => _byName(materialId));
  }

  List<Monster> _byName(String materialId) {
    final points = RegExp(r'^(?:mr-)?(.+?)(?:-plus)?-material-s$')
        .firstMatch(materialId);
    if (points == null) return const [];
    final slug = points.group(1)!;
    return [
      for (final m in _bases)
        if (m.id.slug == slug || m.id.slug.endsWith('-$slug')) m,
    ];
  }

  /// The "Dropado por" lookup for the weapon detail, names in [language].
  MaterialSourceLookup lookup(NameLanguage Function() language) =>
      MaterialSourceLookup(
        (id) => [
          for (final m in droppersOf(id))
            MaterialDropper(id: m.id, name: m.name.resolve(language())),
        ],
      );

  /// The weapons whose forge or upgrade uses a material [monster] drops
  /// (or its points), master rank first, then rarity, then name. Versions
  /// count as their base monster.
  List<Weapon> weaponsUsingMaterialsOf(
    Monster monster,
    Iterable<Weapon> weapons,
  ) {
    if (monster.id.game != game) return const [];
    final base = monster.versionOf ?? monster.id;
    bool fromMonster(String materialId) =>
        droppersOf(materialId).any((m) => m.id == base);
    final result = [
      for (final w in weapons)
        if ([...w.forge, ...w.upgrade].any((c) => fromMonster(c.material.id)))
          w,
    ];
    return result..sort((a, b) {
      final byRank = _rankOrder(b.rank).compareTo(_rankOrder(a.rank));
      if (byRank != 0) return byRank;
      final byRarity = b.rarity.compareTo(a.rarity);
      return byRarity != 0 ? byRarity : a.name.en.compareTo(b.name.en);
    });
  }

  static int _rankOrder(Rank rank) => Rank.values.indexOf(rank);
}

/// Unwraps the opaque id of a [MaterialDropper] built by this index.
MonsterId monsterIdOf(MaterialDropper dropper) => dropper.id as MonsterId;
