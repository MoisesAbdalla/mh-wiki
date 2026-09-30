# Research: Renovação Visual "Caderninho"

Decisions for the 005 plan. Each has the decision, the rationale and the alternatives.

## R1. Fonts

- **Decision**: Bundle three OFL families from the official `google/fonts` repository, and remove
  Cinzel and Alegreya Sans (files, `pubspec.yaml` entries, `HunterFonts`).

  | Role | Family | Files (`assets/fonts/…`) |
  |------|--------|--------------------------|
  | Titles: brand, text tabs, monster names, section titles, stamp | IM Fell English SC | `im_fell_english_sc/IMFeENsc28P.ttf` (one weight) |
  | Numbers: HP, ruler values, rates, section numbers, counts | Averia Serif Libre | `averia_serif_libre/AveriaSerifLibre-{Regular,Bold}.ttf` |
  | Body text | Atkinson Hyperlegible | `atkinson_hyperlegible/AtkinsonHyperlegible-{Regular,Bold,Italic}.ttf` |

  Each folder keeps its `OFL.txt`.
- **Rationale**: these are the families the user approved in the mockups. A `fontTools` cmap check
  confirmed all three have every Portuguese accent (ã õ ç á é í ó ú â ê ô à and capitals), the en
  dash, `·`, `%` and the digits. None has ★/☆, which is fine, because stars stay icons (R6).
- **Consequences**:
  - IM Fell English SC has only one weight. Hierarchy comes from size and colour, never from
    synthetic bold (`FontWeight.w400` everywhere it is used).
  - Its small caps replace the old `toUpperCase()` + letter spacing, so titles are no longer
    forced to upper case.
  - Numbers use `FontFeature.tabularFigures()` where columns align (rates, ruler values).
- **Alternatives**: Big Shoulders Display (rejected by the user: "urban signage", not a
  bestiary), Grenze, Alegreya SC, League Gothic, Averia for everything; see
  [mockups/fonts.html](mockups/fonts.html).

## R2. Colour and contrast

- **Decision**: Keep `HunterPalette` as is. Gold is used only for state and emphasis. Contrast was
  measured (WCAG relative luminance):

  | Foreground | on background `#16120E` | on selected row `#2C2215` | Use |
  |------------|------------------------:|--------------------------:|-----|
  | text `#EFE4C8` | 14.73 | 12.33 | body, names |
  | textMuted `#B9A67F` | 7.83 | 6.55 | secondary text, inactive tabs |
  | gold `#E0BD6A` | 10.34 | 8.66 | active state, best weakness, section numbers |
  | textDisabled `#8A7652` | 4.25 | 3.56 | empty stars (icon, ≥ 3:1) |
  | fire / water / thunder / ice / dragon | 6.73 / 8.25 / 12.18 / 13.17 / 7.76 | 5.63 / 6.91 / 10.19 / 11.02 / 6.49 | element symbols |
  | border `#5A4526` | 2.05 | 1.72 | decorative rules only |
  | borderSubtle `#3B2E1D` | 1.41 | 1.18 | decorative hairlines only |

- **Rationale**:
  - All text is ≥ 4.5:1 and all informative icons are ≥ 3:1 (FR-016).
  - Rules are decorative, because the separation is also given by spacing and headings, so the
    3:1 rule for non-text elements does not apply to them.
  - The state of a tab is carried by the gold underline (10.34:1) and by semantics, not only by
    the logo's opacity.
- **Alternatives**: the vermilion accent of mockup A (the user chose the current palette).

## R3. Structure without cards

- **Decision**: Replace `HunterPanel`, `SectionCard` and `OrnamentHeader` with two layout
  widgets, and delete the old ones.
  - `NotebookSection`: a numbered title in the title font with the number in gold (Averia). It
    has an optional discreet note ("igual à forma base"), an optional trailing widget and a
    hairline under the title. Spacing tokens: 32 between sections, 12 between title and content,
    8 inside.
  - `RuledList` / `RuledRow`: rows separated by 1 px `borderSubtle` rules, with no containers.

  `EmptySectionText` stays. Section numbers are assigned by `MonsterDetailView` in display order.
- **Order** (FR-004): 1 Fraquezas, 2 Vida, 3 Itens de caça, 4 Materiais, 5 Habitat, 6 Partes.
  Habitat and Parts stay side by side from 360 dp of content, as in 002 FR-008.
- **Rationale**: the spec forbids cards and nested cards (SC-002). A single section widget keeps
  numbering and spacing consistent.
- **Alternatives**: keep `HunterPanel` without its border. Rejected: its name and API invite
  cards back.

## R4. Tabs

- **Decision**: One `UnderlineTabs<T>` widget replaces `HunterTabs`.
  - Options are text or an image with a text fallback.
  - The selected tab gets a 2 px gold underline and full colour; the others use `textMuted`
    (text) or 55 % opacity with reduced saturation (images).
  - Minimum 48 dp tap height. Each tab has `Semantics(button, selected, label)`.
  - When the tabs do not fit the width (320 dp or enlarged text), the row scrolls horizontally
    instead of shrinking or wrapping.
  - It is used for game tabs, version tabs, HP rank tabs and material rank tabs.
- **Rationale**: FR-006/FR-008 ask for underlined text tabs. Scrolling keeps the 46 px logos
  legible at 320 dp (spec edge case).
- **Alternatives**: wrap to two rows (the current behaviour). Rejected, because logos in two rows
  look broken.

## R5. Game logos

- **Decision**: Official logos from the Monster Hunter Wiki (`MHWI-Logo.png`, `MHRS-Logo.png`,
  `MHWilds-Logo.png`).
  - Trimmed to their bounding box and exported as WebP with alpha, 138 px tall (3× of 46 dp).
  - Stored in `assets/images/games/{world_iceborne,rise_sunbreak,wilds}.webp`.
  - A Python step `tool/data/fetch_game_logos.py` makes them reproducible.
  - The source is recorded in the README sources section and in `assets/images/games/SOURCES.md`
    (FR-019).
  - If a logo fails to load, `Image.asset` `errorBuilder` shows the game name as text (FR-007).
- **Rationale**:
  - Same source and policy as the monster icons (feature 001, personal/study use).
  - 3× height stays sharp on high-density phones. The three files total ≈ 110 KB.
- **Alternatives**: cropped emblems (rejected in the mockup: Rise and Wilds are
  unrecognisable); flagship monster icons (rejected by the user).

## R6. Weaknesses

- **Decision**:
  - Order the rows in the domain with a new `WeaknessProfile.ranked`: a list of
    (element, effectiveness), from most to least effective, ties in the order fire, water,
    thunder, ice, dragon, immune last.
  - The existing `mostEffective` decides the highlight: stars in gold and a "Melhor" stamp in
    gold (title font, rotated −3°, 1.5 px gold border).
  - The view draws a row with `ElementIcon` in the element colour, the name and three star icons
    (`StarRating` restyled: filled `text`, empty `textDisabled`, gold when highlighted).
    Immunity is text ("Sem efeito"). Per-state weaknesses (e.g. Alatreon) use the same rows.
  - The list badge keeps `primaryWeakness`, now drawn as element symbol + name.
- **Rationale**: Constitution II. Views must not sort, so ordering belongs to the domain, with a
  unit test. It reuses the icons and rules of 002.
- **Alternatives**: sort in the widget (violates II).

## R7. HP ruler

- **Decision**: `HpSection` becomes stateful, like `MaterialsSection`, with the selected rank as
  UI-only state.
  - The rank selector is `UnderlineTabs`, shown only with more than one rank.
  - The chosen rank shows the solo HP big (Averia, "a partir de" kept for `minQuest`), then
    `HpRuler`: a horizontal axis from 0 to the largest estimate. It has a gold mark at solo,
    marks at 2 players and a span for 3–4 players, with labelled values under them (Averia,
    tabular).
  - Estimates come from `RankHp.partyEstimate` (unchanged domain).
  - Without factors, only the solo value is shown. Without HP: "HP desconhecido".
- **Accessibility**: the ruler is `ExcludeSemantics`. A `Semantics` label reads "HP solo X; 2
  caçadores Y; 3 a 4 caçadores Z". At large text scales, value labels move under the ruler as a
  list, so they cannot collide.
- **Rationale**: FR-013. The positions are presentation geometry, not business logic.
- **Alternatives**: list rows (the current layout; the user chose the ruler of mockup B).

## R8. Materials

- **Decision**: Add a domain getter `Monster.dropsByMethod(rank)`. It returns the groups of a
  rank as (method, partId, methodLabel) → drops, in first-appearance order.
  - The view draws each group as a small upper-case caption row ("Entalhe", "Quebrar cabeça",
    "Prêmio da missão: …"), followed by `RuledRow`s: material name (+ rarity) on the left and
    the rate on the right (Averia, tabular), or "Taxa desconhecida".
  - `dropsByRank` stays for the rank list.
- **Rationale**: FR-014 (grouped by method, as in the mockup). Grouping in the domain keeps
  views logic-free (Constitution II) and testable.
- **Alternatives**: keep grouping by material (current). Rejected: it does not match the
  approved mockup.

## R9. Motion

- **Decision**:
  - `AnimatedSwitcher` around the detail content, keyed by monster id, and around the list body,
    keyed by game filter.
  - The detail uses a fade plus a 2 % upward slide. The list fades only, because sliding 300
    rows is wasted work.
  - Duration 220 ms, `Curves.easeOutCubic` (no bounce).
  - When `MediaQuery.disableAnimationsOf(context)` is true, the duration is `Duration.zero`.
- **Rationale**: FR-015. It respects the platform's reduce-motion setting.
- **Alternatives**: page-level hero animations (more code, no user value).

## R10. Title and repeated information

- **Decision**:
  - The app bar title is "Caderninho" (ARB `appTitle`). `appSubtitle` is removed.
  - The detail header no longer shows the game name above the monster name. A back-row caption
    (compact layout) keeps the game for context only when the game filter is "Todos".
  - In "Todos", each game block in the list starts with a caption row: the game name in the
    title font and a hairline, replacing `OrnamentHeader`.
- **Rationale**: FR-001, FR-009. The spec edge case asks the "Todos" header to identify the game
  without ornaments. A text header is lighter than a second logo row.
- **Alternatives**: a small logo per game header (redundant with the tabs just above).

## R11. Tests to update

- Replace the grid-specific finders (`WeaknessCell`, `HunterTabs`) in `weakness_section_test`,
  `game_filter_test` and `version_selector_test` with semantics-based finders.
- New tests:
  - unit tests for `WeaknessProfile.ranked` and `Monster.dropsByMethod`;
  - widget tests for `UnderlineTabs` (logo fallback, semantics, scrolling), `HpRuler` semantics,
    weakness order and the "Melhor" stamp, no card widgets (no `Card`, no bordered `Material`
    in detail and list), and reduce motion (zero duration);
  - accessibility tests at 320 dp / 200 % for list, detail and version detail.
- The list performance test (004) must keep passing.
