# UI Contract: Armas da Rise

Reference: [mockups/approved.html](../mockups/approved.html). The style is the 005 Caderninho look:
discreet cards that never nest, gold as the only accent, IM Fell English SC for titles, Averia
Serif Libre for numbers and Atkinson Hyperlegible for text.

## App shell (navigation between areas)

- Destinations, in order: **Monstros**, **Armas**, **Armaduras**, **Assistente**.
- Below 840 dp: a bottom navigation bar. From 840 dp: a navigation rail on the left.
- The selected destination is shown in gold with its label in IM Fell.
- Armaduras and Assistente are visible but disabled: dimmed, and a tap does nothing. Their
  tooltip and semantics read "<área>, em breve".
- Each area keeps its state when you switch away and back: filters, search, scroll and the
  selected item.
- Semantics: each destination is a selectable tab with its label. The disabled ones expose
  `enabled: false`.

## Armas: list

- The game tabs use the 005 logo tabs.
  - Only Rise: Sunbreak is selectable.
  - World and Wilds are dimmed. Their label and semantics read "<jogo>, em breve", and a tap
    does nothing.
- **Weapon type picker**:
  - 14 blocks that scroll sideways, each with the type icon and its pt-BR name, at least
    48×48 dp.
  - The selected block has a gold edge.
  - The first type (Espada Grande) is selected on first open.
- **Rank filter**: underlined text tabs (Todos, Baixo, Alto, Mestre). A search field
  (underline) on the same row or the next.
- **Tree cards**, one per tree:
  - The title is the tree name, with the count (Averia) at the right.
  - Rows are ruled and indented by depth (`14 + 16 × depth` dp, depth capped at 3).
  - Each row has:
    - the icon, 34 dp;
    - the name (IM Fell) and the rank (body small);
    - at the right, the attack (Averia, bold), the element/status symbol and value, and the
      affinity (red when negative, as in the mockup).
  - The selected row (expanded layout) has the `panelHighlight` background and a gold mark.
- **Empty result**: "Nenhuma arma encontrada" and, when filters are active, a "Limpar filtros"
  button.
- **Load failure**: an error message and "Tentar de novo", inside the Armas area only.

## Armas: detail

- **Header**:
  - the weapon name (IM Fell, 32–34);
  - the subtitle "<tipo> · Raridade <n> · <rank> · <n>★ (estimado)";
  - the icon plate tilted +3°, as in the monster detail;
  - the description in italic, muted.
- **Cards**, numbered:
  1. **Atributos**:
     - attack, element/status (with the element's symbol and colour) and affinity, in Averia;
     - slots as level badges (1–4);
     - the Rampage slot as a separate gold badge with its level.
  2. **Afiação** (melee only):
     - two bars, "Normal" and "Com Artesanato (máximo)";
     - each segment's width is its units over 400.
  3. **Materiais**:
     - the groups "Melhorar" (from the previous weapon) and/or "Criar", as ruled captions;
     - each row has the material name and "×n" (Averia);
     - a material dropped by a known monster shows a "Dropado por: <monstro>" link that opens
       that monster's detail.
  4. **Árvore**:
     - ruled rows for the previous weapon, this weapon (gold) and each next weapon;
     - tapping a row opens that weapon.
- **Semantics**:
  - sharpness: "Afiação normal: vermelho X, laranja Y, …" and the same for Artesanato;
  - slots: "Slots: nível 3; Rampage: nível 2".

## Monster detail: "Armas feitas com ele"

- A new numbered card, the last one, shown only for Rise monsters that have weapons.
- The title shows the count. Up to 5 rows show the weapon name, its type and rank. "Ver todas
  (n)" opens the Armas area filtered to those weapons; this filter shows as a removable chip.
- Tapping a weapon opens it in the Armas area.

## Accessibility

- At 320 dp with 200 % text there is no overflow:
  - the type picker and the tabs scroll;
  - the attribute grid wraps to one column;
  - the materials rows wrap.
- Text contrast follows the 005 palette. Negative affinity uses `error` `#F2A08A`, which is
  ≥ 4.5:1 on panel and must be measured.
- Tap targets are at least 48 dp.
