# Implementation Plan: Armas e Armaduras da Wilds

**Branch**: `010-wilds-equipment` | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/010-wilds-equipment/spec.md`

## Summary

Bring the Wilds into Armas and Armaduras, using the Wilds' own icons, and add Artian weapons with a
simulator.

- **Data** (Python, `tool/data/`):
  - `fetch_wilds_equipment.py` caches wilds.mhdb.io (en and pt-BR);
  - `fetch_wilds_icons.py` takes the wiki's `MHWA-*_Icon_Rare_N`, decoration icons and weapon
    renders, plus Kiranico Wilds piece renders;
  - `build_wilds_equipment.py` writes `assets/data/wilds/weapons.json` and `armor.json` in the
    006/007 schemas, with optional additions: weapon skills, set and group bonuses, decoration kind,
    talismans and Artian (research R1–R4).
- **App**:
  - Armas and Armaduras get game tabs, with one controller and page per game;
  - the `weapons` and `armor` features learn the Wilds additions: a weapon skills card, a set bonus
    card, Joias filters and a Talismãs tab;
  - a pure-Dart Artian simulator in `weapons/domain`, with saved Artians on the device;
  - Monstros (Wilds) gets "Armas feitas com ele".

## Technical Context

**Language/Version**: Dart 3.13 / Flutter 3.47 (unchanged); Python 3 for the data tools.

**Primary Dependencies**: none added.

**Storage**:
- new assets: `assets/data/wilds/weapons.json` and `armor.json`, an estimated 3–6 MB in total;
- new icon folders: `assets/images/wilds/` with icons and renders, an estimated 5–10 MB;
- device preferences for the saved Artians.

**Testing**:
- DTO and real-dataset tests for Wilds;
- Artian simulator unit tests (SC-004);
- widget, accessibility and integration tests.

**Target Platform**: Android, tablet, web, Windows (unchanged).

**Project Type**: cross-platform client app.

**Performance Goals**: the Wilds weapons list opens in ≤ 1 s after its first load (SC-005), and
each dataset loads on its tab's first visit.

**Constraints**:
- offline;
- Rise data and behaviour unchanged;
- Wilds failures stay inside the Wilds tabs;
- the APK grows by ≤ 15 MB.

**Scale/Scope**:
- 3 Python scripts and 2 datasets;
- changes in `weapons`, `armor`, `monsters` (one link) and `app` (game tabs);
- an `artian` sub-module.

## Constitution Check

| Principle | Gate | Pre | Post |
|-----------|------|-----|------|
| I. Clean Architecture | New entities and the simulator in each feature's `domain`; DTO changes in `data`; game tabs in `lib/app/` | ✅ | ✅ |
| II. MVC | Per-game controllers; `ArtianController` uses domain functions; views have no logic | ✅ | ✅ |
| III. Dependency rule / DI | Repositories per game wired in `AppDependencies`; `MyArtianRepository` abstraction | ✅ | ✅ |
| IV. Offline, versioned data | Same schema version, with optional additions; each source recorded; saved Artians versioned | ✅ | ✅ |
| V. Multi-game | The point of this feature: the existing `Game.wilds` key, data per game, per-game state | ✅ | ✅ |
| VI. Tests | research R6 | ✅ | ✅ |
| VII. i18n, lints | Names in en and pt-BR from mhdb; strings in ARB | ✅ | ✅ |
| New packages justified | none | ✅ | ✅ |

**Result**: PASS.

## Project Structure

### Documentation (this feature)

```text
specs/010-wilds-equipment/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── contracts/ui-contract.md
├── mockups/approved.html, mockups/artian.html
└── checklists/requirements.md
```

### Source Code (changes)

```text
tool/data/
├── fetch_wilds_equipment.py      # NEW
├── fetch_wilds_icons.py          # NEW
└── build_wilds_equipment.py      # NEW
assets/data/wilds/weapons.json, armor.json   # NEW
assets/images/wilds/{icons,weapons,armor}/   # NEW
lib/
├── app/
│   ├── equipment_area.dart       # NEW: GameTabs + IndexedStack of per-game pages
│   ├── app_home.dart             # Armas/Armaduras areas per game; Wilds monster link
│   └── di/app_dependencies.dart  # per-game repositories/controllers, Artian repository
├── features/weapons/
│   ├── domain/                   # + WeaponSkill, artian/ (base, rules, build, simulate, MyArtian)
│   ├── data/                     # dto: skills, artian; prefs MyArtian repository
│   └── presentation/             # skills card, Artian group + simulator, Wilds icons
└── features/armor/
    ├── domain/                   # + SkillKind, DecorationKind, SetBonus, Talisman
    ├── data/                     # dto additions
    └── presentation/             # bonus card, Joias filters, Talismãs tab
test/ … mirrors the above
```

**Structure Decision**: extend the existing features rather than fork them per game. The game is
already part of every controller and dataset (constitution V). Game tabs are composed in
`lib/app/`, so features stay unaware of each other.

## Complexity Tracking

No violations.
