# UI Contract: Armas e Armaduras da Wilds

References: [mockups/approved.html](../mockups/approved.html) and
[mockups/artian.html](../mockups/artian.html), option **B**. The Caderninho style is kept, and the
Wilds content uses the Wilds icons (research R3).

## Game tabs (Armas, Armaduras)

- The `GameTabs` logos sit at the top: World ("em breve" until 011), Rise and Wilds. The last game
  opened is remembered for the session.
- Each game keeps its own type, filters, search, scroll and selection. Switching games does not
  reset them.

## Armas · Wilds

- The list works as for Rise: a type picker, then rows grouped by rarity. A row shows:
  - the name (pt-BR);
  - "Raridade N";
  - the element or status;
  - the slots.

  The icons are the Wilds type icons by rarity.
- **Artian**: after the rarity groups, a group "Artian" lists the three Artian of the type, then the
  user's saved Artians ("minha"). A tap opens the simulator.
- **Detail**:
  - the header shows the Wilds image (render, or the type icon);
  - **1 Atributos**: attack, affinity, element or status, slots, and the sharpness bar (with
    Handicraft);
  - **2 Habilidades da arma**: ruled rows with pips. A tap opens the skill in Armaduras (Wilds);
  - **3 Materiais**: forge and upgrade, with "Dropado por";
  - **4 Árvore**.

  There is no Rampage card.

## Artian simulator

- The header shows the name, "Espadão Artian · Raridade 8" and the Wilds icon.
- **1 Monte a sua**:
  - element chips (None, or each element available for the type);
  - **Peças (3)**: steppers for Elemento, Ataque and Afinidade, which add up to 3;
  - **Reforços (5)**: steppers for Ataque +5, Afinidade +5%, Elemento, Afiação +30, and Munição for
    bowguns. Each one is capped at its maximum, and the total is capped at 5.
  - "restam N" is shown for the parts and for the rolls.
- **2 Resultado**: the final attack, affinity, element value, sharpness bar and slots, updated live.
- **Buttons**: "Salvar minha Artian" asks for a name. A saved Artian also offers rename and delete
  (with a confirmation).

## Armaduras · Wilds

- The tabs are **Conjuntos · Habilidades · Joias · Talismãs**.
- **Set detail**:
  - the pieces: the part icon by rarity (Wilds), the name, the skills and the slot icons;
  - defense and resistances, then materials;
  - **Bônus do conjunto**:
    - the set skill, with each step ("2 peças", "4 peças"), its name and description;
    - the group skill ("(grupo)") with its "3 peças" step;
  - **Habilidades somadas**: set and group skills show the piece count.
- **Habilidades**: each row shows a kind seal (arma, armadura, conjunto, grupo). The detail lists
  the levels, decorations, pieces and weapons.
- **Joias**: filter chips Todas / De arma / De armadura, plus a slot filter. Each row shows the
  Wilds decoration icon, the name and both skills when it has two.
- **Talismãs**: each talisman shows its ranks (I, II, III…) with the skill and level, the rarity and
  the materials.

## Monstros · Wilds

- The monster detail gains "Armas feitas com ele", as for Rise.

## Accessibility

- At 320 dp with 200 % text there is no overflow, and chips and steppers wrap.
- Tap targets are at least 48 dp.
- Semantics:
  - game tabs read the game name;
  - set steps read "Fome de Arkveld, 2 peças: Regeneração Veloz I";
  - steppers read "Aumentar Ataque".
