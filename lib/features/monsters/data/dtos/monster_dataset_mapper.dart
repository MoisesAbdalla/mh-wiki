import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_dto.dart';
import 'package:mh_wiki/features/monsters/domain/entities/breakable_part.dart';
import 'package:mh_wiki/features/monsters/domain/entities/habitat.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/material_drop.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_material.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_section_kind.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_profile.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_state.dart';

/// Converts a validated dataset into domain entities, resolving habitat and
/// material references and the sections a version inherits from its base.
/// References are guaranteed valid by the DTO.
abstract final class MonsterDatasetMapper {
  static List<Monster> toMonsters(MonsterDatasetDto dataset) {
    final habitats = {
      for (final h in dataset.habitats.values)
        h.id: Habitat(id: h.id, name: h.name),
    };
    final materials = {
      for (final m in dataset.materials.values)
        m.id: MonsterMaterial(id: m.id, name: m.name, rarity: m.rarity),
    };

    final bySlug = {for (final m in dataset.monsters) m.slug: m};

    Monster toMonster(MonsterDto m) {
      // A version takes each absent section from its base (004 research R3).
      final base = m.versionOf == null ? null : bySlug[m.versionOf]!;
      final inherited = <MonsterSectionKind>{};
      T pick<T>(T? own, T Function(MonsterDto) fromBase, MonsterSectionKind k) {
        if (own != null || base == null) return own as T;
        inherited.add(k);
        return fromBase(base);
      }

      final classification = pick(
        m.classification,
        (b) => b.classification!,
        MonsterSectionKind.classification,
      );
      final (general, states) = pick(
        m.general == null ? null : (m.general!, m.states!),
        (b) => (b.general!, b.states!),
        MonsterSectionKind.weaknesses,
      );
      final habitatIds = pick(
        m.habitatIds,
        (b) => b.habitatIds!,
        MonsterSectionKind.habitats,
      );
      final parts = pick(m.parts, (b) => b.parts!, MonsterSectionKind.parts);
      final reactions = pick(
        m.reactions,
        (b) => b.reactions!,
        MonsterSectionKind.itemReactions,
      );

      return Monster(
        id: MonsterId(dataset.game, m.slug),
        name: m.name,
        classification: classification,
        imageAsset: m.image,
        weaknesses: WeaknessProfile(
          general: general,
          states: [
            for (final s in states)
              WeaknessState(id: s.id, name: s.name, values: s.values),
          ],
        ),
        habitats: [for (final id in habitatIds) habitats[id]!],
        parts: [
          for (final p in parts)
            BreakablePart(id: p.id, name: p.name, severable: p.severable),
        ],
        drops: [
          for (final d in m.drops)
            MaterialDrop(
              material: materials[d.materialId]!,
              rank: d.rank,
              method: d.method,
              methodLabel: d.methodLabel,
              partId: d.partId,
              ratePercent: d.ratePercent,
            ),
        ],
        sources: m.sources,
        huntingInfo: HuntingInfo(
          hp: m.hp,
          partyFactors: dataset.partyFactors,
          items: dataset.huntingItems,
          reactions: reactions,
        ),
        versionOf: base == null ? null : MonsterId(dataset.game, base.slug),
        versionKind: m.versionKind,
        inheritedSections: inherited,
      );
    }

    return [for (final m in dataset.monsters) toMonster(m)];
  }
}
