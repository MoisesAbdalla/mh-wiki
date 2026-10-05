import 'package:mh_wiki/features/monsters/domain/entities/monster_material.dart';
import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';
import 'package:mh_wiki/features/weapons/data/dtos/weapon_dataset_dto.dart';
import 'package:mh_wiki/features/weapons/domain/entities/estimated_stars.dart';
import 'package:mh_wiki/core/domain/material_cost.dart';
import 'package:mh_wiki/core/domain/material_sources.dart';
import 'package:mh_wiki/features/weapons/domain/entities/sharpness.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_special.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_type.dart';

/// Turns a validated weapon dataset into domain entities.
abstract final class WeaponDatasetMapper {
  static WeaponCatalog toCatalog(WeaponDatasetDto dto) {
    final game = dto.game;
    final types = {
      for (final t in dto.types)
        t.id: WeaponType(id: t.id, name: t.name, ranged: t.ranged),
    };
    final materials = {
      for (final e in dto.materials.entries)
        e.key: MonsterMaterial(id: e.key, name: e.value),
    };
    WeaponId id(String slug) => WeaponId(game, slug);
    List<MaterialCost> costs(List<CostDto> list) => [
      for (final c in list)
        MaterialCost(
          material: materials[c.material]!,
          sources: dto.sources[c.material] ?? MaterialSources.none,
          quantity: c.quantity,
          points: c.points,
        ),
    ];

    return WeaponCatalog(
      game: game,
      types: types.values.toList(),
      rampageDecorations: dto.rampageDecorations,
      artian: dto.artian,
      weapons: [
        for (final w in dto.weapons)
          Weapon(
            id: id(w.slug),
            type: types[w.type]!,
            name: w.name,
            description: w.description,
            rarity: w.rarity,
            treeId: w.tree,
            treeName: w.treeName,
            attack: w.attack,
            affinity: w.affinity,
            special: [
              for (final (kind, value) in w.special)
                WeaponSpecial(kind: kind, value: value),
            ],
            slots: w.slots,
            rampageSlot: w.rampageSlot,
            sharpness: switch (w.sharpness) {
              (final base, final handicraft) => Sharpness(
                base: base,
                handicraft: handicraft,
              ),
              null => null,
            },
            previous: w.previous == null ? null : id(w.previous!),
            next: [for (final n in w.next) id(n)],
            forge: costs(w.forge),
            upgrade: costs(w.upgrade),
            stars: EstimatedStars(value: w.stars, estimated: w.starsEstimated),
            imageAsset: w.image,
            traits: w.traits,
            rampageSkills: w.rampageSkills,
            skills: w.skills,
            sources: [
              for (final (name, url) in w.sources)
                SourceRef(name: name, url: url),
            ],
          ),
      ],
    );
  }
}
