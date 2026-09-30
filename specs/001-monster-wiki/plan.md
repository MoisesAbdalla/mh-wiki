# Implementation Plan: Wiki de Monstros

**Branch**: `001-monster-wiki` | **Date**: 2026-09-29 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-monster-wiki/spec.md`

## Summary

Offline-first Flutter app (Android phone/tablet, web, Windows) that lists large monsters from
MH World: Iceborne, Rise: Sunbreak and Wilds (~10 per game in v1), with per-game filter
(sectioned "Todos" view), accent/case-insensitive search over pt-BR and English names, and a
detail view with elemental weaknesses (general + optional per-state), habitats, breakable parts
and materials grouped by rank with acquisition method and drop rate. A user setting chooses
whether game names display in pt-BR or English. Data ships as one versioned JSON asset per game;
architecture is Clean Architecture per feature with MVC presentation (`ChangeNotifier`
controllers), a manual composition root, and an adaptive list/detail layout at 840 dp.

## Technical Context

**Language/Version**: Dart 3.13 / Flutter stable 3.47.x

**Primary Dependencies**: Flutter SDK; `flutter_localizations` + `intl` (gen-l10n, R8);
`shared_preferences` (name-language preference, R7). Dev: `flutter_test`, `integration_test`,
`flutter_lints`.

**Storage**: bundled JSON assets (`assets/data/<game>/monsters.json`, read-only);
`shared_preferences` for one key (`name_language`).

**Testing**: `flutter_test` (unit + widget, hand-written fakes), dataset tests against real
assets, `integration_test` end-to-end on Android, Windows and Chrome (R16).

**Target Platform**: Android (phone + tablet), Web (modern Chrome/Edge/Firefox), Windows 10+
desktop (R1).

**Project Type**: cross-platform client app (mobile/web/desktop), no backend.

**Performance Goals**: filter/search results < 0.5 s (SC-002); detail open < 1 s (SC-003);
60 fps list scrolling.

**Constraints**: fully offline (FR-012; web after first load via custom service worker, R10);
domain in pure Dart; no third-party state management; UI in pt-BR via ARB.

**Scale/Scope**: ~30 monsters in v1, designed for ~200; 3 screens (list, detail, settings)
+ adaptive two-pane layout.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Pre-research | Post-design |
|-----------|------|--------------|-------------|
| I. Clean Architecture por feature | `features/{monsters,settings}/{domain,data,presentation}`; `core/` for shared; domain pure Dart | ✅ | ✅ project structure below; `LocalizedText`, search normalization and `Result` written in pure Dart (R6, R11) |
| II. Presentation em MVC | Model = entities + sealed view states; Controller = `ChangeNotifier` using only use cases; View = widgets without logic | ✅ | ✅ [domain-interfaces.md](contracts/domain-interfaces.md), [ui-contract.md](contracts/ui-contract.md); filtering/sorting in `FilterMonsters`, not in widgets |
| III. Regra de dependência + DI explícita | presentation → domain ← data; constructor injection; single composition root | ✅ | ✅ `lib/app/di/app_dependencies.dart` (R3); import checks in [quickstart.md](quickstart.md) |
| IV. Offline-first, dados versionados | local JSON, `schemaVersion`, abstract datasource, DTO→entity in data | ✅ | ✅ [monster-dataset.schema.json](contracts/monster-dataset.schema.json), `MonsterDatasource` interface, parse-time validation (R4, R5) |
| V. Multi-jogo 1ª classe | `Game` enum; identity (game, id); cross-game duplicates distinct; filter by game | ✅ | ✅ `MonsterId(game, slug)`, per-game files, ranks allowed per game |
| VI. Testes obrigatórios / TDD | unit (domain, controllers), widget (list, detail), dataset tests | ✅ | ✅ R16; test tree below mirrors lib |
| VII. Idioma, i18n, lints | code in English; UI strings in ARB (pt-BR); `flutter analyze` clean; `dart format` | ✅ | ✅ R8; game names from data, not hardcoded |
| Restrições: novos pacotes justificados | each package has rationale + rejected alternative | ✅ | ✅ `intl`/`flutter_localizations` (R8), `shared_preferences` (R7); none in domain |
| Restrições: erros modelados | no raw exceptions reach UI | ✅ | ✅ sealed `Failure`/`Result`, partial catalog (R11) |
| Restrições: origem dos dados | sources recorded | ✅ | ✅ `sources` required per dataset and per monster (R14) |

**Result**: PASS — no violations; Complexity Tracking not needed.

## Project Structure

### Documentation (this feature)

```text
specs/001-monster-wiki/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   ├── monster-dataset.schema.json
│   ├── domain-interfaces.md
│   └── ui-contract.md
├── checklists/requirements.md
└── tasks.md             # Phase 2 output (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
pubspec.yaml                      # name: mh_wiki
analysis_options.yaml             # flutter_lints + stricter rules
l10n.yaml
assets/
├── data/
│   ├── world_iceborne/monsters.json
│   ├── rise_sunbreak/monsters.json
│   └── wilds/monsters.json
└── images/monsters/<game>/<slug>.webp     # optional per monster
web/
├── flutter_bootstrap.js          # registers custom service worker (R10)
└── sw.js
lib/
├── main.dart                     # builds AppDependencies, runs MhWikiApp
├── app/
│   ├── app.dart                  # MaterialApp, theme, localization delegates
│   └── di/app_dependencies.dart  # composition root
├── core/
│   ├── domain/                   # game.dart, rank.dart, localized_text.dart, name_language.dart,
│   │                             # result.dart, failure.dart, search_normalizer.dart
│   └── presentation/             # breakpoints.dart, shared widgets (placeholder image, stars)
├── l10n/app_pt.arb
└── features/
    ├── monsters/
    │   ├── domain/
    │   │   ├── entities/         # monster.dart, monster_id.dart, weakness_profile.dart,
    │   │   │                     # habitat.dart, breakable_part.dart, material.dart,
    │   │   │                     # material_drop.dart, source_ref.dart, monster_catalog.dart,
    │   │   │                     # monster_query.dart, monster_section.dart
    │   │   ├── repositories/monster_repository.dart
    │   │   └── usecases/         # load_monster_catalog.dart, filter_monsters.dart,
    │   │                         # get_monster_by_id.dart
    │   ├── data/
    │   │   ├── datasources/      # monster_datasource.dart, asset_monster_datasource.dart
    │   │   ├── dtos/             # monster_dataset_dto.dart (+ nested DTOs), mappers
    │   │   └── repositories/monster_repository_impl.dart
    │   └── presentation/
    │       ├── controllers/monster_list_controller.dart
    │       ├── models/monster_list_state.dart
    │       └── views/            # monsters_page.dart, monster_detail_page.dart,
    │                             # widgets/ (monster_list_pane, monster_detail_view,
    │                             # weakness_section, habitat_section, parts_section,
    │                             # materials_section, game_filter_bar, search_field)
    └── settings/
        ├── domain/               # app_settings.dart, settings_repository.dart,
        │                         # usecases/load_settings.dart, set_name_language.dart
        ├── data/shared_prefs_settings_repository.dart
        └── presentation/         # settings_controller.dart, settings_page.dart
test/
├── core/domain/                  # localized_text, search_normalizer tests
├── features/monsters/
│   ├── domain/usecases/          # filter_monsters_test, load_monster_catalog_test, ...
│   ├── data/                     # dto parsing/validation tests, repository_impl_test,
│   │                             # real_datasets_test (loads assets/data/**)
│   └── presentation/             # controller tests, widget tests (list, detail, layout switch)
├── features/settings/            # repository, controller, page tests
└── fakes/                        # FakeMonsterRepository, FakeSettingsRepository, fixtures
integration_test/app_test.dart
test_driver/integration_test.dart
```

**Structure Decision**: single Flutter app at repository root (`mh_wiki`), feature-first with
Clean Architecture layers per feature and a shared `core/`. Two features for v1: `monsters`
(all three user stories) and `settings` (name-language preference). No backend project.

## Implementation Notes for /speckit-tasks

- Bootstrap: `flutter create --project-name mh_wiki --org dev.mhwiki --platforms=android,web,windows .`
  (repo root already has `.specify/`, `.claude/`, `specs/` — create must not clobber them).
- Suggested order (vertical slices, TDD inside each): core domain → US1 slice (catalog load +
  detail, one game dataset) → US2 (filter + sections, all three datasets) → US3 (search) →
  settings/name language → adaptive layout → web service worker → integration test.
- Datasets are curated content work; a minimal valid fixture per game should land first so code
  can progress while real data is filled in.

## Complexity Tracking

No constitution violations to justify.
