# Feature Specification: Armas e Armaduras da Wilds

**Feature Branch**: `010-wilds-equipment`

**Created**: 2026-10-05

**Status**: Draft

**Input**: User description: "Levar as armas e o resto para World e Wilds; Wilds primeiro, por jogo e
completo (Armas + Armaduras); usar os ícones e o visual da Wilds na Wilds; as armas Artian também,
com simulador (opção B)."

**Reference**: mockups aprovados em [mockups/approved.html](mockups/approved.html) (abas de jogo,
detalhe da arma com habilidades, conjunto com bônus, joias e talismãs) e
[mockups/artian.html](mockups/artian.html), opção **B** (simulador). Decisões do usuário em
2026-10-05:
- ordem: Wilds (010), depois World (011), depois o Assistente para os dois (012);
- cada jogo usa os próprios ícones (partes por raridade, imagens das armas, slots e joias);
- Artian com simulador.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Armas da Wilds (Priority: P1)

O caçador abre Armas, escolhe a aba da Wilds (logo do jogo), escolhe o tipo e vê as armas da Wilds
por raridade; ao abrir uma, vê ataque, afinidade, elemento ou status, afiação, slots, as habilidades
da arma, os materiais com quem os dá e a árvore de melhoria.

**Why this priority**: a Wilds é o jogo atual; armas são a consulta mais comum.

**Independent Test**: abrir Armas → Wilds → Espadão → "Sieglinde" e conferir com o jogo: Ataque
1008, Afinidade 15%, Veneno 300, slots ③②①, Prolongar Veneno 1 e Status Crítico 3, materiais
(Escama de Rathian+ ×5, Rubi de Rathian ×1, Símbolo de Caçador I ×5).

**Acceptance Scenarios**:

1. **Given** a área Armas, **When** aberta, **Then** mostra abas de jogo com os logos (World "em
   breve", Rise, Wilds); cada jogo guarda o próprio tipo, filtros e seleção.
2. **Given** a aba Wilds e um tipo, **When** a lista é exibida, **Then** as armas aparecem por
   raridade com nome pt-BR, elemento ou status e slots, com os ícones e imagens da Wilds.
3. **Given** uma arma da Wilds, **When** aberta, **Then** o detalhe mostra os atributos, a afiação,
   os slots, um card "Habilidades da arma" (quadradinhos até o máximo), os materiais de forja e
   melhoria (com "Dropado por" quando o material vem de um monstro da Wilds) e a árvore; não há card
   de Rampage.
4. **Given** uma habilidade da arma, **When** tocada, **Then** abre a habilidade em Armaduras
   (aba Wilds).
5. **Given** um monstro da Wilds em Monstros, **When** aberto, **Then** mostra "Armas feitas com ele",
   como na Rise.

---

### User Story 2 - Armaduras da Wilds (Priority: P2)

O caçador abre Armaduras → Wilds e consulta conjuntos (peças, defesa, resistências, habilidades,
bônus de conjunto e de grupo), habilidades (com o tipo: arma, armadura, conjunto, grupo), joias
(de arma e de armadura, algumas com duas habilidades) e talismãs (com seus níveis).

**Why this priority**: completa a consulta de equipamento da Wilds e é a base do Assistente (012).

**Independent Test**: abrir "Arkveld α": 5 peças de raridade 8 com slots e habilidades, o card
"Bônus do conjunto" com Fome de Arkveld (2 peças: Regeneração Veloz I; 4 peças: Regeneração Veloz II)
e Pelica Fortificante (grupo, 3 peças: Fortificar).

**Acceptance Scenarios**:

1. **Given** a área Armaduras, **When** aberta, **Then** mostra as abas de jogo; na Wilds as abas
   internas são Conjuntos, Habilidades, Joias e Talismãs.
2. **Given** um conjunto da Wilds, **When** aberto, **Then** mostra cada peça (ícone da parte na cor
   de raridade da Wilds, slots, habilidades), defesa base e máxima, resistências, materiais, as
   habilidades somadas e o card "Bônus do conjunto" com cada etapa (2 e 4 peças) e a habilidade de
   grupo (3 peças).
3. **Given** a aba Habilidades, **When** exibida, **Then** cada habilidade mostra o tipo (arma,
   armadura, conjunto, grupo) e os níveis; o detalhe lista as joias, peças e armas que a dão.
4. **Given** a aba Joias, **When** exibida, **Then** um filtro separa joias de arma e de armadura e
   outro o nível do slot; joias com duas habilidades mostram as duas.
5. **Given** a aba Talismãs, **When** exibida, **Then** cada talismã mostra seus níveis (I, II, III…)
   com a habilidade, a raridade e os materiais.

---

### User Story 3 - Armas Artian com simulador (Priority: P3)

O caçador vê as Artian de cada tipo (raridade 6, 7 e 8) num grupo próprio; ao abrir uma, monta a
sua: escolhe o elemento, as 3 peças do bônus de produção e os reforços que tirou, e vê os números
finais; pode salvar a Artian montada no aparelho.

**Why this priority**: é a arma do fim de jogo da Wilds; o simulador é o diferencial pedido (B).

**Independent Test**: Varianza (Espadão, raridade 8), Gelo com 3 peças de Gelo, reforços Ataque ×4 e
Afinidade ×1 → os números finais batem com a fonte (Game8) para essa combinação.

**Acceptance Scenarios**:

1. **Given** um tipo na aba Wilds, **When** a lista é exibida, **Then** um grupo "Artian" no fim
   lista as três Artian do tipo (raridade 6, 7, 8) com o ataque base e "elemento à escolha".
2. **Given** uma Artian, **When** aberta, **Then** o card "Monte a sua" permite escolher o elemento
   (ou nenhum), distribuir as 3 peças (do elemento, de ataque, de afinidade) e contar os reforços
   (Ataque, Afinidade, Elemento, Afiação, e Munição nas bestas), respeitando o total e o limite de cada
   um.
3. **Given** uma montagem, **When** mudada, **Then** o card "Resultado" mostra na hora ataque,
   afinidade, elemento ou status, afiação e slots finais.
4. **Given** uma montagem, **When** o usuário toca "Salvar minha Artian" e dá um nome, **Then** ela
   fica no aparelho, aparece no grupo Artian como "minha" e pode ser renomeada ou excluída.
5. **Given** dados da Artian ausentes para um tipo, **When** o grupo é exibido, **Then** ele não
   aparece (sem erro).

---

### Edge Cases

- Arma da Wilds sem imagem na fonte: mostra o ícone do tipo; peça sem ícone: o ícone da parte.
- Material sem monstro de origem (minério, Símbolo de Caçador): sem "Dropado por".
- Joia com duas habilidades: aparece no detalhe de cada uma das duas.
- Habilidade de conjunto ou grupo: as "habilidades somadas" mostram o número de peças, não níveis.
- Trocar de jogo nas abas mantém o estado de cada jogo.
- Arquivo de dados da Wilds ausente ou inválido: só as abas Wilds mostram o erro; Rise e as outras
  áreas seguem.
- Nomes em inglês (Configurações): todos os nomes da Wilds seguem a preferência.
- Texto grande (200 %) em 320 dp: sem cortes.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Armas e Armaduras MUST ter abas de jogo com os logos (World "em breve" até a 011,
  Rise, Wilds), cada jogo com o próprio estado (tipo, filtros, busca, seleção).
- **FR-002**: O app MUST trazer todas as armas da Wilds dos 14 tipos, com nome (en e pt-BR),
  raridade, ataque, afinidade, elemento ou status, afiação, slots, habilidades da arma, materiais
  de forja e melhoria e a árvore de melhoria.
- **FR-003**: O detalhe da arma da Wilds MUST mostrar o card "Habilidades da arma" e NÃO o card de
  Rampage.
- **FR-004**: Os materiais MUST indicar os monstros da Wilds que os dão ("Dropado por"), quando a
  origem existir nos dados de monstros da Wilds; e monstros da Wilds MUST listar "Armas feitas com
  ele".
- **FR-005**: O app MUST trazer todos os conjuntos de armadura da Wilds (Rank Baixo e Alto), com
  peças, raridade, slots, defesa base e máxima, resistências, habilidades, materiais, bônus de
  conjunto (etapas por número de peças) e habilidade de grupo.
- **FR-006**: Habilidades da Wilds MUST indicar o tipo (arma, armadura, conjunto, grupo) e os
  efeitos por nível.
- **FR-007**: Joias da Wilds MUST indicar se são de arma ou de armadura, o nível do slot e todas as
  suas habilidades (até duas), com filtro por tipo e por slot.
- **FR-008**: A aba Talismãs MUST listar os talismãs da Wilds com cada nível (habilidade, raridade,
  materiais).
- **FR-009**: Conteúdo da Wilds MUST usar os ícones da Wilds: partes da armadura na tabela de cores
  de raridade da Wilds, imagens das armas, ícones de slot e de joia; a Rise mantém os seus.
- **FR-010**: O app MUST trazer as Artian de cada tipo (raridade 6, 7, 8) com atributos base,
  elementos possíveis e seus valores, bônus de produção, reforços (com limites e valores) e materiais.
- **FR-011**: O simulador de Artian MUST calcular ataque, afinidade, elemento ou status, afiação e
  slots finais para a montagem escolhida, respeitando 3 peças, o total de reforços e o limite de cada
  reforço.
- **FR-012**: Users MUST be able to salvar, renomear e excluir Artian montadas, guardadas no
  aparelho.
- **FR-013**: Toda fonte de dados MUST ficar registrada; nomes seguem a preferência de idioma.
- **FR-014**: Falha nos dados da Wilds MUST afetar só o conteúdo da Wilds.
- **FR-015**: Estilo Caderninho (005) e cards da 007/008; acessibilidade em 320 dp com 200 % de
  texto, contraste, alvos de 48 dp e semântica.

### Key Entities *(include if feature involves data)*

- **Arma da Wilds**: como a da Rise, mais habilidades da arma; sem Rampage.
- **Conjunto da Wilds**: peças, bônus de conjunto (etapas por peças) e habilidade de grupo.
- **Habilidade**: com tipo (arma, armadura, conjunto, grupo).
- **Joia**: tipo (arma ou armadura), slot e até duas habilidades.
- **Talismã**: níveis I, II, III…, cada um com habilidade, raridade e materiais.
- **Artian base**: tipo, raridade, atributos, elementos, regras de produção e reforço.
- **Minha Artian**: uma Artian base com elemento, peças e reforços escolhidos e um nome.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100 % das armas, conjuntos, joias, habilidades e talismãs da fonte estão no app, com
  nomes pt-BR em ao menos 99 %.
- **SC-002**: Conferência de 10 armas, 10 conjuntos e 10 joias de tipos e raridades variadas contra o
  jogo ou a wiki, sem divergência.
- **SC-003**: Ao menos 95 % das armas e peças da Wilds mostram uma imagem ou ícone da Wilds.
- **SC-004**: O simulador de Artian bate com a fonte em 5 combinações conferidas (tipos e elementos
  diferentes).
- **SC-005**: A lista de armas da Wilds abre em até 1 segundo depois do primeiro carregamento.

## Assumptions

- Dados de armas, armaduras, habilidades, joias e talismãs: wilds.mhdb.io (en e pt-BR oficiais).
- Ícones e imagens: monsterhunterwiki.org (conjunto da Wilds), como os logos já usados.
- Artian: páginas de stats da Game8 por tipo (a wilds.mhdb.io não as traz).
- "Dropado por" usa os dados de monstros da Wilds que o app já tem (004).
- Fora do escopo: World (011), Assistente e Montar build da Wilds (012), equipamento de Palico,
  roupas de layered, armas de evento ainda não presentes na fonte.
