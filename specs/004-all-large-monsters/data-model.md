# Data Model: Todos os Monstros Grandes

Changes relative to features 001–003. All dataset changes are additive to schema v1: the new
fields are optional, and existing files stay valid.

## Dataset (JSON, per game)

New optional per-monster fields:

| Field | Type | Rule |
|-------|------|------|
| `versionOf` | slug | Must be a monster in the same dataset that is not itself a version (no chains, no cycles). |
| `versionKind` | enum `tempered` · `archTempered` · `afflicted` · `frenzied` · `apex` · `risen` · `guardian` | Required when `versionOf` is present, forbidden otherwise; must be allowed for the game (below). Unique per base (one entry per kind). |

For a version (`versionOf` present):

- `weaknesses`, `parts`, `habitatIds`, `itemReactions`, `classification` become **optional**;
  when absent they are inherited from the base.
- `name`, `drops`, `sources` stay required; `hp` and `image` stay optional.
- A version must carry at least one own datum (`hp` non-empty or `drops` non-empty).
- `drops[].partId` is checked against the effective parts (own or inherited).

Allowed kinds per game (validation):

| Game | Kinds |
|------|-------|
| World: Iceborne | `tempered`, `archTempered` |
| Rise: Sunbreak | `afflicted`, `apex`, `risen` |
| Wilds | `tempered`, `archTempered`, `guardian`, `frenzied` |

For base monsters, nothing changes: all 001–003 fields are required or optional as before.

## Domain (pure Dart)

- **`VersionKind`** (enum): tempered, archTempered, afflicted, frenzied, apex, risen, guardian.
- **`MonsterSectionKind`** (enum): weaknesses, parts, habitats, itemReactions, classification.
- **`Monster`** gains:
  - `MonsterId? versionOf`
  - `VersionKind? versionKind`
  - `Set<MonsterSectionKind> inheritedSections` (empty for base monsters)
  - `bool get isVersion`
- **`MonsterEntry`** (a list row): `Monster base`, `List<Monster> versions` (in `VersionKind`
  order), `Monster? matchedVersion` (set when the search matched only a version), and
  `Monster get target => matchedVersion ?? base`.
- **`MonsterSection`** (list section per game) holds `List<MonsterEntry>` instead of
  `List<Monster>`.
- **Use cases**:
  - `FilterMonsters` groups versions under their base, sorts entries by the base name in the
    selected language, and matches the text against base and version names.
  - `GetMonsterById` is unchanged (finds versions too).
  - New `GetMonsterVersions(monsterId)` returns the base plus its versions, for the detail
    selector.

## Mapping (data layer)

1. Parse all monsters.
2. Resolve each version's base.
3. Copy the absent sections from the base and record them in `inheritedSections`.
4. Build `HuntingInfo` with the base's reactions when inherited, and with the version's own `hp`.

## Presentation

- **`MonsterListState`**: the sections now hold entries. `selectedId` can be a version id.
- **Detail**: the view receives the monster, its version siblings and a callback that selects
  another version through the controller (`controller.select(id)`).
