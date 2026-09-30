# Implementation Plan: Identidade Visual "Caderno do Caçador"

**Branch**: `002-visual-identity` | **Date**: 2026-09-29 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/002-visual-identity/spec.md`

## Summary

Apply prototype A to the whole app: a fixed dark theme (palette, Cinzel + Alegreya Sans bundled,
framed panels, ornamental headers, game tabs), a painted icon and color per element, a 5-column
weakness grid, the primary weakness in list items, and the official hunter's-notes thumbnail for
each of the 30 monsters (downloaded from the Monster Hunter Wiki, converted to 256 px WebP and
referenced by the dataset's existing `image` field). Presentation-only change plus one domain
getter; all 001 behaviour stays.

## Technical Context

**Language/Version**: Dart 3.13 / Flutter stable 3.47.x (unchanged)

**Primary Dependencies**: none added. Fonts are bundled assets (R3); icons painted (R5).

**Storage**: new assets: 30 WebP thumbnails, 2 font families (+ OFL licenses); datasets gain
`image` values (schema unchanged).

**Testing**: `flutter_test` unit (primaryWeakness), widget (theme applied regardless of platform
brightness, tabs, list badge, weakness grid, habitat/parts layout, thumbnails and fallback),
accessibility guidelines (contrast, tap targets, 200% text), dataset test checks image assets.

**Target Platform**: Android, web, Windows (unchanged)

**Project Type**: cross-platform client app

**Performance Goals**: list scrolling stays smooth with 30 thumbnails (`cacheWidth` decoding).

**Constraints**: offline (bundled fonts/images); contrast ≥ 4.5:1; no new packages.

**Scale/Scope**: ~10 widgets restyled, 4 new shared widgets, 30 images.

## Constitution Check

| Principle | Gate | Pre | Post |
|-----------|------|-----|------|
| I. Clean Architecture | UI changes in `presentation`; `primaryWeakness` in domain (pure Dart) | ✅ | ✅ |
| II. MVC | views only render; no logic added to widgets beyond layout choice | ✅ | ✅ `primaryWeakness` computed in domain |
| III. Dependency rule / DI | no new dependencies between layers | ✅ | ✅ |
| IV. Offline, versioned data | assets bundled; schema v1 unchanged; icon source recorded | ✅ | ✅ |
| V. Multi-game | one thumbnail per (game, monster) | ✅ | ✅ |
| VI. Tests | unit + widget + a11y tests for new behaviour | ✅ | ✅ |
| VII. i18n, lints | new strings in ARB; code in English | ✅ | ✅ |
| New packages justified | none added | ✅ | ✅ |

**Result**: PASS.

## Project Structure

### Documentation (this feature)

```text
specs/002-visual-identity/
├── plan.md, research.md, data-model.md, quickstart.md
├── contracts/ui-theme-contract.md
└── checklists/requirements.md
```

### Source Code (changes)

```text
assets/
├── fonts/cinzel/Cinzel[wght].ttf, OFL.txt
├── fonts/alegreya_sans/AlegreyaSans-{Regular,Medium,Bold}.ttf, OFL.txt
├── images/monsters/{world_iceborne,rise_sunbreak,wilds}/<slug>.webp   # 30 files
└── data/*/monsters.json                                               # + image, + source
lib/
├── app/app.dart                                  # fixed dark theme
├── core/presentation/theme/                      # NEW: hunter_palette.dart, hunter_theme.dart
├── core/presentation/widgets/                    # NEW: hunter_panel.dart, ornament_header.dart,
│                                                 #      element_icon.dart, game_tabs.dart;
│                                                 #      monster_image.dart, star_rating.dart restyled
├── features/monsters/domain/entities/weakness_profile.dart   # + primaryWeakness
└── features/monsters/presentation/views/…        # list pane, detail, sections restyled
test/ …                                           # new + updated widget tests
```

**Structure Decision**: same single Flutter app; the theme lives in `core/presentation/theme`, the
reusable themed widgets in `core/presentation/widgets`.

## Complexity Tracking

No violations.
