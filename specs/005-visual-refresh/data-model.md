# Data Model: Renovação Visual "Caderninho"

No dataset or schema change: `schemaVersion` 1 and all `assets/data/*/monsters.json` stay as they
are. The feature adds two pure domain getters, design tokens and three image assets.

## Domain additions (pure Dart, `lib/features/monsters/domain/entities/`)

### `WeaknessProfile.ranked` → `List<RankedWeakness>`

The general weaknesses in display order (R6).

| Field | Type | Notes |
|-------|------|-------|
| `element` | `ElementType` | |
| `effectiveness` | `Effectiveness` | |
| `best` | `bool` | `true` when the element is in `mostEffective` (≥ 2 stars, ties included) |

Rules:

- Sorted by effectiveness, from `high` to `none`.
- `immune` goes last.
- Ties follow the order of `ElementType.values` (fire, water, thunder, ice, dragon).
- Always 5 entries. A missing element counts as `none`, as today.
- The same ordering applies to each `WeaknessState` (a `ranked` getter on the state's value map,
  or a shared helper). `best` is never set inside states, because states have no highlight today.

### `Monster.dropsByMethod(Rank rank)` → `List<MethodDropGroup>`

The materials of one rank grouped by how they are obtained (R8).

| Field | Type | Notes |
|-------|------|-------|
| `method` | `DropMethod` | |
| `partId` | `String?` | set for `breakPart` |
| `methodLabel` | `LocalizedText?` | set for `other` (e.g. tempered/quest reward labels) |
| `drops` | `List<MaterialDrop>` | in dataset order |

Rules:

- The group key is `(method, partId, methodLabel.en)`.
- Groups keep the order in which the drops first appear in the rank.
- An empty list is returned when the rank has no drops.
- `dropsByRank` stays unchanged. It still decides which rank tabs exist.

## Design tokens (`lib/core/presentation/theme/`)

### Colours: `HunterPalette` (unchanged values, new roles)

| Token | Value | Role in 005 |
|-------|-------|-------------|
| `background` | `#16120E` | every surface (no panel colour behind sections) |
| `panelHighlight` | `#2C2215` | selected list row |
| `borderSubtle` | `#3B2E1D` | hairline rules between rows and sections |
| `border` | `#5A4526` | stronger rule under the tab bars, ruler axis |
| `gold` | `#E0BD6A` | the single accent: active tab underline, selected row mark, best weakness stars and stamp, solo HP mark, section numbers |
| `text` | `#EFE4C8` | primary text, filled stars |
| `textMuted` | `#B9A67F` | secondary text, inactive text tabs |
| `textDisabled` | `#8A7652` | empty stars |
| element colours | unchanged | element symbols |

`panel`, `panelRaised` and `goldFrame` are no longer used by list/detail/settings and are
removed if nothing else references them.

### Typography: `HunterFonts` / helpers

| Helper | Family | Default use |
|--------|--------|-------------|
| `notebookTitle({size, color})` | IM Fell English SC, w400 | brand 24, monster name 40 (compact 32), section title 20, list name 18, text tabs 16, stamp 11 |
| `notebookNumber({size, color, bold})` | Averia Serif Libre, tabular figures | solo HP 40, ruler values 13, rates 14, section numbers 18, counts 12 |
| theme `textTheme` | Atkinson Hyperlegible | body text (bodyLarge 16, bodyMedium 14, bodySmall 12.5) |

`hunterDisplay` (Cinzel) is removed.

### Spacing and motion

| Token | Value |
|-------|-------|
| `Space.section` | 32 (between numbered sections) |
| `Space.title` | 12 (section title → content) |
| `Space.row` | 8 vertical padding of a ruled row |
| `Space.gutter` | 22 horizontal page padding (16 below 360 dp) |
| `Motion.switchDuration` | 220 ms (zero when animations are disabled) |
| `Motion.curve` | `Curves.easeOutCubic` |

## Assets

| Path | Content | Source |
|------|---------|--------|
| `assets/fonts/im_fell_english_sc/` | `IMFeENsc28P.ttf`, `OFL.txt` | google/fonts |
| `assets/fonts/averia_serif_libre/` | Regular, Bold, `OFL.txt` | google/fonts |
| `assets/fonts/atkinson_hyperlegible/` | Regular, Bold, Italic, `OFL.txt` | google/fonts |
| `assets/images/games/{world_iceborne,rise_sunbreak,wilds}.webp` | official game logos, 138 px tall, alpha | Monster Hunter Wiki (`MHWI-Logo.png`, `MHRS-Logo.png`, `MHWilds-Logo.png`) |
| `assets/images/games/SOURCES.md` | origin and licence note of the logos | — |

Removed: `assets/fonts/cinzel/`, `assets/fonts/alegreya_sans/`.

## Localisation (ARB, pt-BR)

| Key | Value | Change |
|-----|-------|--------|
| `appTitle` | "Caderninho" | changed |
| `appSubtitle` | — | removed |
| `bestWeakness` | "Melhor" | new (stamp) |
| `gameLogoLabel` | "{game}" | new (semantics of a logo tab; uses the game's full name) |
| `hpRulerSemantics` | "HP solo {solo}; 2 caçadores {two}; 3 a 4 caçadores {more}" | new |
| `immuneShort` | "Sem efeito" | new, or reuse the existing immunity label |
