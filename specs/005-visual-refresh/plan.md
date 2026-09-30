# Implementation Plan: Renovação Visual "Caderninho"

**Branch**: `005-visual-refresh` | **Date**: 2026-09-30 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/005-visual-refresh/spec.md`

## Summary

This feature restyles the whole app to the mockup the user approved
([mockups/approved.html](mockups/approved.html)). It changes presentation only; data and
behaviour stay as they are. The main changes:

- **Title and tabs**: the app is called "Caderninho". The game tabs use the official game logos
  (from the Monster Hunter Wiki, as WebP assets) and underline the active tab in gold.
- **No cards**: `HunterPanel`, `SectionCard` and `OrnamentHeader` give way to numbered notebook
  sections and ruled rows.
- **Fonts**: three bundled OFL families replace Cinzel and Alegreya Sans. IM Fell English SC is
  for titles, Averia Serif Libre for numbers and Atkinson Hyperlegible for body text.
- **Weaknesses**: each row shows the element symbol and stars, ordered by a new domain getter,
  with a gold "Melhor" stamp on the best one.
- **HP**: the solo value comes with a ruler showing the party estimates.
- **Materials**: grouped by method, through a new domain getter.
- **Motion**: one 220 ms fade/slide transition, turned off when the platform asks for reduced
  motion.

The palette values stay the same, and every colour pair was measured for contrast (R2).

## Technical Context

**Language/Version**: Dart 3.13 / Flutter 3.47 (unchanged). Asset tooling: Python 3 with Pillow
(already used by `fetch_icons.py`).

**Primary Dependencies**: none added. Fonts and logos are bundled assets.

**Storage**: new assets are 3 font families (6 TTF files and OFL licences) and 3 game-logo WebP
files (≈ 110 KB). Cinzel and Alegreya Sans are removed. Datasets and schema are unchanged.

**Testing**: `flutter_test`:
- unit: `WeaknessProfile.ranked`, `Monster.dropsByMethod`;
- widget: `UnderlineTabs` (semantics, logo fallback, scrolling), weakness rows and stamp, HP
  ruler and its semantics, no card/panel widgets, reduce-motion;
- accessibility: guidelines at 320 dp / 200 %;
- regression: the existing 232 tests, with visual finders updated.

**Target Platform**: Android, tablet, web, Windows (unchanged).

**Project Type**: cross-platform client app (Flutter).

**Performance Goals**: the list with 300+ entries opens in ≤ 1 s and scrolls at 60 fps. There is
no cross-fade of whole lists (R9).

**Constraints**: offline (bundled assets); text contrast ≥ 4.5:1 and icon contrast ≥ 3:1; 320 dp
at 200 % text with no overflow; 48 dp tap targets; no new packages; pt-BR strings from ARB.

**Scale/Scope**:
- ~15 widgets restyled;
- 4 new shared widgets (`NotebookSection`, `RuledRow`, `UnderlineTabs`, `HpRuler`);
- 3 widgets deleted;
- 2 domain getters;
- ~8 test files updated and ~6 added.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Pre | Post |
|-----------|------|-----|------|
| I. Clean Architecture | Styling stays in `presentation`; the new getters (`ranked`, `dropsByMethod`) are pure Dart in `domain` | ✅ | ✅ |
| II. MVC | Views only render. Sorting and grouping live in the domain (R6, R8). Rank/version selection stays UI-only ephemeral state, as in `MaterialsSection` today | ✅ | ✅ |
| III. Dependency rule / DI | No new cross-layer dependencies; no new services | ✅ | ✅ |
| IV. Offline, versioned data | Assets bundled; schema v1 unchanged; logo source recorded (FR-019) | ✅ | ✅ |
| V. Multi-game | Logos keyed by `Game`; per-game data untouched | ✅ | ✅ |
| VI. Tests | Unit tests for the new getters; widget and a11y tests for new visuals; regressions kept green | ✅ | ✅ |
| VII. i18n, lints, English code | New strings in ARB ("Caderninho", "Melhor", semantics labels); code and commits in English; lints clean | ✅ | ✅ |
| New packages justified | None added | ✅ | ✅ |

**Result**: PASS. No complexity to track.

## Project Structure

### Documentation (this feature)

```text
specs/005-visual-refresh/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── contracts/ui-contract.md
├── mockups/approved.html (+ logos, directions.html, fonts.html)
└── checklists/requirements.md
```

### Source Code (changes)

```text
assets/
├── fonts/im_fell_english_sc/ (+ OFL.txt)          # NEW
├── fonts/averia_serif_libre/ (+ OFL.txt)          # NEW
├── fonts/atkinson_hyperlegible/ (+ OFL.txt)       # NEW
├── fonts/cinzel/, fonts/alegreya_sans/            # REMOVED
└── images/games/{world_iceborne,rise_sunbreak,wilds}.webp, SOURCES.md   # NEW
tool/data/fetch_game_logos.py                       # NEW: download, trim, WebP 138 px
pubspec.yaml                                        # font families, games asset folder
lib/
├── l10n/app_pt.arb (+ generated)                   # appTitle, bestWeakness, semantics labels
├── core/presentation/theme/
│   ├── hunter_theme.dart                           # new fonts, text theme, tab/app bar styles
│   └── notebook_tokens.dart                        # NEW: spacing + motion tokens, type helpers
├── core/presentation/widgets/
│   ├── notebook_section.dart                       # NEW (replaces hunter_panel/section_card)
│   ├── ruled_row.dart                              # NEW
│   ├── underline_tabs.dart                         # NEW (replaces HunterTabs in game_tabs.dart)
│   ├── game_tabs.dart                              # logos + fallback
│   ├── star_rating.dart, element_icon.dart, monster_image.dart   # restyled
│   ├── hunter_panel.dart, ornament_header.dart     # REMOVED
├── features/monsters/domain/entities/
│   ├── weakness_profile.dart                       # + ranked
│   ├── ranked_weakness.dart                        # NEW
│   ├── monster.dart                                # + dropsByMethod
│   └── method_drop_group.dart                      # NEW
├── features/monsters/presentation/views/
│   ├── monsters_page.dart, monster_detail_page.dart    # title, back row, AnimatedSwitcher
│   └── widgets/
│       ├── monster_list_pane.dart                  # ruled rows, "Todos" captions, badges
│       ├── monster_detail_view.dart                # header, numbering, order, motion
│       ├── weakness_section.dart                   # rows + stamp
│       ├── hp_section.dart, hp_ruler.dart (NEW)    # rank tabs + ruler
│       ├── hunting_items_section.dart, habitat_section.dart, parts_section.dart
│       ├── materials_section.dart                  # groups by method
│       ├── version_selector.dart                   # UnderlineTabs
│       └── section_card.dart                       # REMOVED (EmptySectionText moves to notebook_section.dart)
└── features/settings/presentation/settings_page.dart   # no panels
test/ (see research R11)
```

**Structure Decision**: the existing Flutter single-project layout (Clean Architecture +
MVC). Shared visual building blocks go in `lib/core/presentation/`, and feature widgets stay in
the monsters and settings features.

## Complexity Tracking

No violations.
