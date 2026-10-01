# UI Contract: Armaduras, habilidades e joias

Reference: [mockups/approved.html](../mockups/approved.html), option **A**. The style is the
Caderninho direction from 005.

## Area and tabs

- In the app shell, **Armaduras** is enabled; **Assistente** stays "em breve".
- The tabs **Conjuntos**, **Habilidades** and **Joias** are underlined text tabs. Each keeps its
  own filters, search and scroll.

## Conjuntos

- The rank tabs are Todos, Baixo, Alto and Mestre.
- The search field reads "Buscar conjunto ou habilidade":
  - typing filters sets by set or piece name;
  - matching skills show as suggestions under the field, and choosing one adds a removable seal
    ("Reforço de Ataque ✕").
- **One card per set**:
  - the title is the set name, with "Raridade n" at the right;
  - one ruled row per piece, in body-part order, with:
    - the icon (28 dp, or a body-part glyph);
    - the name (IM Fell);
    - the skills, summarized ("Ataque 1 · Quebra-parte 1");
    - the slot gems at the right;
  - the footer shows the skill sum ("Conjunto: Reforço de Ataque 7 · Tampões 5 …"), with the
    chosen skill first and in bold.
- **Empty state**: "Nenhum conjunto encontrado" and "Limpar filtros".

## Detalhe do conjunto

- **Header**: the name, then "Rank Mestre · Raridade 9 · 5 peças", and the plate with the
  chest-piece icon.
- **1 Defesa**:
  - "Defesa" shows "570 → 870" in Averia;
  - five resistances follow, each with its element symbol, negatives in the error colour.
- **2 Habilidades**:
  - one ruled row per skill, with the name and pips;
  - pips are filled up to the summed level and outlined up to the max, plus "+n" when above the
    max;
  - a tap opens the skill.
- **3 Peças**:
  - one row per piece, with the name and the slot gems;
  - a tap expands the forge materials, using the shared material row with seals and the rates
    table, as in 006 US5.
- **Semantics**:
  - each skill reads "Reforço de Ataque, nível 7 de 7";
  - the resistances read "Resistências: fogo 15, água 5, trovão menos 10, …".

## Habilidades

- The list has a search field. Each row shows the name, the max level ("máx. 7") and the start of
  the description.
- **Detail**:
  - **Header**: the name, then the description and "máx. Nv. n".
  - **1 Níveis**: ruled rows, "Nv n" in gold followed by the effect.
  - **2 Joias**:
    - the name and the skill level ("· Nv 1") on the left, the slot gem on the right;
    - a tap opens the decoration;
    - the card is hidden when the skill has no decorations.
  - **3 Armaduras**:
    - the pieces that have the skill, master rank first, up to 8, then "Ver todas (n)";
    - each row shows the piece name and "Nv n";
    - a tap opens the set.

## Joias

- **Filters**: the slot level tabs are Todas, 1, 2, 3 and 4, plus a search field.
- Each row shows the slot gem, the name, and the skills it gives with their levels.
- **Detail**:
  - **Header**: the name and "Slot nível n".
  - **1 Habilidade**: the skills with their levels; a tap opens the skill.
  - **2 Materiais**: the shared material row with seals.

## Weapon detail: Rampage card

- The card number follows the last card of the weapon.
- **Low and High Rank weapons**:
  - the title is "Habilidades Rampage", with "escolha uma" as a note;
  - rows show the skill name and its effect, muted.
- **Master Rank weapons with a Rampage slot**:
  - the title is "Rampage";
  - one row shows "Slot Rampage" and a gold gem;
  - rows show the Rampage decorations that fit, each with its name, slot level and effect.
- The card is hidden when the weapon has neither Rampage skills nor a slot.

## Accessibility

- At 320 dp with 200 % text there is no overflow: the tabs and filters scroll, and the rows wrap.
- Tap targets are at least 48 dp.
- Text contrast follows the 005 palette.
