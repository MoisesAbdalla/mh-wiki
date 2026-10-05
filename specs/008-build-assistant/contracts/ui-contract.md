# UI Contract: Assistente

Reference: [mockups/approved.html](../mockups/approved.html), list option **A**. The style follows
the Caderninho direction from 005.

## Area and tabs

- In the app shell, **Assistente** is enabled; no area is "em breve" any more.
- Three underlined tabs: **Recomendadas**, **Minhas builds** and **Montar build**. Montar build is
  dimmed, reads "Montar build, em breve", and does nothing on tap (009).

## Recomendadas

- **"Onde você está?" card** (a `NotebookSection` without a number):
  - rank tabs: Baixo, Alto, Mestre and Pós-jogo;
  - step chips for the chosen rank: 1–3★, 4–7★, M1–M6★, or MR 10+, 50+, 100+, 140+, 180+. The
    chosen chip is gold.
  - Changes apply at once and are saved.
- **Weapon type picker**: the one from 006, reused.
- **"Para agora"** caption, then build cards; **"Próximas"** caption, then the next builds' cards,
  dimmed with "A partir de M3★", "Depois da história" or "A partir de MR 100".
- **Build card**:
  - the name (IM Fell);
  - the stage seal ("MR 1–2", gold for now, muted for next);
  - the weapon (pt-BR) and up to 3 set names;
  - the top 4 skills, with the first two in full colour.
- **Empty state**: "Nenhuma build pronta para este ponto", with a pointer to the next builds.

## Detail

- **Header**:
  - the name;
  - the stage seal, then "type · fonte: Game8";
  - a crumb back to the list.
- **1 Equipamento** (layout B of [mockups/equipment-approved.html](../mockups/equipment-approved.html)):
  one card with a ruled row per part: Arma, Cabeça, Tronco, Braços, Cintura, Pernas and Talismã.
  Each row has:
  - an icon: the weapon's own image (or its type icon); for armor and the talisman, the game's
    part icon in the rarity colour (rarity 1 white … 10 orange; the talisman takes the rarest
    piece's colour);
  - the part caption and the name (IM Fell), with "ou …" for alternatives;
  - the decorations as tiles with their slot icon, three per line, or two when a tile cannot fit
    a whole word.

  A tap on a known item or decoration opens it in Armas or Armaduras. An unknown item shows
  "não encontrado no catálogo" in muted text. The talisman row reads "Olho Crítico Nv 3".
- **2 Habilidades**: ruled rows with pips up to the max; a tap opens the skill.
- **3 Joias**: each decoration with "×n", sorted by slot level.
- **Buttons and source**: a full-width "Salvar em Minhas builds" button, then the source link and
  the note on Qurious augments.

## Minhas builds

- **Cards**:
  - the saved name;
  - the stage seal;
  - "baseada em: …" and the date.
- A tap opens the same detail, with **Renomear** and **Excluir** (with a confirmation) instead of
  Salvar.
- **Empty state** explains how to save a build.

## Accessibility

- At 320 dp with 200 % text there is no overflow; the step chips and type picker wrap or scroll.
- Tap targets are at least 48 dp.
- Semantics:
  - the stage reads "Disponível a partir de M3 estrelas";
  - pips read "Reforço de Ataque, nível 7 de 7".
