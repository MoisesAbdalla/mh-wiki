# Research: Assistente de builds da Rise: Sunbreak

## R1. Source pages

- **Decision**: the Game8 build pages of each weapon type.
  - **Master Rank (Sunbreak)**, one page per type:
    - Great Sword `380791`, Charge Blade `380792`, Hammer `380793`, Sword and Shield `380795`;
    - Long Sword `380797`, Hunting Horn `380800`, Lance `380801`, Gunlance `380802`;
    - Bow `380805`, Insect Glaive `380810`, Dual Blades `380777`, Switch Axe `381141`;
    - Light Bowgun `381282`, Heavy Bowgun `381358`.
  - **High and Low Rank (base Rise)**: one page per type and rank. The ids sit in the range
    `341257`–`341997`, linked from "High Rank Builds and Best Armor" (`326874`). The builder
    classifies each page by its `<title>` ("High Rank Great Sword Builds", "Low Rank … Builds").
- Pages are cached in `tool/data/.cache/` like the other sources, fetched slowly (one request at a
  time, 1 s apart).
- **Rationale**: Game8 gives structured tables for every build: a weapon table, an armor table
  with decorations per piece, a talisman row, and the resulting skills with levels and Rampage.
  Piece names match our catalog (checked: Primordial Helm, Rimeguard Mail, Flaming Espinas Brain,
  Risen Kaiser Horns, Onmyo Sashiko, Kaiser Crown X).
- **Alternatives**:
  - hand-curated builds: rejected by the user;
  - other sites (Sportskeeda, Ginx): prose only, no tables.

## R2. Parsing a build

- Each build is an `<h3>` (its name) followed by its tables:
  - **Weapon**: the name, then the decorations per slot ("ー" = empty), then the Rampage
    decorations.
  - **Armor**: one row per piece, with its decorations and skills. "A / B" lists an alternative
    piece.
  - **Talisman**: its decorations, then the skill and the requirement ("Level 3 with desired slots
    or better").
  - **Skills**: "Name Lv n" pairs, then "Rampage Skills" names.
- The **section heading** above a build is its stage: "Master Rank Build (Early Game): MR 1-2",
  "Endgame MR Build: MR 6+", "Ultra Endgame MR Build: MR 100+", "Gathering Hub HR 4 - HR 100+".
  A build's own heading may refine it ("(TU5 Build)", "MR 180+") when it gives one.
- **Matching**: names are matched to the catalog by normalized English name, with a fallback that
  ignores "Lv", "+" spacing and punctuation. Anything unmatched is kept by its source name, marked,
  and listed in the import report (FR-008).

## R3. Stage → progress

- **Decision**: map each stage label to one point of the progress picker.
  - "MR a–b" or "MR a+" with a ≤ 6 → Mestre M{a}★. "MR 6+" → M6★, the end of the story.
  - "MR a+" with a ≥ 10 → Pós-jogo, the highest band ≤ a among 10, 50, 100, 140 and 180.
  - "Hub HR a and b" → Alto a★: the guides name hub stars outright ("Hub HR 4 and 5").
  - "HR a to b" / "HR a+" → Alto 7★ when a ≥ 8, else 4★. HR 8 opens only after the 6★ urgent
    quest, so these builds belong after the 7★ quests.
  - "Village ★a to ★b" / "Low Rank" → Baixo, by the stars when given, else 1★.
- Progress compares as an ordered scale: Baixo 1–3★ < Alto 4–7★ < Mestre M1–M6★ < Pós-jogo
  10 < 50 < 100 < 140 < 180.

## R4. Independence from the weapon and armor datasets

- **Decision**: `builds.json` carries, for each item, the catalog id and the names (en, pt-BR).
  It also carries each skill's max level, so the pips can be drawn. The assistant feature does not
  need the weapons or armor datasets to render. Links to the weapon, piece, skill or decoration
  detail go through app-layer callbacks, as "Dropado por" does in 006.
- **Rationale**: a failure in one dataset must not break another area (FR-009). The builder fills
  the names from our own datasets at build time, so they stay consistent.

## R5. Saved builds and progress

- **Decision**: store them on the device with `shared_preferences`, the package the settings
  already use:
  - the progress and weapon type, under one key;
  - the saved builds, as a JSON list under one key, versioned.

  A saved build is a copy of a curated build (all its data), plus `name`, `savedAt` and `fromId`.
  So it survives a dataset update.
- **Rationale**: no new package; same pattern as the 001 settings.

## R6. Tests to add

- **Domain**:
  - stage parsing and ordering (R3);
  - the "Para agora" / "Próximas" split;
  - skill sums;
  - total decorations.
- **Data**:
  - DTO validation;
  - a real-dataset test with:
    - builds for all 14 types in Master Rank;
    - "Kamura Warrior Cleaver Raw Affinity" at M1★;
    - ≥ 95 % of the items matched;
  - the saved-builds repository: save, rename, delete, and survival over reloads.
- **Presentation**:
  - the progress picker (persisted);
  - the list sections;
  - the detail cards, with alternatives and unmatched items;
  - Minhas builds;
  - the disabled "Montar build" tab;
  - accessibility at 320 dp / 200 %.

## Results (T001, 2026-10-01)

- **Pages**: 42 (14 Master Rank, 14 High Rank, 14 Low Rank). The Low Rank Dual Blades page is
  `339296`.
- **Builds**: 323. Per type and rank:
  - every type has Master Rank and post-game builds;
  - High Rank has 5–13 builds per type;
  - Low Rank has 2–3 builds per type.
- **Stages**: the Master Rank pages' progression table ("MR180+ BU Blood Awakening …") gives each
  build its own MR level. A build takes it when its name overlaps the heading by ≥ 50 %; otherwise
  it takes the section stage.
- **Matching**: 99.2 % of the 8,618 item references are in our catalog, after these fixes:
  - names are read from the visible text, because image alts are cut at apostrophes;
  - possessives and accents are ignored;
  - "S" is added for base-Rise High Rank pieces, and "+" for weapons;
  - in "A / B Coil", the last word is shared;
  - aliases cover "Masters Touch" and "Quick Sheath".
- **Unmatched**: mostly Rampage decorations that neither Kiranico nor the wiki lists
  ("Anti-Wyvern Jewel 2" and "Fanged Exploit Jewel 2", 113 each), plus a few generic skills
  ("Element Attack"). They are kept by name.
- `builds.json` is 2.6 MB.
