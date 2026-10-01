# Data Model: Armas da Rise: Sunbreak

The monster datasets do not change. A new dataset file and new domain entities are added.

## Dataset: `assets/data/rise_sunbreak/weapons.json` (schemaVersion 1)

```jsonc
{
  "schemaVersion": 1,
  "game": "rise_sunbreak",
  "generatedAt": "2026-10-01",
  "sources": [ { "name", "url", "notes" } ],
  "starRule": "…",                          // research R3, shown in the app's sources
  "weaponTypes": [
    { "id": "great-sword", "name": { "en": "Great Sword", "ptBr": "Espada Grande" }, "ranged": false }
  ],
  "materials": [ { "id": "anjanath-hardfang", "name": { "en": "...", "ptBr": "..." } } ],
  "weapons": [
    {
      "slug": "gnashing-flammenzahn-plus",
      "type": "great-sword",
      "name": { "en": "Gnashing Flammenzahn+", "ptBr": "..." },
      "description": { "en": "..." },
      "rarity": 8,
      "tree": "anjanath",                  // slug of the wiki "Tree"
      "treeName": { "en": "Anjanath Tree" },
      "attack": 280,
      "affinity": -20,                     // percent, may be negative
      "special": [ { "kind": "fire", "value": 28 } ],   // 0..2 entries; kinds below
      "slots": [3],                        // decoration slot levels, 0..3 entries, each 1..4
      "rampageSlot": 2,                    // 0 when none
      "sharpness": { "base": [130,100,40,50,20,10,0], "handicraft": [130,100,40,50,20,60,0] },
      "previous": "gnashing-flammenzahn",  // null for a root
      "next": ["lohenzahn"],
      "forge": [ { "material": "...", "quantity": 2 } ],    // empty when only upgraded
      "upgrade": [ { "material": "anjanath-hardfang", "quantity": 3 } ],
      "stars": { "value": 2, "estimated": true },
      "image": "assets/images/weapons/rise_sunbreak/gnashing-flammenzahn-plus.webp",
      "sources": [ { "name": "Monster Hunter Wiki (MHRS)", "url": "…" },
                   { "name": "Kiranico (MH Rise: Sunbreak)", "url": "…/data/weapons/1375999212" } ]
    }
  ]
}
```

### Validation rules (DTO, like the monster datasets)

- `game` must equal the requested game, and `schemaVersion` must be 1.
- Slugs must be unique. `type` must be one of `weaponTypes`, and `rarity` must be 1–10.
- `attack` must be > 0.
- `special.kind` must be one of `fire`, `water`, `thunder`, `ice`, `dragon`, `poison`, `sleep`,
  `paralysis`, `blast`, and `value` must be > 0.
- Each slot level must be 1–4, with at most 3 slots. `rampageSlot` must be 0–3.
- `sharpness` is required when the type is not `ranged` and absent when it is ranged. Each bar
  has 7 non-negative integers, and `handicraft` is greater than or equal to `base` in every
  segment.
- `previous` and `next` must reference existing slugs, and the previous/next relation must
  agree both ways.
- Every material reference must exist in `materials`, with quantity ≥ 1.
- `stars.value` must be 1–7 (Village and Hub go up to 7★ in Low/High Rank, MR up to 6★).

## Domain entities (`lib/features/weapons/domain/entities/`)

| Entity | Fields | Notes |
|--------|--------|-------|
| `WeaponType` | `id`, `name` (LocalizedText), `ranged` | 14 per game |
| `Weapon` | `id` (`WeaponId`: game + slug), `type`, `name`, `description`, `rarity`, `rank` (from rarity: 1–3 low, 4–7 high, 8–10 master), `tree` (`WeaponTreeId`), `treeName`, `attack`, `affinity`, `special` (`List<WeaponSpecial>`), `slots`, `rampageSlot`, `sharpness` (`Sharpness?`), `previous` (`WeaponId?`), `next`, `forge`, `upgrade` (`List<MaterialCost>`), `stars` (`EstimatedStars`), `imageAsset`, `sources` | `rank` is derived in the mapper, not stored |
| `WeaponSpecial` | `kind` (`SpecialKind`: the 5 elements + 4 statuses), `value` | elements reuse `ElementType` colours and icons |
| `Sharpness` | `base`, `handicraft` (each 7 ints) | `maxUnits` = 400 for drawing |
| `MaterialCost` | `material` (`MonsterMaterial` reused from monsters: id + names), `quantity` | |
| `EstimatedStars` | `value`, `estimated` | |
| `WeaponTree` | `id`, `name`, `entries` (`List<(Weapon, depth)>` in display order) | built by `BuildWeaponTrees` |
| `WeaponCatalog` | `game`, `types`, `weapons`, `trees` | loaded once per game |

### Use cases (`lib/features/weapons/domain/usecases/`)

- `LoadWeaponCatalog(game)` returns `Result<WeaponCatalog>` through the `WeaponRepository`
  abstraction.
- `BuildWeaponTrees(weapons)` returns `List<WeaponTree>`. The trees are ordered by their
  root's rarity, then name. Cycles are an error at load time (mapped to a dataset failure).
- `FilterWeapons(catalog, WeaponQuery{type, rank?, text})` returns the trees with only the
  matching entries, dropping empty trees. The search is accent- and case-insensitive over the
  en and pt-BR names.

### Cross-feature (`lib/app/`)

- `WeaponsUsingMaterialsOf(monster, catalog)` returns `List<Weapon>` whose forge or upgrade uses
  a material the monster drops (same game). They are sorted by rank (master first), then
  rarity, then name.

## Presentation state

- `WeaponListController` (ChangeNotifier) holds the states `loading`, `failed(Failure)` and
  `loaded(catalog, query, visibleTrees, selectedId)`. The query keeps the type, rank and text.
  The selected weapon survives area switches (`IndexedStack`).
- `AppShell` owns the selected area index: `0 Monstros`, `1 Armas`; `2` and `3` are disabled.

## Localisation (ARB, pt-BR)

`areaMonsters`, `areaWeapons`, `areaArmor`, `areaAssistant`, `areaComingSoon`,
`weaponTypeLabel`, `rankAll`, `weaponSectionAttributes`, `weaponSectionSharpness`,
`weaponSectionMaterials`, `weaponSectionTree`, `attack`, `affinity`, `slots`, `rampageSlot`,
`sharpnessBase`, `sharpnessHandicraft`, `forgeMaterials`, `upgradeMaterials`, `droppedBy`,
`treePrevious`, `treeCurrent`, `treeNext`, `starsEstimated`, `weaponsMadeFrom`,
`seeAllWeapons`, `weaponsLoadFailed`, `noWeaponsFound`, plus the 4 status names
(`statusPoison`, `statusSleep`, `statusParalysis`, `statusBlast`).
