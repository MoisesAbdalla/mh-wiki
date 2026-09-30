# Implementation Plan: Todos os Monstros Grandes

**Branch**: `004-all-large-monsters` | **Date**: 2026-09-30 | **Spec**: [spec.md](spec.md)

## Summary

Grow the three datasets from 10 curated monsters to each game's full large-monster roster (about
34 in Wilds, 78 in Rise and 71 in World, plus versions). Delivery is one game at a time: Wilds,
then Rise, then World.

- **Versions**: tempered, arch-tempered, afflicted, frenzied, apex, risen and guardian entries
  are separate monsters linked to their base.
- **List**: versions are collapsed into the base row and picked in the detail.
- **Inheritance**: a version inherits weaknesses, parts, habitats and item reactions from its
  base, marked "Igual à forma base". HP and materials are never inherited.
- **Data build**: the extraction scripts move into `tool/data/` so each game's data can be
  rebuilt from a checked-in roster, with the 001–003 rules.
- **Performance**: parsing moves off the UI thread, and search names are normalized once per
  load.

## Technical Context

**Language/Version**: Dart 3.13 / Flutter 3.47 (unchanged). Data tooling: Python 3 (stdlib +
Pillow), outside the app build.
**Primary Dependencies**: none added to the app.
**Storage**: the per-game JSON assets gain optional `versionOf` / `versionKind`. Versions may
omit inheritable sections. About 4 MB of JSON and 6–8 MB of WebP icons when complete.
**Testing**:
- DTO validation (versions, kinds, inheritance, effective parts)
- Mapper inheritance
- `FilterMonsters` grouping, search on version names and matched version
- Controller selection of versions
- Widgets: list row hint, version selector, "Igual à forma base"
- Real-dataset coverage against the roster
- Performance test with a 300-entry catalog
- The existing accessibility suite
**Target Platform**: Android, tablet, web, Windows (unchanged).
**Performance Goals**: list shown ≤ 1 s after start or game switch; search updates ≤ 300 ms per
key (SC-004/005).
**Constraints**: offline; no invented values; pt-BR names only when official; a11y rules of
002/003.
**Scale/Scope**: about 180 base monsters plus versions (about 250 entries) across three games.

## Constitution Check

| Principle | Pre | Post-design |
|-----------|-----|-------------|
| I Clean Architecture per feature | ✅ | ✅ `VersionKind`, `MonsterEntry` and `GetMonsterVersions` are pure Dart; inheritance happens in the `data` mapper |
| II MVC | ✅ | ✅ the controller keeps using use cases only; the selector calls `controller.select` |
| III Dependency rule / explicit DI | ✅ | ✅ the new use case is wired in `AppDependencies` |
| IV Offline, versioned data, abstract datasource, DTO→entity in data | ✅ | ✅ additive v1 fields; parsing moves to an isolate inside the asset datasource; the datasource interface is unchanged |
| V Multi-game first class | ✅ | ✅ per-game rosters and allowed kinds; identity stays (game, slug) |
| VI Tests (TDD) | ✅ | ✅ test-first tasks per layer |
| VII i18n (pt-BR ARB), lints | ✅ | ✅ new strings (version labels, "N versões", "Igual à forma base") |

**Tooling note**: `tool/data/` holds Python scripts that are not compiled or shipped. They are
not an app dependency, so no amendment is needed. They exist to satisfy the "registrar origem
para permitir auditoria e atualização" constraint.

**Result**: PASS (pre and post design).

## Project Structure

### Documentation (this feature)

```text
specs/004-all-large-monsters/
├── plan.md  research.md  data-model.md  quickstart.md
├── contracts/ui-versions.md
└── tasks.md            # /speckit-tasks
```

### Source Code

```text
lib/features/monsters/
├── domain/entities/    version_kind.dart, monster_section_kind.dart, monster_entry.dart,
│                       monster.dart (+versionOf, versionKind, inheritedSections),
│                       monster_section.dart (entries)
├── domain/usecases/    filter_monsters.dart (grouping), get_monster_versions.dart
├── data/dtos/          monster_dataset_dto.dart (+version fields, optional sections, rules),
│                       monster_dataset_mapper.dart (inheritance)
├── data/datasources/   asset_monster_datasource.dart (parse in isolate)
└── presentation/
    ├── controllers/    monster_list_controller.dart (versions of selection)
    └── views/widgets/  monster_list_pane.dart (row hint, matched version),
                        version_selector.dart, inherited_note.dart,
                        monster_detail_view.dart (selector + notes)
lib/l10n/app_pt.arb     version labels, "N versões", "Igual à forma base"
assets/data/<game>/monsters.json, assets/images/monsters/<game>/*.webp
tool/data/              build.py, rosters/<game>.json, extract_*.py (moved from the scratchpad),
                        .cache/ (git-ignored)
test/…                  mirrors lib + real_datasets_test (roster coverage) + performance test
specs/001-monster-wiki/contracts/monster-dataset.schema.json  (+versionOf/versionKind)
```

**Structure Decision**: same feature-first Clean Architecture as 001–003. The only new
top-level folder is `tool/data/` for offline data tooling.

## Phases (delivery, spec Q2)

1. **App support + Wilds**:
   - Domain, data and presentation for versions, grouping, the selector, inheritance and
     performance.
   - Move the pipeline into `tool/data/`.
   - Build the Wilds roster: about 34 monsters, with Guardian Rathalos, Guardian Doshaguma and
     Guardian Arkveld as versions, plus tempered and arch-tempered versions where the sources
     have own data.
   - Gates, then merge.
2. **Rise: Sunbreak**:
   - Source check for apex, risen and afflicted (R4).
   - Build the roster, run the gates, merge.
3. **World: Iceborne**:
   - Source check for tempered and arch-tempered (R4).
   - Build the roster, run the gates, merge.

## Complexity Tracking

| Item | Why needed | Simpler alternative rejected because |
|------|------------|--------------------------------------|
| Versions as linked entries with inheritance | Spec Q1/Q3/Q5: versions are their own entries, collapsed in the list, and show base data marked as such | Duplicating base data in each version hides the inheritance and bloats the files |
| `tool/data/` Python pipeline in the repo | Around 250 entries across three phases must be reproducible and auditable | Scratchpad scripts are lost between sessions; rewriting them in Dart adds HTML-parsing dependencies |
