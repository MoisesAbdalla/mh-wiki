# Research: Armaduras, habilidades e joias da Rise: Sunbreak

## R1. Source of the armor data

- **Decision**: use three sources, each for what it has right:
  - **Kiranico armor lists** (`/data/armors?view=0..9`, one view per rarity 1–10, en and pt-BR):
    - id and names;
    - base defense;
    - resistances, read per element icon (`ElementType1..5`), not by column order: Rathalos X is
      thunder −2 and ice 1 per piece, while a column reading gave the opposite;
    - slots (`deco1..4.png`);
    - skills, with Kiranico skill ids and levels;
    - icons (`avatar/armors/<id>_m.webp`).
  - **Kiranico armor pages** (`/data/armors/<id>`): the forge materials with item ids and
    quantities. The wiki leaves out some materials (Rathalos Helm X misses "Heavy Rathalos
    Scrap"), as found for weapons in 006 R12.
  - **Monster Hunter Wiki MHRS set pages**: each piece title, e.g. "Rathalos Helm X (MHRS)",
    redirects to its set, "Rathalos X Set (MHRS)". The `GenericArmorSetPiece` template gives the
    body part (`Item Icon Type`: Helmet, Chestplate, Arms, Waist, Legs) and the max defense
    ("114 → 174").
- **Rationale**: Kiranico is the game data; the wiki adds what Kiranico lacks (set, part, max
  defense), as for weapon trees in 006.
- **Alternatives**:
  - group sets by name only: rejected; "Kamura Legacy Head Scarf" and the "X/S" variants make
    prefixes unreliable;
  - take materials from the wiki: rejected (missing scraps).

## R2. Obtainable pieces

- **Decision**: drop rows with defense 0 and all resistances 0 and no skills (e.g. "Ran Page
  Waist", which are layered or cut). Also drop pieces with no wiki set, after reporting them.
- 1,591 list rows before filtering. The counts per rarity after filtering are recorded in the
  build report and the real-dataset test.

## R3. Sets and their names

- **Decision**:
  - set = the wiki redirect target, its name taken from `Set Name`;
  - pt-BR set name = the longest common word suffix of the pt-BR piece names, without a leading
    "de/do/da" ("Elmo de Rathalos X", "Arm. de Rathalos X" → "Rathalos X";
    "Lenço Legado Kamura", "Veste Legado Kamura" → "Legado Kamura");
  - a one-piece set keeps the English name.
- Pieces sort by body part: head, chest, arms, waist, legs.

## R4. Skills and decorations

- **Skills**: the Kiranico skills list, en and pt-BR, paired by skill id. It gives the name, the
  description and the effect of each level; the max level is the number of levels.
- **Decorations**: the Kiranico decorations list, en and pt-BR. It gives the name, the slot level
  (the deco icon / the trailing number) and one or two skills with levels. Decoration materials
  come from the decoration pages (`/data/decorations/<id>`).
- **Links**: pieces and decorations refer to skills by Kiranico id, mapped to a slug.

## R5. Material sources (shared)

- **Decision**: move 006's `material_sources()` (Kiranico item pages, en and pt-BR) to
  `tool/data/kiranico_items.py`, so the weapons and armor builders share it. New items (armor and
  decoration materials) are fetched by the same cached fetcher.
- In the app, `MaterialSources`, `RankedSources` and the material row with seals move to `core`.
  The weapons feature keeps working as it is.

## R6. Rampage

- **Rampage skills**: the cached Kiranico weapon pages link each Low/High Rank weapon to its
  options (`/data/rampage-skills/<id>`). The Rampage skills list (en and pt-BR) gives the names and
  effects. They go into `weapons.json` (`rampageSkills` table, ids per weapon).
- **Rampage decorations**: the Kiranico Rampage decorations list (en and pt-BR) gives the name,
  the slot level and the skill. A Master Rank weapon's card lists those that fit its Rampage slot.
- Master Rank weapons have no Rampage skills (Sunbreak), only the slot.

## R7. Icons

- **Decision**: download the male render (`_m.webp`) of each piece, as 96 px WebP. When a piece
  has no icon, show a body-part glyph.
- About 7 MB, cheaper than the weapon icons.

## R8. Max defense

- **Decision**: take the max defense from the wiki ("Defense = 114 → 174"), and show "570 → 870"
  for the set. This revises the spec draft, which had left it out.

## R9. Tests to add

- **Domain**: set skill sums (with overflow above the max); filters (rank, name, skill); skill →
  decorations and pieces.
- **Data**:
  - DTO validation;
  - a real-dataset test with:
    - the counts per rarity;
    - every piece in a set;
    - no duplicates;
    - every skill reference resolving;
    - Rathalos X = 570/870 with resistances 15/5/−10/5/−15;
    - the skill sums of the set.
- **Presentation**:
  - the tabs and the set list (with the skill filter seal);
  - the set, skill and decoration details;
  - the Rampage card for High and Master Rank weapons;
  - accessibility at 320 dp / 200 %;
  - performance with 2,000 pieces.
