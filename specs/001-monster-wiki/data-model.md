# Data Model: Wiki de Monstros (001-monster-wiki)

**Date**: 2026-09-29 | **Plan**: [plan.md](plan.md) | **Research**: [research.md](research.md)

Domain entities live in `lib/core/domain` (shared) and `lib/features/<feature>/domain`.
All are immutable, pure Dart, with value equality. Serialization lives only in DTOs
(`data` layer) — see [contracts/monster-dataset.schema.json](contracts/monster-dataset.schema.json).

## Shared (core/domain)

### Game (enum)

| Value | Display (pt-BR UI string, via l10n) | Order | Allowed ranks |
|-------|-------------------------------------|-------|---------------|
| `worldIceborne` | Monster Hunter World: Iceborne | 0 | low, high, master |
| `riseSunbreak` | Monster Hunter Rise: Sunbreak | 1 | low, high, master |
| `wilds` | Monster Hunter Wilds | 2 | low, high |

Dataset key (asset folder / JSON `game`): `world_iceborne`, `rise_sunbreak`, `wilds`.

### LocalizedText (value object)

| Field | Type | Rules |
|-------|------|-------|
| `en` | String | required, non-empty |
| `ptBr` | String? | optional; `null` when no official translation |

- `resolve(NameLanguage lang)` → `ptBr ?? en` for `ptBr`; `en` for `en` (FR-024).
- `matches(String normalizedQuery)` → true if normalized `en` or normalized `ptBr` contains it
  (FR-004, FR-023).

### NameLanguage (enum) — `ptBr` (default) | `en`

### Rank (enum) — `low` | `high` | `master`

### Result / Failure

- `sealed class Result<T>`: `Success<T>(T value)` | `Err<T>(Failure failure)`.
- `sealed class Failure`: `DatasetUnavailable(Game)`, `DatasetFormatInvalid(Game, String detail)`,
  `UnsupportedSchemaVersion(Game, int found)`, `MonsterNotFound(MonsterId)`,
  `PreferenceStorageFailure(String detail)`.

## Monsters feature (features/monsters/domain)

### MonsterId (value object)

| Field | Type | Rules |
|-------|------|-------|
| `game` | Game | required |
| `slug` | String | required, `^[a-z0-9]+(-[a-z0-9]+)*$`, unique within the game |

Identity of a Monster is `(game, slug)` (constitution Principle V). Same `slug` in different
games = different monsters (FR-013).

### Monster (aggregate root)

| Field | Type | Rules / source requirement |
|-------|------|----------------------------|
| `id` | MonsterId | unique per (game, slug) |
| `name` | LocalizedText | FR-001, FR-021 |
| `classification` | LocalizedText | e.g. "Wyvern Voadora" / "Flying Wyvern" (FR-007) |
| `imageAsset` | String? | asset path; `null` ⇒ generic placeholder |
| `weaknesses` | WeaknessProfile | FR-008, FR-008a |
| `habitats` | List<Habitat> | may be empty ⇒ "nenhum habitat fixo" (FR-016) |
| `parts` | List<BreakablePart> | may be empty ⇒ "nenhuma parte quebrável" (FR-016) |
| `drops` | List<MaterialDrop> | FR-011; may be empty per rank |
| `sources` | List<SourceRef> | ≥ 1 (SC-005 traceability) |

Derived (in domain, not stored): `dropsByRank` → `Map<Rank, List<MaterialDropGroup>>` grouping
drops by rank, then by material, preserving each (method, part, rate) row. Ranks with no
drops are absent from the map (edge case "monstro sem materiais em algum rank").

### Element (enum) — `fire` | `water` | `thunder` | `ice` | `dragon`

### Effectiveness (enum, ordered)

`immune` < `none` (0★) < `low` (1★) < `medium` (2★) < `high` (3★). `immune` is rendered
distinctly from `none` (edge case).

### WeaknessProfile

| Field | Type | Rules |
|-------|------|-------|
| `general` | Map<Element, Effectiveness> | must contain all 5 elements |
| `states` | List<WeaknessState> | optional; empty for most monsters |

Derived: `mostEffective` → set of elements with the maximum `general` value, only when that max
is `medium` (2★) or `high` (3★); ties return all tied elements. **Empty** when the max is `low`,
`none` or `immune` (FR-008; edge case "sem fraquezas relevantes" — nothing highlighted).

### WeaknessState

| Field | Type | Rules |
|-------|------|-------|
| `id` | String | slug, unique within the monster |
| `name` | LocalizedText | e.g. "Enfurecido" |
| `values` | Map<Element, Effectiveness> | must contain all 5 elements |

### Habitat

| Field | Type | Rules |
|-------|------|-------|
| `id` | String | slug, unique within the game |
| `name` | LocalizedText | FR-009 |

### BreakablePart

| Field | Type | Rules |
|-------|------|-------|
| `id` | String | slug, unique within the monster |
| `name` | LocalizedText | FR-010 |
| `severable` | bool | true ⇒ UI marks as "cortável" |

### Material

| Field | Type | Rules |
|-------|------|-------|
| `id` | String | slug, unique within the game |
| `name` | LocalizedText | |
| `rarity` | int? | 1–12 when known |

### MaterialDrop (Forma de Obtenção)

| Field | Type | Rules |
|-------|------|-------|
| `material` | Material | |
| `rank` | Rank | must be allowed for the monster's game |
| `method` | DropMethod | |
| `methodLabel` | LocalizedText? | required iff `method == other` |
| `partId` | String? | required iff `method == breakPart`; must reference `parts[].id` (FR-011a) |
| `ratePercent` | double? | 0 < x ≤ 100; `null` ⇒ "taxa desconhecida" (FR-011b) |

### DropMethod (enum)

`carve` | `tailCarve` | `capture` | `breakPart` | `questReward` | `droppedMaterial` | `other`

### SourceRef

| Field | Type | Rules |
|-------|------|-------|
| `name` | String | e.g. "Kiranico" |
| `url` | String | absolute http(s) URL |
| `notes` | String? | e.g. weakness conversion rule used (research R12) |

### MonsterCatalog (use case output)

| Field | Type | Meaning |
|-------|------|---------|
| `monsters` | List<Monster> | all monsters from games that loaded |
| `failedGames` | Map<Game, Failure> | games whose dataset failed (FR-017) |

### MonsterQuery (use case input)

| Field | Type | Default |
|-------|------|---------|
| `game` | Game? | `null` = "Todos" |
| `text` | String | `""` |
| `language` | NameLanguage | from settings |

Result of `FilterMonsters`: `List<MonsterSection>` where `MonsterSection = (Game game,
List<Monster> monsters)`; sections ordered by `Game.order`, monsters sorted by
`name.resolve(language)` (FR-006, FR-025), empty sections omitted.

## Settings feature (features/settings/domain)

### AppSettings

| Field | Type | Default |
|-------|------|---------|
| `nameLanguage` | NameLanguage | `ptBr` |

## Presentation state (Model in MVC)

### MonsterListState (sealed)

- `MonsterListLoading`
- `MonsterListLoaded(sections, query, failedGames, selectedId?)` — `isEmpty` when no sections;
  `hasActiveFilters` when `query.game != null || query.text.isNotEmpty`.
- `MonsterListLoadFailed(Failure)` — only when **all** games failed.

State transitions:

```text
Loading ──load ok (≥1 game)──▶ Loaded
Loading ──all games failed──▶ LoadFailed ──retry──▶ Loading
Loaded ──setGame / setText / language changed──▶ Loaded (re-filtered, selection kept)
Loaded ──select(id)──▶ Loaded(selectedId = id)
Loaded ──clearFilters──▶ Loaded(query reset)
```

### MonsterDetailState — derived from `Loaded.selectedId` + catalog; no separate loading state
(entities are already in memory).

### SettingsState — `AppSettings` + `isSaving` flag; failures surface as a transient message and
keep the in-memory choice for the session.

## Validation rules enforced at parse time (data layer)

1. `schemaVersion == 1`, else `UnsupportedSchemaVersion`.
2. File `game` matches the asset folder, else `DatasetFormatInvalid`.
3. Unique `slug` per game; unique part/state ids per monster; unique habitat/material ids per game.
4. Every weakness map has exactly the 5 elements.
5. `rank` allowed for the game (Wilds: no `master`).
6. `breakPart` drops reference an existing part id; `other` drops have `methodLabel`;
   every `habitatIds[]` and `drops[].materialId` references an entry in the file's top-level
   `habitats` / `materials` (the DTO→entity mapper resolves them into `Habitat` / `Material`).
7. `ratePercent` in (0, 100] when present.
8. At least one `sources` entry per dataset and per monster.
