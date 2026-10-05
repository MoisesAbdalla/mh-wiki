# Data Model: Armas e Armaduras da Wilds

## `assets/data/wilds/weapons.json` (same schema as Rise, schemaVersion 1)

The fields work as in 006: `weaponTypes`, `materials` (with `sources.monsters` from the Wilds
monster drops) and `weapons`. A Wilds weapon has:
- the 006 fields: `slug`, `type`, `name`, `rarity`, `tree`, `treeName`, `attack` (the displayed
  value), `affinity`, `special` (element or status kinds and values), `slots`, `sharpness`
  (`base` + `handicraft`), `previous`, `next`, `forge`, `upgrade`, `sources`, `image`;
- **`skills`** (new, optional): `[{ "skill": "poison-duration-up", "level": 1 }]`;
- no `rampageSlot`, and no `rampageSkills` or `rampageDecorations` at the top level.

**`artian`** (new, optional, top level): one entry per weapon type.

```json
{ "type": "great-sword",
  "weapons": [ { "rarity": 6, "name": { "en": "Artian Blade I", "ptBr": "…" }, "attack": 816,
                 "affinity": 5, "slots": [2, 2, 2], "sharpness": { "base": [...], "handicraft": [...] },
                 "image": "assets/images/wilds/icons/great-sword-6.webp" }, … ],
  "elements": { "fire": 450, "water": 450, "thunder": 450, "ice": 450, "dragon": 450,
                "poison": 300, "blast": 300, "sleep": 250, "paralysis": 250 },
  "elementsByRarity": { "6": { … }, "7": { … }, "8": { … } },
  "production": { "attack": 5, "affinity": 5, "infusion": 30 },
  "reinforcement": [ { "kind": "attack", "value": 5, "max": 5 },
                     { "kind": "affinity", "value": 5, "max": 3 },
                     { "kind": "element", "value": 50, "max": 4 },
                     { "kind": "sharpness", "value": 30, "max": 2 } ],
  "rolls": 5,
  "materials": [ … ] }
```

## `assets/data/wilds/armor.json` (same schema as Rise, schemaVersion 1)

- **`skills[]`** gain an optional `kind`: `weapon`, `armor`, `set` or `group`.
- **`decorations[]`** gain an optional `kind` (`weapon` or `armor`) and an optional `icon` colour.
  `skills` may hold two entries.
- **`sets[]`** gain two optional fields:
  - `bonus`: `{ "skill": "arkveld-hunger", "steps": [ { "pieces": 2, "name": { … }, "description": { … } }, … ] }`
  - `groupBonus`: the same shape, with one step of 3 pieces.
- **`talismans`** (new, optional, top level):

  ```json
  [ { "id": "abundance-charm", "ranks": [ { "level": 1, "name": { … }, "rarity": 4,
      "skills": [ { "skill": "free-meal", "level": 1 } ], "forge": [ … ] } ] } ]
  ```

**Validation**:
- unknown skill references are rejected;
- set steps need `pieces` from 1 to 5;
- talisman ranks are listed in level order;
- the Rise files stay valid unchanged.

## Domain additions

- `weapons/domain`:
  - `Weapon.skills` (`List<WeaponSkill>`, empty for Rise);
  - `ArtianBase`, `ArtianRules`;
  - `ArtianBuild` (the chosen element, parts and rolls);
  - `ArtianResult` (attack, affinity, element, sharpness, slots);
  - `simulateArtian(base, rules, build)` and `validateArtian(build)`, both pure;
  - `MyArtian(id, name, build)` and `MyArtianRepository`.
- `armor/domain`:
  - `Skill.kind` (`SkillKind`);
  - `ArmorDecoration.kind` (`DecorationKind`) and `skills` (one or two);
  - `ArmorSet.bonus` and `ArmorSet.groupBonus` (`SetBonus(skill, steps)`);
  - `Talisman(id, ranks)` with `TalismanRank`;
  - `ArmorCatalog.talismans`.

## Presentation

- **`EquipmentArea`** (in `lib/app/`): the `GameTabs` above an `IndexedStack` of per-game pages.
  It is used by Armas and by Armaduras, and each game's page is built on its first visit.
- **Weapon detail**:
  - a "Habilidades da arma" card when `skills` is not empty;
  - the Rampage card only for Rise;
  - the Artian simulator page for an `ArtianBase`.
- **Armor**:
  - a "Bônus do conjunto" card;
  - the Joias filters (kind and slot);
  - a Talismãs tab, shown when the catalog has talismans.

## Localisation (ARB)

These strings are added:
- `weaponSkills`, `setBonus`, `groupBonus`, `piecesN`;
- `skillKindWeapon`, `skillKindArmor`, `skillKindSet`, `skillKindGroup`;
- `decoKindWeapon`, `decoKindArmor`, `decoKindAll`;
- `talismansTab`, `talismanRank`;
- `artian`, `artianBuild`, `artianElement`, `artianParts`, `artianReinforcement`, `artianResult`;
- `saveMyArtian`, `myArtian`, `artianNoElement`;
- `partsRemaining`, `rollsRemaining`.
