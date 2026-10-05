# Implementation Plan: Armas e Armaduras do World: Iceborne

**Branch**: `011-world-equipment` | **Date**: 2026-10-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/011-world-equipment/spec.md`

## Summary

Enable the World tab in Armas and Armaduras, reusing everything 010 built: game tabs, per-game
controllers, the Wilds additions (set bonus card, Joias filter, Talismãs tab) and the read-only
group pattern used for Gogma.

- **Data** (Python, `tool/data/`):
  - `fetch_world_equipment.py` caches:
    - the wiki modules (Weapons, Armor, Decorations);
    - mhw-db.com (armor sets, skills, decorations, charms);
    - the Kiranico en/pt-BR lists.
  - `fetch_world_icons.py` gets the MHWI rarity icons, decoration and slot icons, and the renders.
  - `build_world_equipment.py` writes `assets/data/world_iceborne/weapons.json` and `armor.json` in
    the 006/007/010 schemas, with the optional World additions (research R1–R7).
- **App**:
  - `Weapon` gains `hidden` on each element, `elderseal`, `defenseBonus` and `special`. The augment
    slot count is derived from rarity.
  - The weapon detail shows these fields. Especiais form a group like Gogma.
  - `SkillKind` gains `secret`.
  - The World game in `GameIcons`.
  - "Armas feitas com ele" for World monsters.
  - Nothing new for armor beyond the data: the 010 bonus card, Joias filter and Talismãs tab work
    as they are.

## Technical Context

**Language/Version**: Dart 3.13 / Flutter 3.47 (unchanged); Python 3 for the data tools.

**Primary Dependencies**: none added.

**Storage**:
- new assets: `assets/data/world_iceborne/weapons.json` and `armor.json`, about 6–7 MB;
- `assets/images/world/` icons and renders, ≤ 15 MB (research R8).

**Testing**: DTO, real-dataset, widget, accessibility and integration tests (research R9).

**Target Platform**: Android, tablet, web, Windows (unchanged).

**Project Type**: cross-platform client app.

**Performance Goals**: the World weapon list opens in ≤ 1 s after its first load (SC-004).

**Constraints**:
- offline;
- Rise and Wilds unchanged;
- World failures stay in the World tabs;
- the APK grows by ≤ 20 MB.

**Scale/Scope**:
- 3 Python scripts and 2 datasets;
- small domain and DTO additions in `weapons` and `armor`;
- `GameIcons`, and app wiring for a third game.

## Constitution Check

| Principle | Gate | Pre | Post |
|-----------|------|-----|------|
| I. Clean Architecture | New fields in each feature's `domain` (pure Dart); DTO changes in `data`; tab wiring in `lib/app/` | ✅ | ✅ |
| II. MVC | Same per-game controllers; views only render the new fields | ✅ | ✅ |
| III. Dependency rule / DI | World controllers created in `AppDependencies` like Wilds | ✅ | ✅ |
| IV. Offline, versioned data | Same schema version with optional fields; every source recorded in `sources` | ✅ | ✅ |
| V. Multi-game | The existing `Game.worldIceborne` key and per-game data | ✅ | ✅ |
| VI. Tests | research R9 | ✅ | ✅ |
| VII. i18n, lints | pt-BR names from Kiranico; strings in ARB | ✅ | ✅ |
| New packages justified | none | ✅ | ✅ |

**Result**: PASS.

## Project Structure

### Documentation (this feature)

```text
specs/011-world-equipment/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── contracts/ui-contract.md
├── mockups/world.html (+ img/)
└── checklists/requirements.md
```

### Source Code (changes)

```text
tool/data/
├── fetch_world_equipment.py      # NEW
├── fetch_world_icons.py          # NEW
└── build_world_equipment.py      # NEW
assets/data/world_iceborne/weapons.json, armor.json   # NEW
assets/images/world/{icons,decorations,slots,weapons,armor}/   # NEW
lib/
├── app/app_home.dart, main.dart, app.dart, di/   # World controllers and pages
├── core/presentation/game_icons.dart             # World icons
├── features/weapons/
│   ├── domain/   # WeaponSpecial.hidden, Weapon.elderseal/defenseBonus/special, augmentSlots
│   ├── data/     # DTO: the new optional fields
│   └── presentation/   # detail rows, Especiais group, hidden note
└── features/armor/
    ├── domain/   # SkillKind.secret
    └── data/     # nothing else (010 schema)
test/ … mirrors the above
```

**Structure Decision**: the same as 010. Extend the features with optional, game-neutral fields,
and wire the third game in `lib/app/`.

## Complexity Tracking

No violations.
