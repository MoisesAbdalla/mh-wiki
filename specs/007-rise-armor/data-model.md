# Data Model: Armaduras, habilidades e joias da Rise: Sunbreak

## Dataset `assets/data/rise_sunbreak/armor.json` (schemaVersion 1)

```text
{
  schemaVersion: 1, game: "rise_sunbreak", generatedAt, sources[],
  skills: [{ id, name{en,ptBr}, description{en,ptBr}, levels: [{ level, effect{en,ptBr} }] }],
  decorations: [{ id, name{en,ptBr}, slotLevel 1..4, skills: [{ skill, level }],
                  forge: [cost], rarity }],
  materials: [{ id, name{en,ptBr}, sources? }],        // same shape as weapons.json (006 R13)
  sets: [{ id, name{en,ptBr}, rarity, rank, pieces: [pieceId] }],
  pieces: [{ id, kiranicoId, set, part: head|chest|arms|waist|legs,
             name{en,ptBr}, description{en,ptBr}, rarity 1..10,
             defense, maxDefense?, resistances{fire,water,thunder,ice,dragon},
             slots: [1..4], skills: [{ skill, level }], forge: [cost],
             image?, sources[] }]
}
cost = { material, quantity }
```

### Validation rules

- Unique ids per table, and every reference resolves: `set`, `pieces`, `skill` and `material`.
- Every piece of a set appears in the set's `pieces`, sorted by `part`.
- A skill's `level` is between 1 and its max level (the length of `levels`). Sums are not
  validated, because overflow is real data.
- `slotLevel` and `slots` hold values 1–4; there are at most 3 slots.
- When present, `maxDefense` is at least `defense`.

## Additions to `weapons.json`

```text
rampageSkills: [{ id, name{en,ptBr}, effect{en,ptBr} }],
rampageDecorations: [{ id, name{en,ptBr}, slotLevel 1..3, effect{en,ptBr} }],
weapons[].rampageSkills?: [rampageSkillId]   // Low/High Rank weapons only
```

## Domain (lib/features/armor/domain)

| Entity | Fields | Notes |
|--------|--------|-------|
| `ArmorPiece` | id, set, part, name, description, rarity, rank (from rarity), defense, maxDefense?, resistances, slots, skills (`SkillLevel`), forge (`MaterialCost` from core), imageAsset | |
| `ArmorSet` | id, name, rarity, rank, pieces | `defense`, `maxDefense`, `resistances` and `skills` are sums over the pieces |
| `BodyPart` | head, chest, arms, waist, legs | display order |
| `Resistances` | fire, water, thunder, ice, dragon | `+` for sums |
| `Skill` | id, name, description, levels (`SkillEffect`) | `maxLevel` = number of levels |
| `SkillLevel` | skill id, level | |
| `Decoration` | id, name, slotLevel, skills, forge, rarity | |
| `ArmorCatalog` | game, sets, pieces, skills, decorations | indexes by id; `piecesWith(skill)`, `decorationsFor(skill)` |

### Use cases

- `LoadArmorCatalog` returns `Result<ArmorCatalog>`.
- `FilterSets(catalog, SetQuery{rank?, text, skill?})` returns sets in rarity order, then name.
  The text matches the set or piece names in en and pt-BR; `skill` keeps the sets where some piece
  has the skill.
- `SumSetSkills(set)` returns the skills with their summed level and max level, sorted by level
  descending, then name.
- `SkillSources(catalog, skill)` returns the decorations that give the skill and the pieces that
  have it, grouped by rank, master rank first.

### Shared (lib/core)

`MaterialSources`, `RankedSources`, `GatheringSource`, `MonsterSource`, `QuestSource` and
`MaterialCost` move from `weapons` to `core/domain`. The material row with seals and its expand
table move to `core/presentation/widgets`.

## Presentation state

- `ArmorController` (ChangeNotifier) has the states `loading`, `failed(Failure)` and `loaded`. When
  loaded, it holds:
  - the tab: `sets`, `skills` or `decorations`;
  - per-tab queries: `SetQuery`, a skill search and a decoration query (text and slot level);
  - the selection: one set, skill or decoration.
- The catalog loads on the first visit to the Armaduras area.

## Localisation (ARB, pt-BR)

These strings are added to the ARB:
- the tabs: `armorTabSets`, `armorTabSkills`, `armorTabDecorations`;
- the body parts: `partHead`, `partChest`, `partArms`, `partWaist`, `partLegs`;
- the section titles: `armorSectionDefense`, `armorSectionSkills`, `armorSectionPieces`,
  `skillSectionLevels`, `skillSectionDecorations`, `skillSectionArmor`, `decorationSectionSkill`;
- the defense values: `defenseBase`, `defenseMax`;
- the counts and levels: `skillLevel`, `skillMaxLevel`, `skillOverflow`, `piecesCount`,
  `slotLevelFilter`;
- the search: `searchArmorHint`, `searchSkillHint`, `searchDecorationHint`;
- the Rampage card: `weaponSectionRampage`, `rampageChooseOne`, `rampageSlotFits`;
- the messages: `armorLoadFailed`, `noSetsFound`.
