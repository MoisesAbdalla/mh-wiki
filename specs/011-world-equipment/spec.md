# Feature Specification: Armas e Armaduras do World: Iceborne

**Feature Branch**: `011-world-equipment`

**Created**: 2026-10-05

**Status**: Draft

**Input**: User description: "Armas e Armaduras do World: Iceborne (011, depois da 010 Wilds; 012
assistente para World e Wilds). Liga a aba World (hoje "em breve") em Armas e Armaduras, com os
ícones e o visual do World. Armas de raridade 1–12 com elemento oculto, Selo do Ancião, bônus de
defesa, slots 1–4, afiação, espaços de aumento, materiais e árvore; grupo Especiais (Kulve Taroth,
Kjárr, Safi'jiiva) só para consulta. Armaduras de Baixo, Alto e Mestre com bônus de conjunto;
habilidades com selos; joias de nível 1–4; talismãs I–V."

**Reference**: the user approved the mockup [mockups/world.html](mockups/world.html) on
2026-10-05 (list, weapon detail, set detail, Joias and Talismãs). The user decided:
- **Especiais**: Kulve Taroth, Kjárr and Safi'jiiva leave the trees. They go into an "Especiais"
  group at the end of each type, read only, with how to get them (like the Wilds Gogma).
- **Aumentos (Iceborne)**: show only the number of slots by rarity, with no simulation.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Armas do World (Priority: P1)

The hunter opens Armas, picks the World tab (game logo) and a type. They see every World and
Iceborne weapon, one card per upgrade tree, filtered by rank (Baixo, Alto, Mestre) and by name.
Opening a weapon shows:
- the displayed attack, affinity, and element or status (hidden in parentheses, with an
  explanation);
- Selo do Ancião, the defense bonus and slots of level 1–4;
- sharpness with and without Handicraft;
- the number of augment slots;
- materials with the monsters that drop them, and the tree.

**Why this priority**: weapons are the most common lookup, and World is the last game without
them.

**Independent Test**: open Armas → World → Espadão → "Dharma Inabalável" and check it against the
game:
- Ataque 1344, Afinidade 0 %, Dragão (540) hidden, Selo do Ancião Alto, Defesa +30;
- two level 1 slots;
- 1 augment slot (rarity 12);
- it upgrades from Espada Selo Dragão I with Shara Ishvalda materials.

**Acceptance Scenarios**:

1. **Given** the Armas area, **When** it opens, **Then** the World tab is enabled (it is no longer
   "em breve") and keeps its own type, filters, search and selection.
2. **Given** the World tab and a type, **When** the list shows, **Then**:
   - each tree card lists its weapons with name, rank, displayed attack and element or status;
   - hidden elements are in parentheses;
   - icons are World's, by rarity;
   - the rank filter offers Todos, Baixo, Alto and Mestre.
3. **Given** a World weapon, **When** opened, **Then** the detail shows:
   - attributes: attack, affinity, element or status, Selo do Ancião, defense bonus, slots;
   - the type traits (phial, shelling, kinsect, notes, coatings, ammo);
   - sharpness with and without Handicraft;
   - the augment slots (Mestre only);
   - forge and upgrade materials, with "Dropado por" for World monsters;
   - the tree.

   There are no Rampage or weapon-skill cards.
4. **Given** a weapon with a hidden element, **When** opened, **Then** the value shows in
   parentheses with the note that it only works with the Liberar Elemento skill.
5. **Given** a type, **When** the list shows, **Then** the Kulve Taroth, Kjárr and Safi'jiiva
   weapons do not appear in the trees. They appear in an "Especiais" group at the end, read only;
   the detail explains how to get them (random drops from Kulve Taroth; Safi'jiiva's awakening).
6. **Given** a World monster in Monstros, **When** opened, **Then** it shows "Armas feitas com ele".

---

### User Story 2 - Armaduras do World (Priority: P2)

The hunter opens Armaduras → World and looks up:
- sets of Baixo, Alto and Mestre, with pieces, defense, resistances, summed skills and set bonus;
- skills, with a seal for set-bonus skills and for "segredo" skills;
- decorations of level 1–4, some with two skills;
- talismans with their levels I–V.

**Why this priority**: it completes the World equipment and is the base for the Assistente (012).

**Independent Test**: open "Fatalis α+" and check:
- 5 pieces of rarity 12, with slots and skills;
- defense base → max;
- the "Bônus do conjunto" card with Lenda de Fatalis: 2 pieces remove the level cap of the skill
  secrets, 4 pieces grant True Razor Sharp / Sharp Shot.

**Acceptance Scenarios**:

1. **Given** the Armaduras area, **When** it opens, **Then** the World tab is enabled. Its inner
   tabs are Conjuntos, Habilidades, Joias and Talismãs.
2. **Given** a World set, **When** opened, **Then** it shows:
   - each piece: the World part icon by rarity, slots and skills;
   - base and max defense, resistances and materials;
   - the summed skills;
   - the "Bônus do conjunto" card, with each step by piece count and its description.
3. **Given** the Habilidades tab, **When** shown, **Then**:
   - set-bonus skills carry the "conjunto" seal and secret skills the "segredo" seal;
   - the detail lists the levels and the decorations, pieces and talismans that give the skill.
4. **Given** the Joias tab, **When** shown, **Then** a filter by slot level (1–4) is offered. Each
   decoration shows the World icon in its color, and those with two skills show both.
5. **Given** the Talismãs tab, **When** shown, **Then** each talisman shows its levels (I–V), each
   with skill, level, rarity and materials.

---

### Edge Cases

- A weapon or piece with no icon in the source shows the type or part icon for its rarity.
- A material with no source monster (ore, bones, Kulve Taroth parts) has no "Dropado por".
- A weapon with two elements (dual blades) shows both.
- Bowguns have no sharpness. They show ammo and special ammo, as in Rise.
- A decoration with two skills appears in the detail of each of the two.
- In the summed skills, a set-bonus skill shows the piece count.
- Switching games in the tabs keeps each game's state.
- If the World data file is missing or invalid, only the World tabs show the error.
- With names in English (Configurações), every World name follows the preference.
- With large text (200 %) at 320 dp, nothing is cut off.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The World tab of Armas and Armaduras MUST be enabled. Each game keeps its own state.
- **FR-002**: The app MUST include every World and Iceborne weapon of the 14 types (rarity 1–12)
  with:
  - names in en and pt-BR, rarity and rank;
  - displayed attack, affinity, and element(s) or status, saying whether they are hidden;
  - Selo do Ancião, the defense bonus and slots (levels 1–4);
  - sharpness with and without Handicraft;
  - the type traits;
  - forge and upgrade materials, and the upgrade tree.
- **FR-003**: Rank Mestre weapons MUST show the number of augment slots by rarity (10: 3, 11: 2,
  12: 1). There is no augment simulation.
- **FR-004**: Kulve Taroth, Kjárr and Safi'jiiva weapons MUST be listed apart from the trees, in an
  "Especiais" group per type. The group is read only and says how to get them.
- **FR-005**: Materials MUST show the World monsters that drop them ("Dropado por"), and World
  monsters MUST list "Armas feitas com ele".
- **FR-006**: The app MUST include every World armor set of Baixo, Alto and Mestre, with:
  - pieces, rarity, slots, base and max defense, resistances, skills and materials;
  - the set bonus, with its steps by piece count.
- **FR-007**: World skills MUST show their effects by level and their kind: armor, set bonus or
  secret.
- **FR-008**: World decorations MUST show the slot level (1–4) and all their skills (up to two),
  with a filter by slot level.
- **FR-009**: The Talismãs tab MUST list the World talismans, each level with skill, level, rarity
  and materials.
- **FR-010**: World content MUST use World's icons: weapon types and armor parts by rarity,
  talisman, decorations by color, and slots by level. Rise and Wilds keep their own.
- **FR-011**: Every data source MUST be recorded, and names follow the language preference.
- **FR-012**: A failure in the World data MUST affect only the World content.
- **FR-013**: The Caderninho style (005) and the 010 pattern apply. Accessibility: no overflow at
  320 dp with 200 % text, contrast, 48 dp targets and semantics.

### Key Entities *(include if feature involves data)*

- **World weapon**: as in Rise, plus hidden element, Selo do Ancião, defense bonus, slots 1–4,
  augment slots and a "special" mark. It has no Rampage and no weapon skills.
- **World set**: pieces with base and max defense, resistances, slots and skills, plus the set
  bonus with steps by piece count.
- **Skill**: its kind (armor, set bonus, secret) and its effects by level.
- **Decoration**: slot level (1–4), color and up to two skills.
- **Talisman**: levels I–V, each with skills, rarity and materials.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100 % of the weapons, sets, decorations, skills and talismans in the sources are in
  the app, with pt-BR names for at least 99 %.
- **SC-002**: A check of 10 weapons, 10 sets and 10 decorations of varied types and rarities
  against the game or another source shows no difference.
- **SC-003**: At least 95 % of the weapons and pieces show a World image or icon.
- **SC-004**: The World weapon list opens in at most 1 second after the first load.

## Assumptions

- Data:
  - weapons and armor: the Monster Hunter Wiki data modules (World + Iceborne), which give stats,
    sharpness, materials, tree and max defense;
  - set bonus, decorations, talismans and skills: mhw-db.com;
  - pt-BR names: Kiranico World (pt-BR pages).
- Icons and images: monsterhunterwiki.org (the MHWI set), like the logos already used.
- "Dropado por" uses the World monster data the app already has (004).
- Augments: rarity 10 has 3 slots, 11 has 2 and 12 has 1 (game rule). The effects are not shown.
- Out of scope:
  - custom upgrades (Safi/Kulve) and the augment simulation;
  - layered armor, special tools and Palico gear;
  - the Assistente and Montar build for World (012).
