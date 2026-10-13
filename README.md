# Caderninho

Offline wiki of large monsters from **Monster Hunter World: Iceborne**, **Monster Hunter
Rise: Sunbreak** and **Monster Hunter Wilds**, built with Flutter (Android, tablet, web and
Windows).

> Built with **Spec-Driven Development** (Spec Kit + Claude Code): 11 features, each with its own
> spec, plan, research, data model, UI contract and tasks in [`specs/`](specs/). Flutter · Dart ·
> Clean Architecture + MVC · fully offline.

- List monsters by game, with accent- and case-insensitive search (pt-BR and English names).
- Detail view: elemental weaknesses (including per-state variations), habitats, breakable
  parts, and materials by rank with acquisition method and drop rate.
- Versions (tempered, guardian and others) collapsed in their base monster's row and picked in
  the detail. Sections a version shares with its base are marked "Igual à forma base".
- Hunting info: reference HP per rank (solo, plus an approximate party estimate for 2–4
  hunters with its source), vision, and the reaction to Flash, Sonic/Screamer and Dung
  pods or bombs, Pitfall and Shock traps.
- **Armas** (feature 006): every Rise: Sunbreak weapon of the 14 types (3,925), browsed by
  type, rank and name, one card per upgrade tree. The detail shows attack, element or status,
  affinity, slots and Rampage slot, sharpness with and without Handicraft, forge and upgrade
  materials with the monsters that drop them, and the upgrade tree. A Rise monster lists the
  weapons made from it. Wilds weapons are in a game tab (feature 010, below).
- **Armaduras** (feature 007): the Rise: Sunbreak armor, with three tabs.
  - **Conjuntos**: 292 sets and 1,371 pieces, filtered by rank, by name or by a chosen skill.
  - **Habilidades**: 147 skills with the effect of each level, the jewels that give them and the
    pieces that have them.
  - **Joias**: 243 decorations, filtered by slot level.
  - A set shows its base and max defense, the five resistances, the summed skills, and each
    piece's forge materials with their sources.
  - Weapons gain a Rampage card: the Rampage skills to choose from (Low and High Rank), or the
    Rampage slot and the Rampage jewels that fit it (Master Rank).
- **Assistente** (feature 008): 323 ready-made Rise: Sunbreak builds from Game8 guides.
  - **Recomendadas**: pick where you are ("Onde você está?": Baixo 1–3★, Alto 4–7★, Mestre
    M1–M6★, Pós-jogo MR 10+ to 180+) and a weapon type; builds are split into "Para agora" and
    "Próximas".
  - A build shows its weapon, five pieces with jewels and "ou …" alternatives, the suggested
    talisman, the skills with pips and the jewel totals. Each item opens in Armas or Armaduras.
  - **Minhas builds**: saved copies, renamed or deleted, kept on the device.
  - **Montar build** (feature 009): pick the skills and levels you want; the app finds, offline,
    the weapon, five pieces, talisman and decorations that reach them within your progress (up to
    10 sets, "completa" or "quase"), shown like a curated build and savable in Minhas builds.
    - **Meus talismãs**: register your talismans (two skills, three slots); the search tries each.
    - Pin a weapon you own, or let it pick any of the type.
    - "Só peças do meu progresso" filters by rarity (Baixo ≤ 3, Alto 5–7, Mestre 8–10); within
      rarity 10 the Master Rank gates (Risen, Afflicted) are not modelled.
- **Wilds in Armas and Armaduras** (feature 010): game logos at the top of both areas switch
  between World, Rise: Sunbreak and Wilds. Each game keeps its own filters and
  selection. The Wilds content uses the Wilds icons.
  - **Armas**: 1,146 weapons of the 14 types, with the weapon skills (a tap opens the skill in
    Armaduras), sharpness with Handicraft, materials and the upgrade tree. There is no Rampage.
  - **Artian**: a group after each type's trees lists the three Artian (rarity 6, 7, 8) and your
    own. The simulator picks the element, the 3 parts (element, Attack or Affinity) and the 5
    reinforcement rolls. It shows attack, affinity, element with infusion, sharpness and slots
    live. Built Artian are saved on the device and can be renamed or deleted.
  - **Gogma Artian** (Gogmazios): a subsection of the Artian group lists the three foci (Ataque,
    Afinidade, Elemento) of each type. The detail compares them, explains how to get one (Tarred
    Device from Gogmazios) and links to Gogmazios.
  - **Armaduras**: 183 sets and 714 pieces, 179 skills with their kind (arma, armadura,
    conjunto, grupo), and 361 decorations filtered by weapon or armor kind. A fourth tab lists
    64 talismans with their ranks. A set shows its set bonus ("2 peças", "4 peças") and its
    group bonus.
- **World: Iceborne in Armas and Armaduras** (feature 011), with the World icons by rarity.
  - **Armas**: 3,123 weapons of the 14 types, rarity 1–12 and ranks Baixo, Alto and Mestre. The
    detail shows:
    - the displayed attack, affinity, and element or status. A hidden element is shown in
      parentheses, with the Liberar Elemento note;
    - Selo do Ancião, the defense bonus, slots of level 1–4, and the Iceborne augment slots;
    - sharpness with and without Handicraft, the type traits, materials with "Dropado por", and
      the tree.

    Kulve Taroth, Kjárr and Safi'jiiva weapons are in an "Especiais" card with "Como obter".
  - **Armaduras**: 360 sets and 1,638 pieces. Each set shows defense base → max, the summed skills
    and the set bonus (e.g. Lenda de Fatalis, 2 and 4 peças). There are also 198 skills (seals
    "conjunto" and "segredo"), 405 decorations of level 1–4 (two skills on many level 4 jewels)
    and 109 talismans I–V.
- Areas (Monstros, Armas, Armaduras, Assistente) in a bottom bar, or a side rail on wide screens; each keeps its
  filters and selection.
- Game names shown in Portuguese (Brazil) or English (Configurações).
- Side-by-side list and detail on wide screens (≥ 840 dp).
- "Caderninho" look (feature 005): a fixed dark theme like a hunter's notebook.
  - Each monster and each numbered detail section is a discreet card, with ruled rows inside.
  - Gold is the only accent.
  - The game tabs are the official game logos.
  - Weaknesses are ordered from best to worst, with element symbols, stars and a "Melhor"
    stamp.
  - HP is shown as a ruler with the party estimates.
  - Content changes with a short fade, turned off by the system's reduce-motion setting.

## Credits

- **Fonts**: [IM Fell English SC](https://fonts.google.com/specimen/IM+Fell+English+SC)
  (titles), [Averia Serif Libre](https://fonts.google.com/specimen/Averia+Serif+Libre)
  (numbers) and [Atkinson Hyperlegible](https://fonts.google.com/specimen/Atkinson+Hyperlegible)
  (text), SIL Open Font License, bundled with their `OFL.txt` in `assets/fonts/`.
- **Monster icons**: hunter's-notes icons from the
  [Monster Hunter Wiki](https://monsterhunterwiki.org/), converted to 256 px WebP. These are
  Capcom artwork, used here only locally in a personal study project. Replace them before any
  public release. The app falls back to a styled marker when an image is missing.
- **Game logos**: the official logos of the three games, from the Monster Hunter Wiki
  (`MHWI-Logo.png`, `MHRS-Logo.png`, `MHWilds-Logo.png`). They are Capcom artwork, used locally
  like the monster icons; see `assets/images/games/SOURCES.md`.
- **Design**: the 005 refresh followed the Tech Leads Club `frontend-design` skill
  (`.claude/skills/frontend-design`) and mockups the user approved
  (`specs/005-visual-refresh/mockups/`).
- **Weapon icons**: each weapon's icon from Kiranico and the type icons from the Monster Hunter
  Wiki, as 96 px WebP; Capcom artwork used locally like the monster icons (see
  `assets/images/weapons/SOURCES.md`).
- **Armor icons**: each piece's male render from Kiranico, as 96 px WebP (see
  `assets/images/armor/SOURCES.md`).
- **Data**: Kiranico, Monster Hunter Wiki, mhw-db.com and Fextralife (see each dataset's `sources`).
- **Builds**: the Game8 Monster Hunter Rise build guides; each build links to its source page.
- **World equipment**:
  - weapon and armor data from the Monster Hunter Wiki data modules (`Module:MHWI/data`);
  - set bonuses, skills, decorations and talismans from [mhw-db.com](https://mhw-db.com);
  - pt-BR names and the slot check from Kiranico World;
  - MHWI icons and renders from the Monster Hunter Wiki.
- **Wilds equipment**:
  - data from [wilds.mhdb.io](https://wilds.mhdb.io) (en + pt-BR);
  - Artian rules from the Monster Hunter Wiki, checked against Game8;
  - icons (equipment by rarity, decorations, weapon renders) from the Monster Hunter Wiki, and
    piece renders from Kiranico.

  This is Capcom artwork used locally, like the monster icons.

> Fan-made, non-commercial study project. Not affiliated with or endorsed by Capcom.
> Monster Hunter and all related names are trademarks of Capcom.

## Architecture

Clean Architecture per feature with MVC in the presentation layer. The rules are in
[.specify/memory/constitution.md](.specify/memory/constitution.md), and the design is in
[specs/001-monster-wiki/](specs/001-monster-wiki/).

```text
lib/
├── app/                 # MaterialApp + composition root (app/di)
├── core/                # shared domain types and presentation helpers
└── features/
    ├── monsters/{domain,data,presentation}
    ├── weapons/{domain,data,presentation}
    ├── armor/{domain,data,presentation}
    └── settings/{domain,data,presentation}
assets/data/<game>/monsters.json   # versioned datasets (schemaVersion 1)
assets/data/rise_sunbreak/weapons.json, armor.json
```

## Running

```powershell
flutter pub get
flutter run -d windows          # needs Windows Developer Mode (plugin symlinks)
flutter run -d chrome
flutter run -d <android-device>
```

Web build that works offline after the first load (custom service worker in `web/sw.js`;
CanvasKit is self-hosted so nothing depends on a CDN):

```powershell
flutter build web --release --no-web-resources-cdn
```

## Quality gates

```powershell
flutter analyze
dart format --set-exit-if-changed .
flutter test
flutter test integration_test -d <device>
```

## Adding or fixing monster data

Data changes never require code changes. Datasets are generated by the pipeline in
[`tool/data/`](tool/data/README.md) (`python tool/data/build.py <game>`). Fix a rule there and
rebuild instead of editing the JSON by hand. Hand edits follow
[the dataset schema](specs/001-monster-wiki/contracts/monster-dataset.schema.json) and the
validation rules in [data-model.md](specs/001-monster-wiki/data-model.md). Then run
`flutter test test/features/monsters/data/real_datasets_test.dart` to confirm the file is
still valid.

- Every dataset and every monster must list its `sources`.
- Omit `ratePercent` when a drop rate is not verified. The app then shows "Taxa desconhecida"
  and never shows an invented value.

**Data status** (feature 004, delivered one game at a time):

| Game | Base monsters | Versions | Roster |
|------|---------------|----------|--------|
| Wilds (game version 1.040) | 31 | 38 (3 guardians, 30 tempered, 5 arch-tempered) | Full large-monster list |
| Rise: Sunbreak (Kiranico database 16.0.0) | 67 | 63 (6 apex, 5 risen, 52 afflicted) | Full large-monster list |
| World: Iceborne (Kiranico ver. 15.11) | 71 | 46 (36 tempered, 10 arch-tempered) | Full large-monster list |

What counts as a version, and which data a version inherits, is described in
[research.md](specs/004-all-large-monsters/research.md) (R2–R4). In Wilds, arch-tempered versions come from their event and challenge quests on the
Monster Hunter Wiki: they list the quest rewards without rates. Tempered and arch-tempered HP (the lowest value,
"a partir de") comes from the
[macarongamemo HP table](https://macarongamemo.com/entry/mhwilds-monster-hp), because Kiranico
does not list those hunts. Four tempered versions (Lagiacrus, Seregios, Gogmazios, Zoh Shia) have
no value there.
The same table fills the HP of the free title update and collab monsters that Kiranico does not
list, except Gogmazios, which shows "HP desconhecido". Frenzied monsters have no entries, because
the sources give them no data of their own.
Sources are Kiranico, the Monster Hunter Wiki, mhw-db.com and Fextralife. Every monster lists
its sources, and the choices behind them are in
[research.md](specs/001-monster-wiki/research.md) (R12, R15). Rise and Wilds star ratings are
derived from hitzones by a documented rule, so they may differ slightly from the in-game field
guide.

**Hunting info** ([research](specs/003-hunting-info/research.md)):

- HP is a reference, not a fixed number. World uses the solo expedition HP of each rank; Rise
  and Wilds, and World ranks without expeditions, use the lowest HP of the rank's regular
  quests, shown as "a partir de".
- Party HP is always an estimate labeled "aprox.". It is the solo HP times the game's factor:
  World from Fextralife (×1.5 / ×2.2–2.6 / ×2.2–2.6); Rise (×1.35–1.5 / ×1.7–2.0 / ×2.0–2.4)
  and Wilds (×1.6 / ×2.0 / ×2.4) from Kiranico's per-player quest data.
- Item reactions come from the Monster Hunter Wiki. When its infobox and item table disagree,
  the infobox is used and the conflict is noted in the monster's `sources`. "Enxerga" is
  shown only when the Flash item affects the monster, so the app never claims a monster is
  blind.
- `hp`, `partyHpFactors`, `huntingItems` and `itemReactions` are optional. A monster without
  them shows "HP desconhecido" or "Desconhecido".

**Weapons** ([research](specs/006-rise-weapons/research.md)):

- `python tool/data/fetch_rise_weapon_pages.py` caches the Kiranico weapon pages, then
  `python tool/data/build_rise_weapons.py --icons` builds `weapons.json` and the icons.
- Stats, slots, the upgrade tree and points requirements come from the Monster Hunter Wiki MHRS
  pages; forge and upgrade materials and both sharpness bars come from Kiranico, which has the
  game's own data; pt-BR names come from Kiranico's pt-BR lists. 28 wiki entries that are not
  obtainable (no attack or no tree) are left out.
- The rank comes from rarity (1–3 Low, 4–7 High, 8–10 Master). The quest stars are an
  **estimate**, shown as "(estimado)": the highest of the lowest-star quests, in that rank, of
  the monsters that drop the weapon's materials (the first star of the rank when none does).
- 3,799 weapons (96.8 %) have an icon; the rest show the plate's marker.

**Armor** ([research](specs/007-rise-armor/research.md)):

- To rebuild the data, run the Python scripts in this order:
  1. `python tool/data/fetch_rise_armor_pages.py`;
  2. `python tool/data/fetch_rise_item_pages.py`;
  3. `python tool/data/build_rise_armor.py --icons`.
- **Sources**:
  - the Kiranico armor lists give the stats, slots and skills;
  - the armor pages give the materials;
  - the Monster Hunter Wiki set pages give the set, body part and max defense;
  - the Kiranico skills and decorations lists give the skills and decorations. 36 Sunbreak skills
    whose Kiranico list has no level text take it from the wiki, in English only.
- 220 rows with no defense and no skills (cosmetic armor) are left out.
- 1,282 pieces (93.5 %) have an icon.
- The release APK (arm64) was 34.2 MB at 007, 39.5 MB with the Wilds equipment (010) and 43.4 MB
  with the World equipment (011).

### Builds (Rise: Sunbreak)

- `python tool/data/build_rise_builds.py` reads the Game8 build pages per weapon type (Master
  Rank for Sunbreak, High and Low Rank for base Rise) and writes
  `assets/data/rise_sunbreak/builds.json`.
- Each build gets a stage from the guide (the Master Rank progression table gives the MR level).
- Weapons, pieces, skills and decorations are matched to our catalog: 99.2 % of the references
  are found. The rest (mostly two Rampage jewels) are kept by name and marked "não encontrado no
  catálogo".
- 323 builds, 2.6 MB.

### Optimizer data (Rise: Sunbreak)

- `python tool/data/build_rise_optimizer.py` writes `assets/data/rise_sunbreak/optimizer.json`
  (1.1 MB) from `armor.json` and `weapons.json`: skills with max levels, decorations (slot, skill,
  points), pieces (part, rarity, slots, defense, skills) and weapons (type, rarity, slots, attack).
- The search (`lib/features/assistant/domain/optimizer/`) prunes each part to its pareto front,
  combines the parts by dynamic programming over the wanted-skill levels and free slots, places
  decorations exactly, and ranks complete sets first, then free slots, then defense. It runs in a
  background isolate; a 4–6 skill request takes well under a second on a desktop.
