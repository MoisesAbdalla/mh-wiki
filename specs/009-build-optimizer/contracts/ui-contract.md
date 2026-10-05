# UI Contract: Montar build

Reference: [mockups/approved.html](../mockups/approved.html) (screens 1–4). The style follows the
Caderninho direction (005) and the 008 detail. In the equipment card, layout B is used: ruled rows,
the part icon in its rarity colour, and decoration tiles.

## Tab

- In the Assistente, **Montar build** is enabled; the "em breve" label is gone.
- A context strip at the top reads "**Mestre · M6★** · Espadão" with "alterar". "alterar" switches
  to Recomendadas, where the picker is.

## 1 · Escolher habilidades

- **Card 1 "Habilidades que você quer"**:
  - a search field: typing lists matching skills; a tap adds a skill at its max level;
  - one ruled row per chosen skill:
    - the name and the pips (gold up to the chosen level, outlined up to the max);
    - − / + steppers with 48 dp targets;
    - ✕ to remove the skill.
  - "Comuns para {tipo}": up to 8 suggestion chips ("+ Agitador"); a tap adds the skill.
- **Card 2 "Arma e talismãs"**, three rows:
  - **Arma**: "Qualquer {tipo} até {progresso}" or the fixed weapon's name, with "escolher". It
    opens a searchable list of weapons of the type; the list includes "Qualquer".
  - **Weapon filters** (only with "Qualquer"), as choice chips under Arma:
    - "Frasco" (Charge Blade, Switch Axe) or "Bombardeio" (Gunlance): Qualquer plus the kinds the
      type has, most common first;
    - "Elemento ou status": Qualquer, Sem elemento and the kinds the type has, in game order;
    - "Nenhuma arma com esse filtro até {progresso}." in red when nothing fits, and the button
      disabled. Result cards name the weapon's phial or shelling and element ("Grande Gordlock ·
      Impacto").
  - **Meus talismãs**: "{n} cadastrados · usar todos", with a switch, and "gerenciar".
  - **Só peças do meu progresso**: "até {progresso} (raridade {r})", with a switch, on by default.
- **"Montar build"**: a full-width solid gold button, disabled while no skill is chosen.
- **While searching**: an overlay card reads "procurando… {n} combinações" with Cancelar.

## 2 · Meus talismãs (pushed page)

- A crumb "‹ Montar build", the title, and the note "Usados pelo Montar build. Ficam no aparelho."
- **Cadastrados**: one row per talisman, with the talisman icon, "Olho Crítico 3" (and the second
  skill on a muted line), and the slot icons (– for an empty slot). A tap edits the talisman; a
  long press or the trailing menu deletes it, with a confirmation.
- **Novo talismã** (the same form edits a talisman):
  - Habilidade 1: a searchable picker plus a − / + level;
  - Habilidade 2 (opcional): a picker or "nenhuma", plus a level;
  - Slot 1–3: a segmented choice of –, 1, 2, 3 or 4;
  - "Salvar talismã".
- **Empty state**: "Nenhum talismã cadastrado."

## 3 · Resultados

- The context strip reads "{n} habilidades · {progresso} · {tipo}" with "editar", which goes back
  to screen 1.
- A caption reads "{n} conjuntos encontrados".
- **Result card**:
  - "Opção N" (IM Fell), with a seal: "completa" in green, or "quase" in red;
  - a row of the 5 part icons in their rarity colours, plus the talisman icon;
  - "{arma} · talismã {talismã ou nenhum}";
  - the wanted skills as "Reforço de Ataque 7/7"; any that are short are in red;
  - "Defesa máx. {d} · sobram {slot icons}".
- The first card has a gold edge. A tap opens screen 4.
- A note gives the ranking: "Ordenados por: atinge tudo, depois mais slots livres, depois defesa."
- **No sets**: "Nenhum conjunto chega perto. Tente baixar níveis ou desligar 'Só peças do meu
  progresso'."

## 4 · Um resultado

- A crumb reads "‹ Resultados" and "‹ 1 de N ›".
- The header shows "Opção N", the seal, and "{tipo} · {progresso}".
- **1 Habilidades pedidas**:
  - ruled rows with pips; missing levels are red pips plus "falta n", and a reached skill shows ✓;
  - a muted line "Também vem: …" lists the other skills.
- **2 Equipamento**: the 008 rows for the weapon, the 5 parts and the talisman ("Talismã (seu)"),
  with decoration tiles. An item or tile opens Armas or Armaduras.
- **3 Joias**: the totals, as in 008.
- A "Salvar em Minhas builds" button. Saving gives the "Build salva em Minhas builds" feedback.

## Accessibility

- At 320 dp with 200% text there is no overflow; the steppers, chips and slot choices wrap.
- Every target is at least 48 dp.
- Semantics:
  - pips read "Olho Crítico, 5 de 7, faltam 2";
  - the seal reads "completa" or "quase";
  - steppers read "Diminuir" / "Aumentar Reforço de Ataque".
