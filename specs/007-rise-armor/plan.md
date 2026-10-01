# Implementation Plan: Armaduras, habilidades e joias da Rise: Sunbreak

**Branch**: `007-rise-armor` | **Date**: 2026-10-01 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/007-rise-armor/spec.md`

## Summary

Turn on the Armaduras area with a catalog of the Rise: Sunbreak armor (~1,500 pieces grouped
into sets), skills (147), decorations (243), and the weapons' Rampage options.

- **Data**: a new `tool/data/build_rise_armor.py` builds `assets/data/rise_sunbreak/armor.json`:
  - Kiranico armor lists (en and pt-BR) give names, defense, resistances, slots, skills and icons;
  - Kiranico armor pages give the forge materials;
  - Monster Hunter Wiki set pages give the set, body part and max defense;
  - Kiranico skills and decorations lists (en and pt-BR) give the skill levels and the jewels;
  - material sources reuse 006's Kiranico item-page logic, moved to a shared helper.

  The weapons dataset gains the Rampage skills of each Low/High Rank weapon and the Rampage
  decorations (research R6).
- **App**: a new `armor` feature (domain, data, presentation):
  - the Conjuntos, Habilidades and Joias tabs;
  - set, skill and decoration details in numbered cards, as in the approved mockup (option A).
- **Shared**: the material sources model and the material row with source seals move from
  `weapons` to `core`, so armor and decorations reuse them.
- **Weapons**: a Rampage card on the weapon detail.

## Technical Context

**Language/Version**: Dart 3.13 / Flutter 3.47 (unchanged). Data tooling: Python 3 (stdlib +
Pillow).

**Primary Dependencies**: none added to the app.

**Storage**:
- new asset `assets/data/rise_sunbreak/armor.json`, estimated 3–4 MB;
- ~1,500 armor icons at 96 px WebP (male render only), ~7 MB;
- `weapons.json` grows a little (Rampage skills and decorations).

**Testing**:
- `flutter_test`: set grouping, skill sums and filters (unit); DTO and mapper; a real-dataset
  test; widget tests (tabs, list, set, skill and decoration details, the Rampage card);
  accessibility and performance (2,000 synthetic pieces);
- the integration test is extended (Armaduras → search a skill → set → skill).

**Target Platform**: Android, tablet, web, Windows (unchanged).

**Project Type**: cross-platform client app.

**Performance Goals**:
- the set list appears in ≤ 1 s (SC-004);
- a search takes < 50 ms over 2,000 pieces.

**Constraints**:
- offline;
- the armor dataset loads lazily and independently (FR-011);
- no new packages.

**Scale/Scope**:
- 1 new feature module (~30 files);
- 1 Python builder plus a shared helper;
- about 2,000 records.

## Constitution Check

| Principle | Gate | Pre | Post |
|-----------|------|-----|------|
| I. Clean Architecture | `armor` with domain / data / presentation; shared material model in `core`; cross-feature links only in `lib/app/` | ✅ | ✅ |
| II. MVC | `ArmorController` (tabs, filters, selection); sums and filters in domain use cases | ✅ | ✅ |
| III. Dependency rule / DI | `ArmorRepository` abstraction; wiring in `AppDependencies` | ✅ | ✅ |
| IV. Offline, versioned data | `armor.json` with `schemaVersion` 1, sources per piece; failures mapped to `Failure` | ✅ | ✅ |
| V. Multi-game | ids carry the game; Rise only, other games later | ✅ | ✅ |
| VI. Tests | unit, widget, real-dataset, a11y, performance (research R9) | ✅ | ✅ |
| VII. i18n, lints | strings in ARB; names in en and pt-BR from the source; code in English | ✅ | ✅ |
| New packages justified | none | ✅ | ✅ |

**Result**: PASS.

## Project Structure

### Documentation (this feature)

```text
specs/007-rise-armor/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── contracts/ui-contract.md
├── mockups/approved.html
└── checklists/requirements.md
```

### Source Code (changes)

```text
tool/data/
├── kiranico_items.py              # NEW: item-page sources, moved from build_rise_weapons.py
├── build_rise_armor.py            # NEW: lists + armor pages + wiki sets → armor.json, icons
├── fetch_rise_armor_pages.py      # NEW: caches Kiranico armor and decoration pages
├── build_rise_weapons.py          # + rampageSkills per weapon, rampage tables; uses kiranico_items
└── README.md
assets/
├── data/rise_sunbreak/armor.json  # NEW
└── images/armor/rise_sunbreak/*.webp   # NEW
lib/
├── core/
│   ├── domain/material_sources.dart          # MOVED from weapons
│   └── presentation/widgets/material_cost_row.dart   # MOVED/generalized from weapons
├── app/
│   ├── app_shell.dart             # Armaduras enabled (AppArea.armor)
│   ├── app_home.dart              # + ArmorPage, monster links for armor materials
│   └── di/app_dependencies.dart   # + ArmorRepository, ArmorController
├── features/armor/                # NEW
│   ├── domain/entities/           # armor_piece, armor_set, body_part, resistances, skill,
│   │                              # skill_level, decoration, armor_catalog, ids
│   ├── domain/usecases/           # load_armor_catalog, filter_sets, sum_set_skills, skill_sources
│   ├── data/                      # dto (+ validation), mapper, asset datasource, repository impl
│   └── presentation/              # controller, armor_page (tabs), set list, set / skill / jewel
│                                  # details, widgets (skill pips, resistance row)
├── features/weapons/
│   ├── domain/entities/rampage.dart          # NEW: rampage skill, rampage decoration
│   └── presentation/views/widgets/weapon_rampage_section.dart   # NEW
└── l10n/app_pt.arb
test/ … mirrors the above
```

**Structure Decision**: the new `armor` feature mirrors `features/weapons`. Rampage data stays
with the weapons, because it describes weapons, so the weapon detail does not depend on the armor
dataset. The material sources model and its UI move to `core`: both features use them, and
neither imports the other.

## Complexity Tracking

No violations.
