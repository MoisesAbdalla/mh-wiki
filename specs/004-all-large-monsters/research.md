# Research: Todos os Monstros Grandes

Decisions for feature 004. Rules from features 001–003 (sources, star rule, drop rules, HP basis,
party factors, item reactions) are reused unchanged unless stated.

## R1. Roster per game (what is a large monster)

- **Source of the roster**: the Kiranico monster list of each game, large-monster section only.
  Counts seen on 2026-09-30:
  - Wilds (game version 1.040): 34 large (Rathian … Omega Planetes).
  - Rise: Sunbreak: 78.
  - World: Iceborne: 71 (incl. collab Behemoth, Leshen, Ancient Leshen).
- **Excluded**: small monsters and endemic life; non-monster targets (Wilds "High Purrformance
  Barrel Puncher", an arena object).
- **Decision**: the per-game roster is a checked-in list (slug + source ids) in the data
  pipeline (R8); SC-001 is verified against it. Collab monsters stay, since the game and the
  source list them as large monsters.
- **Alternatives**: the Monster Hunter Wiki category pages (less stable naming, mixed games).

## R2. Base monsters, versions and version kinds (spec Q1, Q4)

- **Own row (base monster)**: base species, subspecies, rare species and the games' "Variant"
  class with its own Hunter's Notes entry (e.g. Ruiner Nergigante, Savage Deviljho, Raging
  Brachydios, Scorned Magnamalo, Primordial Malzeno, Chaotic Gore Magala). They have their own
  icon, moveset and field-guide page, like subspecies (spec Q4: "outros monstros no caderno").
- **Version (collapsed in the base row)**, `versionKind`:
  | Kind | Games | Example |
  |------|-------|---------|
  | `tempered` | World, Wilds | Rey Dau Temperado |
  | `archTempered` | World, Wilds | Arch-Tempered Rey Dau |
  | `afflicted` | Rise (Anomaly quests / afflicted monsters; "Anomalia" and "Aflito" are the same thing in Rise) | Aflito Rathalos |
  | `frenzied` | only if a game's sources list frenzied individuals with own data | — |
  | `apex` | Rise | Apex Rathalos |
  | `risen` | Rise | Risen Teostra |
  | `guardian` | Wilds | Guardian Rathalos |
- A named variant whose base species is not in the game becomes its own base row (Wilds:
  Guardian Fulgur Anjanath, Guardian Ebony Odogaron; spec edge case).
- **Creation rule** (spec Assumptions): a version entry exists only when the sources give it
  some own data (HP, drops or quests). Tempered/arch-tempered/afflicted are therefore
  confirmed per monster during each game's data build, not assumed for every monster.
- **Existing entries**: Wilds `guardian-rathalos` (one of the 30) becomes a `guardian` version of
  `rathalos`; its data is kept (FR-007).

## R3. Version data and inheritance (spec Q5)

- **Own data** (never inherited): `hp`, `drops`, `sources` (+ name, image when it has its own).
- **Inherited when absent**: `weaknesses`, `parts`, `habitatIds`, `itemReactions` (and
  `classification`). The dataset simply omits them for the version; the mapper copies them from
  the base and records which sections were inherited, so the UI can show "Igual à forma base".
- **Why in the data layer**: inheritance is a dataset convention (Principle IV: DTO→entity in
  `data`); the domain receives complete `Monster`s plus an `inheritedSections` set and stays
  unaware of JSON.
- **Parts**: drops of a version may reference inherited part ids; validation uses the effective
  (inherited) part list.
- **Alternatives**: duplicating base data in every version entry (bloats the files, hides that
  the value is inherited — rejected by Q5 "com a indicação").

## R4. Per-game sources for versions (to confirm at each game's start)

- **Wilds** (first):
  - Tempered: Kiranico monster pages list a "Tempered Wound Destroyed Reward" drop group
    (Wyverian Bloodstone) → tempered version with those drops.
  - Tempered HP: free hunts only, no quest HP → "HP desconhecido".
  - Arch-Tempered: Monster Hunter Wiki pages have an "Arch-Tempered" section (Rey Dau, …). HP and
    rewards come from event quests; the Kiranico `/data/quests` list shows only Assignments and
    Optional quests, so any missing values are unknown.
  - Guardians: already separate Kiranico pages.
- **Rise**:
  - Apex, Risen, Primordial Malzeno: separate Kiranico pages.
  - Afflicted: Kiranico "Anomaly" quest rows (e.g. Rathalos 88,200 HP at Anomaly 6★) and
    afflicted materials; confirmed per monster.
- **World**: Tempered and Arch-Tempered. Kiranico quest tables mark tempered and arch-tempered
  quests by name and star (e.g. Nergigante ★9 26,224 HP), and the rewards list tempered
  streamstones. To be confirmed at the start of the World phase.
- **Decision**: each game phase starts with a short source check (a task) that fixes the
  version inventory before any data is written.

## R5. List, search and selection (spec Q3)

- The list shows one row per base monster, sorted alphabetically, with a "N versões" hint.
- Search matches base or version names (en and pt-BR, accent-insensitive). A row whose match
  came only from a version remembers that version, and tapping it opens the detail on it.
- **Domain**: `FilterMonsters` returns `MonsterEntry(base, versions, matchedVersion?)` per row
  instead of bare monsters. Selection stays a `MonsterId` (base or version), so the adaptive
  layout (FR-020 of 001) is unchanged.
- **Detail**: a version selector (the existing themed tab style) under the header: "Base",
  "Temperado", "Arquitemperado", … Switching changes every section; inherited sections show a
  small "Igual à forma base" note.

## R6. Performance (SC-004, SC-005)

- Expected size: about 16 KB of JSON per entry and about 40 KB per icon. For the full roster,
  that is about 4 MB of JSON (compressed in the APK) and 6–8 MB of icons.
- Parsing: move `jsonDecode` + DTO validation to a background isolate (`compute` from Flutter
  foundation, data layer only), so switching games never blocks frames.
- List: already a lazy `SliverList.builder`; thumbnails already decode at display size
  (`cacheWidth`).
- Search: precompute normalized en/pt names per entry once per load (today they are
  normalized on every keystroke). With about 250 entries this keeps filtering well under 300 ms.
- Verified by a performance test with a synthetic catalog of 300 entries (extends the existing
  bulk fixture `copyForTest`).

## R7. Thumbnails

- Same source and conversion as feature 002 (Monster Hunter Wiki hunter's-notes icons, 256 px
  WebP).
- Versions with an own icon (Apex, Risen, Guardian) use it; tempered, arch-tempered and
  afflicted versions reuse the base icon (the games show the same icon).
- Missing icon → existing placeholder (SC-006 ≥ 95 %).

## R8. Data pipeline in the repository

- Until now, the extraction scripts lived in a session scratchpad: `build_*.py`,
  `hp_extract.py`, `items_extract.py` and `fetch_icons.py`. With about 180 base monsters and
  three game phases, they must be reproducible.
- **Decision**: move them to `tool/data/` (Python 3, stdlib + Pillow, not part of the Flutter
  build). There is one entry point per game (`python tool/data/build.py wilds`) that runs roster →
  base data → versions → HP → items → icons. Downloaded pages are cached in a git-ignored
  `tool/data/.cache/`. Rules and sources stay in the docs of 001–004.
- **Rationale**: auditable and re-runnable (constitution: "registrar origem para permitir
  auditoria e atualização"); no app dependency is added.
- **Alternatives**: Dart scripts (would need HTML parsing packages; the existing, proven
  Python code would be rewritten for no gain).

## R9. Delivery order (spec Q2)

- Order is Wilds → Rise: Sunbreak → World: Iceborne. Each game runs roster → data → tests →
  merge.
- The app changes (versions, list grouping, selector, inheritance, performance) ship with the
  Wilds phase, because Wilds already has a version (Guardian Rathalos).
