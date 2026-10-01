# Implementation Plan: Armas da Rise: Sunbreak

**Branch**: `006-rise-weapons` | **Date**: 2026-10-01 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/006-rise-weapons/spec.md`

## Summary

Add the first non-monster area of the app: a catalog of about 3,950 Rise: Sunbreak weapons (14
types).

- **Data**: built offline from the Monster Hunter Wiki's structured MHRS weapon pages (tree,
  materials, sharpness, slots) and the Kiranico lists (pt-BR names, icons, cross-check). Rank
  comes from rarity. Quest stars are estimated from the monsters that drop the materials.
- **App**: a new `weapons` feature (domain, data, presentation, following the constitution)
  shows the weapons grouped by upgrade tree, with a detail in numbered cards.
- **Navigation**: a new app shell adds bottom navigation (a rail on wide screens) between
  Monstros and Armas, with Armaduras and Assistente disabled until 007 and 008.
- **Monsters**: the monster detail gains a "Armas feitas com ele" card, wired in the composition
  root so the features stay independent.

## Technical Context

**Language/Version**: Dart 3.13 / Flutter 3.47 (unchanged). Data tooling: Python 3 (stdlib +
Pillow).

**Primary Dependencies**: none added to the app.

**Storage**:
- new asset `assets/data/rise_sunbreak/weapons.json`, about 1.5 MB of JSON;
- about 3,950 weapon icons at 96 px WebP (~20 MB);
- 14 weapon type icons.

**Testing**:
- `flutter_test`: unit (tree building, filters), DTO and mapper, a real-dataset test, widget
  tests (shell, list, detail, monster card), accessibility and performance (4,000 synthetic
  weapons);
- the integration test is extended to open a weapon.

**Target Platform**: Android, tablet, web, Windows (unchanged).

**Project Type**: cross-platform client app.

**Performance Goals**:
- a weapon type list appears in ≤ 1 s and scrolls smoothly (SC-004);
- the search query takes < 50 ms over 4,000 weapons.

**Constraints**:
- offline;
- the weapons dataset loads lazily and independently (FR-011);
- no new packages;
- the APK grows by about 20 MB (research R6).

**Scale/Scope**: 1 new feature module (~25 files), 1 app shell, 1 Python builder, about 3,950
records.

## Constitution Check

| Principle | Gate | Pre | Post |
|-----------|------|-----|------|
| I. Clean Architecture | `weapons` with domain (pure Dart) / data / presentation; cross-feature link only in `lib/app/` | ✅ | ✅ |
| II. MVC | `WeaponListController` holds state; views render; trees and filters in domain use cases | ✅ | ✅ |
| III. Dependency rule / DI | `WeaponRepository` abstraction; concrete wiring in `AppDependencies` | ✅ | ✅ |
| IV. Offline, versioned data | bundled JSON with `schemaVersion` 1 and sources per weapon; failures mapped to `Failure` | ✅ | ✅ |
| V. Multi-game | `WeaponId` carries the game; World/Wilds tabs present as "em breve" | ✅ | ✅ |
| VI. Tests | unit, widget, real-dataset, a11y, performance (R11) | ✅ | ✅ |
| VII. i18n, lints | new strings in ARB; code in English | ✅ | ✅ |
| New packages justified | none | ✅ | ✅ |

**Result**: PASS.

## Project Structure

### Documentation (this feature)

```text
specs/006-rise-weapons/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── contracts/ui-contract.md
├── mockups/approved.html
└── checklists/requirements.md
```

### Source Code (changes)

```text
tool/data/
├── build_rise_weapons.py          # NEW: wiki MHRS pages + Kiranico lists → weapons.json, icons
└── README.md                      # + the new script
assets/
├── data/rise_sunbreak/weapons.json            # NEW
└── images/weapons/rise_sunbreak/*.webp, types/*.webp   # NEW
lib/
├── app/
│   ├── app.dart                   # home = AppShell
│   ├── app_shell.dart             # NEW: NavigationBar / NavigationRail + IndexedStack
│   ├── di/app_dependencies.dart   # + WeaponRepository, WeaponListController
│   └── weapons_of_monster.dart    # NEW: cross-feature use case (research R7)
├── features/weapons/              # NEW
│   ├── domain/entities/           # weapon, weapon_type, weapon_special, sharpness,
│   │                              # material_cost, estimated_stars, weapon_tree, weapon_catalog, weapon_id
│   ├── domain/repositories/weapon_repository.dart
│   ├── domain/usecases/           # load_weapon_catalog, build_weapon_trees, filter_weapons
│   ├── data/                      # dtos (+ validation), mapper, asset datasource, repository impl
│   └── presentation/              # controller, weapons_page, list pane, detail view, widgets
│                                  # (type picker, tree card, sharpness bar, slot badges)
├── features/monsters/presentation/views/
│   └── widgets/monster_detail_view.dart   # + optional extraSections builder
└── l10n/app_pt.arb                # + strings (data-model.md)
test/
├── features/weapons/{domain,data,presentation}/…   # NEW
├── app/app_shell_test.dart                         # NEW
└── integration_test/app_test.dart                  # + open a weapon
```

**Structure Decision**: one new feature module mirroring `features/monsters`. The app shell and
the monster-to-weapons link live in `lib/app/`, the composition layer. The monsters feature
only gains an optional, feature-agnostic `extraSections` slot.

## Complexity Tracking

No violations.
