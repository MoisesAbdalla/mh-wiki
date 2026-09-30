# Research: Identidade Visual "Caderno do Caçador" (002-visual-identity)

**Date**: 2026-09-29 | **Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

## R1. Source of the monster thumbnails

- **Decision**: download the official hunter's-notes icons from the Monster Hunter Wiki
  (`https://monsterhunterwiki.org/wiki/Special:FilePath/<file>`), one naming pattern per game:
  `MHWI-<Name>_Icon.png` (World: Iceborne), `MHRS-<Name>_Icon.png` (Rise: Sunbreak),
  `MHWilds-<Name>_Icon.webp` (Wilds), where `<Name>` is the English name with `_` for spaces.
  Checked with Rathalos in all three games: each returns that game's icon (456 px PNG, 256 px PNG
  and 512 px WebP, with transparency).
- **Rationale**: one source and naming rule for all 30 monsters; the same wiki is already a data
  source (feature 001). Kiranico has icons for Rise and Wilds but its World list has none.
- **Alternatives considered**: Kiranico (incomplete for World), Fextralife (inconsistent file
  names), drawing our own (not what the user asked for).
- **Licensing**: Capcom artwork, used locally in a personal study project (feature 001, clarification
  Q1). Each dataset records the icon source; the image stays optional per monster.

## R2. Thumbnail format and size

- **Decision**: convert every icon to **WebP, 256×256, transparent background**, stored at
  `assets/images/monsters/<game>/<slug>.webp` and referenced by the dataset's existing optional
  `image` field (schema v1 already has it; no schema change).
- **Rationale**: 256 px covers the largest use (≈104 dp detail frame at 2.5× density); WebP with
  alpha keeps 30 icons small. Flutter decodes WebP on Android, Windows and web.
- **Alternatives considered**: original sizes (up to 290 KB each), PNG (larger).

## R3. Typography

- **Decision**: bundle **Cinzel** (titles, section headings, tabs) and **Alegreya Sans** (body)
  from the Google Fonts repository (SIL Open Font License) as assets under `assets/fonts/`, with
  their `OFL.txt`. Cinzel ships as a variable font; weights are set with the `wght` axis.
- **Rationale**: same faces as the approved prototype; bundled fonts work offline (constitution
  Principle IV); no new package.
- **Alternatives considered**: `google_fonts` package (downloads fonts at runtime by default, one
  more dependency).

## R4. Theme structure

- **Decision**: one fixed dark theme built in `lib/core/presentation/theme/`:
  - `hunter_palette.dart`: color tokens (background, panels, gold, text, borders) and the five
    element colors.
  - `hunter_theme.dart`: `ThemeData` (dark `ColorScheme`, text theme, component themes).
  - Reusable widgets: `HunterPanel` (framed panel), `OrnamentHeader` (separator with centered
    title), `ElementIcon` (painted icon per element), `GameTabs`.
  `MaterialApp` gets only this theme, with `themeMode: ThemeMode.dark` (FR-001).
- **Rationale**: widgets keep reading colors from `Theme`/tokens, so feature widgets stay
  simple; one place defines the identity (easy to change later).
- **Alternatives considered**: `ThemeExtension` only (more ceremony for a single fixed theme).

## R5. Element icons

- **Decision**: draw the five element icons with a `CustomPainter` using the same simple stroke
  paths as the prototype (flame, drop, bolt, snowflake, four-point star for dragon).
- **Rationale**: Material Icons has no dragon icon; painting all five keeps them consistent; no
  SVG package needed (constitution: new packages must be justified).
- **Alternatives considered**: `flutter_svg` (new dependency for 5 icons), Material Icons mix
  (inconsistent set).

## R6. Primary weakness in the list (FR-005)

- **Decision**: add `WeaknessProfile.primaryWeakness` in the domain: the first element, in the
  order Fire, Water, Thunder, Ice, Dragon, of `mostEffective`; `null` when `mostEffective` is
  empty (below 2 stars).
- **Rationale**: domain rule, unit-testable, reuses FR-008's highlight rule from feature 001.

## R7. Game filter as tabs (FR-009)

- **Decision**: replace the chip `Wrap` with four equal-width tab buttons in a row ("Todos",
  "World", "Rise", "Wilds"), each ≥48 dp tall, wrapping to two rows when the text scale needs it.
  Each tab exposes `selected` semantics.
- **Rationale**: matches the prototype; equal widths fit four short labels at 320 dp.

## R8. Contrast

- **Decision**: palette chosen so every text/background pair meets 4.5:1 (WCAG ratios computed):
  gold `#E0BD6A` on `#16120E` 10.3:1; text `#EFE4C8` on `#1F1812` 13.9:1; muted `#B9A67F` on
  `#1F1812` 7.4:1; dark text `#1C150D` on gold 10.0:1. Element colors on `#1F1812`: fire 6.3,
  water 7.8, thunder 11.5, ice 12.4, dragon 7.3. `textContrastGuideline` in widget tests guards it.
