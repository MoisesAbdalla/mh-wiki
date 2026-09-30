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

### R4 result — Wilds (T013, 2026-09-30)

- **Roster**: 34 large monsters on the Kiranico list (game version 1.040). Written to
  `tool/data/rosters/wilds.json` by `tool/data/roster_wilds.py`. The result is 31 base rows and
  38 versions (arch-tempered added on 2026-09-30, see below).
- **Guardians**:
  - Guardian Rathalos, Guardian Doshaguma and Guardian Arkveld are `guardian` versions. They
    have their own pages, and all their sections are their own.
  - Guardian Fulgur Anjanath and Guardian Ebony Odogaron keep their own rows, because the base
    species is not in Wilds.
- **Tempered**:
  - 30 bases list tempered drop groups on their wiki page: "Extra Rewards (Tempered)" and
    "Tempered Wound Destruction Rewards", High Rank only. Each becomes a `tempered` version with
    those drops. The labels are "Extra Reward (Tempered)" and "Tempered Wound Destroyed Reward"
    (Kiranico pt-BR: "Prêmio de Ferimento Ag. Destr.").
  - All other sections are inherited.
  - No official pt-BR name exists for the tempered monster, so the name is English only (e.g.
    "Tempered Rey Dau").
  - Tempered HP: no quest lists it, so the HP section shows unknown.
  - Guardian Rathalos and Guardian Doshaguma also list tempered drops. They are versions
    themselves, and versions of versions are not modelled, so those drops are left out.
- **Arch-tempered** (revised 2026-09-30, after the manual check): 5 `archTempered` versions,
  Rey Dau, Uth Duna, Nu Udra, Jin Dahaad and Arkveld. They match the wiki category "MHWilds
  Arch-Tempered Monster Icons".
  - First pass: none. Only the monster pages and Kiranico were checked, and they have no
    arch-tempered data. That missed the quest pages.
  - Own data: the Monster Hunter Wiki quest pages whose target template has
    `Type=Arch Tempered` (14 event, challenge and ★10 quests; `roster_wilds.py` scans the
    "MHWilds Quests" category through the wiki API). Each version lists its quests in the roster.
  - Drops: the quest rewards that are the monster's own materials, meaning items named after it
    or among the base's drops. Spheres, charms and emblems are left out. They are High Rank
    `questReward` rows without a rate, because quest pages give none.
  - HP: Kiranico's quest list does not include these quests. The user approved the
    [macarongamemo HP table](https://macarongamemo.com/entry/mhwilds-monster-hp) (歴戦王 rows,
    middle of 5 size variations) as the source. Its normal High Rank values match Kiranico for
    12 of 13 monsters checked; Lala Barina differs (10,080 vs 9,000 in our data). Each version
    shows its lowest quest HP (basis `minQuest`, the 003 rule); the ★10 value is in the source
    note. Rey Dau ★8 35,550 / ★10 54,675; Uth Duna ★8 49,500 / ★10 77,517; Nu Udra ★9 47,250 /
    ★10 66,977; Jin Dahaad ★9 65,120 / ★10 73,593; Arkveld ★10 79,923.
  - Tempered HP (added on 2026-09-30 at the user's request): from the same table's 歴戦 rows
    (per hunt star ★5–9 and strength level ♦3–♦5). Each tempered version shows its lowest value
    (basis `minQuest`, e.g. Tempered Rey Dau 20,500 at ★7 ♦3), and every value is listed in its
    source note. Lagiacrus, Seregios, Gogmazios and Zoh Shia have empty tempered rows, so their
    tempered versions keep "HP desconhecido".
  - Base HP fallback (added on 2026-09-30 at the user's request): bases without HP on Kiranico
    (free title updates, collab) take the table's normal-individual value at strength ♦3. The page
    says every assignment and optional quest target is ♦3, and that column matches Kiranico.
    Lagiacrus 20,160, Seregios 19,800, Mizutsune 16,500 and Omega Planetes 90,020 are all High
    Rank. Gogmazios is listed only as "(410000)", which the page does not explain, so it stays
    unknown. Kiranico stays first for every other monster.
  - `tool/data/macaron.py` parses the table. It matches the Japanese names to slugs through the
    Kiranico Japanese monster pages.
  - The icon is the base icon (R7). All other sections are inherited from the base.
  - "Certificate γ" gets its own id (`-gamma`). Before, it collided with "Certificate".
- **Frenzied**: none. The wiki only mentions frenzy quest names.
- **Without wiki drop tables**: Guardian Arkveld (its HP comes from two Low Rank quests) and
  Omega Planetes (collab). Their drops stay empty ("Sem materiais").

### R4 result — Rise: Sunbreak (T028, 2026-09-30)

- **Roster**: 78 large monsters on the Kiranico list (`/data/monsters?view=lg`, database 16.0.0),
  written to `tool/data/rosters/rise_sunbreak.json` by `tool/data/roster_rise.py`. The result is
  67 base rows and 63 versions.
- **Apex** (6: Arzuros, Diablos, Mizutsune, Rathalos, Rathian, Zinogre) and **Risen** (5:
  Chameleos, Crimson Glow Valstrax, Kushala Daora, Shagaru Magala, Teostra) are versions. They
  have their own Kiranico pages, so their names (pt-BR "Rathalos Alfa", "Teostra Erguido"),
  weaknesses, parts, drops, habitats and icons are their own. The classification is the base
  species' when the wiki has no page of its own.
- **Own rows**: subspecies and rare species (Silver Rathalos, Gold Rathian…) and the named
  variants with their own Hunter's Notes entry (Primordial Malzeno, Scorned Magnamalo, Furious
  Rajang, Chaotic Gore Magala, Seething Bazelgeuse, Lucent Nargacuga…).
- **Afflicted**: 52 bases whose Kiranico page lists "Afflicted" materials. Each becomes an
  `afflicted` version with those materials (Master Rank carves; the page repeats them per anomaly
  level, so there is one row per material). The elder dragons, the serpents, Malzeno, Primordial
  Malzeno, Violet Mizutsune and Lucent Nargacuga have none. The name is English only ("Afflicted
  Rathalos"), because no official pt-BR name exists. The icon is the base's.
- **HP** (T030):
  - Afflicted: the "Anomaly Research: <monster>" row of the base page (e.g. Rathalos 88,200).
    Other Anomaly rows on that page are research quests of other targets, where the monster is
    only an extra.
  - Apex: its quests are Gathering Hub 8★ High Rank hunts ("The Fearsome Apex Rathalos",
    20,400). "Advanced:" 8★ quests are arena-style multi-Apex fights and are left out.
  - Risen: the Master Rank quests of its own page.
  - Every entry has HP.
- The 10 entries of feature 001 keep their values. Four part names gained their pt-BR name
  ("Garra", "Chifre"), because the part-name table now covers the whole roster.

### R4 result — World: Iceborne (T033, 2026-09-30)

- **Roster**: 71 large monsters on the Kiranico list (ver. 15.11), written to
  `tool/data/rosters/world_iceborne.json` by `tool/data/roster_world.py`. The result is 71 base
  rows and 46 versions. Subspecies and named variants (Ruiner Nergigante, Raging Brachydios,
  Savage Deviljho, Frostfang Barioth…) keep their own rows.
- **Correction to the plan above**: Kiranico's quest pages do not mark tempered or
  arch-tempered targets. The Monster Hunter Wiki quest pages ("MHWI Quest Pages") do, through
  their `Goal Icons` template (`Type=Tempered` / `Type=Arch Tempered`). There are 36 tempered and
  10 arch-tempered targets. Each becomes a version with its quests. Arena and challenge quests are
  marked by the page's categories.
- **Version data**:
  - Drops: the Kiranico reward tables of each of its quests, with rates, as method `other`
    labelled "Quest reward: <quest>" (pt-BR "Prêmio da missão: <Kiranico pt-BR quest name>").
    That keeps tickets (e.g. Nergigante Ticket, 100 % in "The Heralds of Destruction Cry") and
    streamstones. An item listed in two reward tables of one quest combines as independent
    draws.
  - HP: the monster's solo HP on those quest pages, with arena and challenge quests excluded.
    Quests where it is the only large monster come first, because World lowers each monster's HP
    in multi-monster quests (e.g. Arch-Tempered Nergigante 26,224). Tempered Nergigante has only
    multi-monster quests (4,998).
  - Tempered Savage Deviljho and Tempered Uragaan have only challenge quests, so their HP is
    unknown. "The Heart of the Nora" (tempered Deviljho, a collab event) is not on Kiranico.
- **Weakness stars** (29 bases not on mhw-db.com):
  - Velkhana and Alatreon keep their hand-checked Fextralife values.
  - The other 27 are parsed from the Fextralife "Weakness" box. The first rating of an element is
    the normal state; charged or crystallized ratings come later in parentheses. Where both
    sources rate a monster, Fextralife matches mhw-db on 29 of 30 elements.
  - Elements Fextralife does not rate use the hitzone rule on Kiranico's normal-state
    Physiology block: Raging Brachydios' dragon, and Yian Garuga's fire, thunder and ice.
  - The hitzone rule alone matches mhw-db only on 70 % of the elements, because the in-game
    notes rate each monster relatively. That is why it is only a fallback.
- **Habitats and classification** of monsters without Kiranico expeditions and not on mhw-db come
  from the wiki (MHWI page locales, including the Guiding Lands; classification from the base
  page). Seven new locales have no pt-BR name in the sources and show in English.
- The 10 entries of feature 001 keep their values. Alatreon's wiki source note gains "Locales.".

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

### R6 results (T038, 2026-09-30, after the 005 visual refresh)

- **Size**: release APK for arm64 (`flutter build apk --release --analyze-size
  --target-platform android-arm64`) is **24.9 MB**:
  - `lib/` (Flutter engine and AOT Dart code): 17.1 MB;
  - images: 6.6 MB (monster icons 6.5 MB, game logos 0.1 MB);
  - fonts: 0.33 MB;
  - datasets: 0.15 MB compressed (2.8 MB of JSON on disk).
  The estimate above (4 MB JSON, 6–8 MB icons) holds; the JSON compresses about 19×.
- **Time**: measured by `integration_test/app_test.dart` ("list opening and game switch times")
  on the real Windows app in profile mode (`flutter drive -d windows --profile`), because no
  phone was connected:
  - load of the three datasets: 43 ms;
  - list on screen from start: 150 ms (SC-004 target ≤ 1 s);
  - switching games: about 420 ms until everything settles, including the 220 ms fade of 005.
    The new list starts drawing in the first frame.
- A phone measurement remains open: run the same integration test with `flutter drive -d
  <device> --profile` when a device is connected.

### SC-002 spot check (T039, 2026-09-30)

- **Sample**: 10 new entries per game, drawn with a fixed seed (39) among those with drops and
  HP. Bases and versions are mixed: tempered, arch-tempered, afflicted, Apex and guardian.
- **Method**: one drop rate and the HP of each entry were compared with the **live** source page
  (Kiranico or the Monster Hunter Wiki, downloaded again, not the pipeline cache), read from the
  raw page text. The macarongamemo table was also downloaded again.
- **Result**: 30 of 30 match (World 10, Rise 10, Wilds 10). Details worth keeping:
  - An automatic summary of the Banbaro page gave 25 % for Banbaro Lash. The raw page shows that
    25 % belongs to "Investigation Reward (Gold)", which is out of scope. "Hunt Banbaro" is 16 %,
    as in the app.
  - Rompopolo's Toxin Sac is 40 % for both back and tail breaks, as in the app.
- **Fixed**: in Rise and Wilds, every monster listed its wiki page twice, as `…_(MHRS)` and
  `…_%28MHRS%29`, because `build_rise.py` / `build_wilds.py` and `items_extract.py` wrote the URL
  differently. The builders now quote it the same way. A rebuild changed only those duplicate
  sources.
- **Observation** (003 rule, not an error): World bases without Master Rank expeditions use the
  lowest regular quest HP, which can be a multi-monster quest. Silver Rathalos shows "a partir de
  15.000" from a two-monster quest, while its single hunts are 21.000. The tempered versions of
  005 prefer single-monster quests; the bases do not.


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
