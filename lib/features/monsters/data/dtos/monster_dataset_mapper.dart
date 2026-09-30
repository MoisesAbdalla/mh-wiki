import 'package:mh_wiki/features/monsters/data/dtos/monster_dataset_dto.dart';
import 'package:mh_wiki/features/monsters/domain/entities/breakable_part.dart';
import 'package:mh_wiki/features/monsters/domain/entities/habitat.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/material_drop.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_material.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_profile.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_state.dart';

/// Converts a validated dataset into domain entities, resolving habitat and
/// material references. References are guaranteed valid by the DTO.
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

    return [
      for (final m in dataset.monsters)
        Monster(
          id: MonsterId(dataset.game, m.slug),
          name: m.name,
          classification: m.classification,
          imageAsset: m.image,
          weaknesses: WeaknessProfile(
            general: m.general,
            states: [
              for (final s in m.states)
                WeaknessState(id: s.id, name: s.name, values: s.values),
            ],
          ),
          habitats: [for (final id in m.habitatIds) habitats[id]!],
          parts: [
            for (final p in m.parts)
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
            reactions: m.reactions,
          ),
        ),
    ];
  }
}
