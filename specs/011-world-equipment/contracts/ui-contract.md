# UI Contract: Armas e Armaduras do World

Reference: [mockups/world.html](../mockups/world.html), approved on 2026-10-05. The Caderninho
style is kept, and the World content uses the World icons.

## Game tabs

- In Armas and Armaduras the World logo is enabled (no longer "em breve").
- Each game keeps its own state.

## Armas · World

- **List**:
  - the type picker shows the World type icons;
  - the rank tabs are Todos, Baixo, Alto, Mestre;
  - there is a search;
  - there is one card per tree. Each row shows the rarity icon, name, rank, displayed attack and
    element or status. A hidden element is in parentheses, for example "(Dragão 540)".
- **Especiais**: after the trees, an "Especiais" card lists the type's Kulve Taroth, Kjárr and
  Safi'jiiva weapons, each with a subtitle ("Kulve Taroth · sorteada", "Safi'jiiva · despertar").
- **Detail**:
  - the header shows the render (or the rarity icon), then "Tipo · Raridade N · Rank X";
  - **1 Atributos**:
    - attack, affinity, element or status (hidden in parentheses);
    - Selo do Ancião and Defesa +N, when present;
    - the slots, with World icons;
    - the note about Liberar Elemento, when hidden;
    - "Aumentos: N espaços", for Mestre;
    - the type traits;
  - **2 Afiação**: Normal, and Com Artesanato (nível 5), for melee weapons;
  - **3 Materiais**: forge and upgrade, with "Dropado por";
  - **4 Árvore**.

  For an Especial, "Como obter" replaces Materiais and Árvore.

## Armaduras · World

- The tabs are Conjuntos · Habilidades · Joias · Talismãs.
- **Set**:
  - Defesa base → máx. and the resistances;
  - Habilidades somadas (a set bonus shows "N peças");
  - Bônus do conjunto, with steps "2 peças" / "3 peças" / "4 peças" and their descriptions;
  - Peças: the part icon by rarity, the name, the skills and the slots.
- **Habilidades**: the "conjunto" and "segredo" seals.
- **Joias**: slot filter Todas, 1, 2, 3, 4. Each row shows the colour icon, the name and up to two
  skills.
- **Talismãs**: one row per talisman ("I–V"). The detail lists each level with skill pips, rarity
  and materials.

## Accessibility

- 320 dp at 200 % text with no overflow, 48 dp tap targets, contrast.
- A hidden element reads "Dragão 540, oculto".
