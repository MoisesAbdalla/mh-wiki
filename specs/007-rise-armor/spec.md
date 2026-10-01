# Feature Specification: Armaduras, habilidades e joias da Rise: Sunbreak

**Feature Branch**: `007-rise-armor`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "Armaduras, habilidades e joias da Rise: Sunbreak no app Caderninho
(segunda da sequência 006–010). Catálogo offline de todas as peças de armadura (Rank Baixo, Alto e
Mestre), agrupadas em conjuntos, com defesa, resistências, slots, habilidades e materiais com
origem; todas as habilidades com o efeito por nível; todas as joias; habilidades e joias Rampage. A
área Armaduras é ligada, com abas Conjuntos, Habilidades e Joias; a arma ganha o card Rampage."

**Reference**: mockup aprovado pelo usuário em [mockups/approved.html](mockups/approved.html), opção
**A** (lista por conjunto), com as telas "Detalhe do conjunto", "Detalhe da habilidade" e "Na arma:
novo card Rampage". Aprovado em 2026-10-01 ("ok gostei, qualquer coisa a gente ajusta algo depois").
Roteiro: 006 armas (entregue) → 007 → 008 assistente → 009 otimizador → 010 IA opcional.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consultar os conjuntos de armadura (Priority: P1)

O caçador abre a área Armaduras, escolhe um rank e vê um card por conjunto: as peças com seus slots
e habilidades, e no rodapé a soma das habilidades do conjunto. Pode buscar pelo nome do conjunto ou
por uma habilidade, que filtra os conjuntos que a têm.

**Why this priority**: é a consulta mais comum (o que o conjunto do monstro que acabei de caçar me
dá?) e a base para habilidades, joias e para as builds da 008–009.

**Independent Test**: abrir Armaduras, escolher Rank Mestre, buscar "Reforço de Ataque" e encontrar
o conjunto Rathalos X com Reforço de Ataque 7 no rodapé.

**Acceptance Scenarios**:

1. **Given** a barra de navegação, **When** o usuário toca em Armaduras, **Then** a área abre na aba
   Conjuntos (a área deixa de aparecer como "em breve").
2. **Given** a aba Conjuntos, **When** o usuário escolhe um rank (Todos, Baixo, Alto, Mestre),
   **Then** aparecem só os conjuntos daquele rank, um card por conjunto, com as peças em ordem
   (cabeça, tronco, braços, cintura, pernas).
3. **Given** um card de conjunto, **When** exibido, **Then** cada peça mostra nome, slots (ícones do
   jogo com o nível) e habilidades com nível, e o rodapé mostra a soma das habilidades das peças.
4. **Given** a busca, **When** o usuário digita parte do nome de um conjunto (pt-BR ou inglês, sem
   acento ou maiúsculas), **Then** aparecem os conjuntos que combinam.
5. **Given** a busca, **When** o usuário escolhe uma habilidade sugerida, **Then** a lista mostra só
   os conjuntos com alguma peça que a tenha, e a habilidade aparece como um selo removível.

---

### User Story 2 - Ver tudo sobre um conjunto e suas peças (Priority: P2)

O caçador abre um conjunto e vê, em cards numerados, a defesa total e as resistências, a soma das
habilidades com o nível obtido até o máximo de cada uma, e cada peça com slots e os materiais de
forja com a origem (como nas armas).

**Why this priority**: responde "vale fazer esse conjunto?" e "o que preciso caçar ou coletar?".

**Independent Test**: abrir Rathalos X e conferir defesa 570, resistências (fogo 15, água 5,
trovão 5, gelo −10, dragão −15), as habilidades somadas e os materiais do Elmo com a Kiranico.

**Acceptance Scenarios**:

1. **Given** o detalhe de um conjunto, **When** aberto, **Then** mostra o cabeçalho (nome, rank,
   raridade, número de peças) e os cards 1 Defesa, 2 Habilidades e 3 Peças.
2. **Given** o card Defesa, **When** exibido, **Then** mostra a soma da defesa base e das cinco
   resistências, com valores negativos destacados.
3. **Given** o card Habilidades, **When** exibido, **Then** cada habilidade mostra o nível somado
   como quadradinhos cheios até o máximo da habilidade; tocar abre o detalhe da habilidade.
4. **Given** o card Peças, **When** o usuário toca numa peça, **Then** aparecem os materiais de forja
   com quantidade e os selos de origem (monstro grande com link, monstro pequeno, coleta, missão ou
   origem desconhecida), e tocar num material abre a lista com as chances, como nas armas.

---

### User Story 3 - Habilidades e joias (Priority: P3)

O caçador consulta uma habilidade: o que cada nível faz, que joias a dão (e em que nível de slot
cabem) e que peças de armadura a têm. Também consulta a lista de joias, filtrando pelo nível do
slot.

**Why this priority**: entender habilidades e onde consegui-las é o passo antes de montar builds
(008–009).

**Independent Test**: abrir Reforço de Ataque e conferir os 7 níveis, as joias "Joia do Ataque 2"
(Nv. 1, slot 2) e "Joia Ataque+ 4" (Nv. 2, slot 4) e peças como o Avamb. de Rathalos X (Nv. 2).

**Acceptance Scenarios**:

1. **Given** a aba Habilidades, **When** aberta, **Then** lista todas as habilidades com busca por
   nome (pt-BR ou inglês).
2. **Given** o detalhe de uma habilidade, **When** aberto, **Then** mostra a descrição, o nível
   máximo e o efeito de cada nível.
3. **Given** o detalhe de uma habilidade, **When** exibido, **Then** mostra as joias que a dão (nome,
   nível da habilidade, nível do slot) e as peças de armadura que a têm (com o nível), agrupadas por
   rank, com uma lista resumida e acesso a todas.
4. **Given** a aba Joias, **When** o usuário filtra por nível de slot (1 a 4) ou busca, **Then** vê
   as joias correspondentes com a habilidade e o nível que dão.
5. **Given** o detalhe de uma joia, **When** aberto, **Then** mostra a habilidade (com link), o nível
   do slot e os materiais com os selos de origem.

---

### User Story 4 - Rampage na arma (Priority: P4)

No detalhe de uma arma, o caçador vê suas opções Rampage: as habilidades Rampage para escolher
(armas de Rank Baixo e Alto) ou, em armas de Rank Mestre, o slot Rampage e as joias Rampage que
cabem nele.

**Why this priority**: completa a arma da 006 (as habilidades Rampage foram adiadas para cá).

**Independent Test**: abrir a Lâmina D. Kamura V (Rank Alto) e ver Ref. de Afinid. III, Reforço de
Defesa II e Mestre em Montaria; abrir uma arma de Rank Mestre com slot Rampage 3 e ver as joias
Rampage de nível até 3.

**Acceptance Scenarios**:

1. **Given** uma arma de Rank Baixo ou Alto, **When** o detalhe é aberto, **Then** um card
   "Habilidades Rampage" lista as opções, cada uma com o efeito.
2. **Given** uma arma de Rank Mestre com slot Rampage, **When** aberta, **Then** o card mostra o
   slot e as joias Rampage que cabem (nível menor ou igual ao do slot), com a habilidade que dão.
3. **Given** uma arma sem habilidades nem slot Rampage, **When** aberta, **Then** o card não
   aparece.

---

### Edge Cases

- Peças que o jogo não permite obter (defesa 0 e sem nome real, como "Ran Page Waist") não aparecem.
- Conjunto incompleto (menos de cinco peças): mostra só as peças que existem e a soma delas.
- Habilidade somada acima do máximo: mostra o máximo cheio e indica o excedente (ex.: "+1").
- Peça sem slots ou sem habilidades: o campo some, em vez de mostrar "0".
- Joia que dá duas habilidades (joias de nível 4 compostas): mostra as duas.
- Material sem origem nas fontes: "Origem desconhecida", como nas armas.
- Busca sem resultado ou filtro vazio: mensagem e opção de limpar os filtros.
- Falha ao carregar os dados de armaduras: só a área Armaduras (e o card Rampage, se depender
  deles) mostra o erro; Monstros e Armas funcionam normalmente.
- Texto a 200 % em telas de 320 dp: sem cortes; abas e filtros rolam.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A área Armaduras DEVE ficar disponível na navegação, com as abas Conjuntos,
  Habilidades e Joias; o Assistente continua "em breve".
- **FR-002**: O catálogo DEVE conter todas as peças de armadura obteníveis da Rise: Sunbreak
  (raridades 1 a 10), cada uma com: nome em pt-BR e inglês (seguindo a preferência de idioma dos
  nomes), parte do corpo, raridade, rank, defesa base, as cinco resistências, slots com nível,
  habilidades com nível, materiais de forja com quantidade e origem, ícone quando houver, e a qual
  conjunto pertence.
- **FR-003**: O catálogo DEVE conter todas as habilidades (nome, descrição, nível máximo e efeito de
  cada nível) e todas as joias (nome, habilidades e níveis que dão, nível do slot e materiais).
- **FR-004**: O catálogo DEVE conter as habilidades Rampage de cada arma de Rank Baixo e Alto e as
  joias Rampage (nome, habilidade, nível do slot).
- **FR-005**: A aba Conjuntos DEVE permitir filtrar por rank e buscar por nome de conjunto ou
  habilidade (sem distinguir acentos e maiúsculas, em pt-BR e inglês); a habilidade escolhida vira
  um filtro removível.
- **FR-006**: Cada conjunto DEVE aparecer como um card com as peças em ordem de parte do corpo, e a
  soma das habilidades no rodapé.
- **FR-007**: O detalhe do conjunto DEVE mostrar os cards numerados 1 Defesa (soma da defesa base e
  das resistências), 2 Habilidades (nível somado até o máximo, com link à habilidade) e 3 Peças
  (slots e materiais com a origem no rank do conjunto).
- **FR-008**: O detalhe da habilidade DEVE mostrar os efeitos por nível, as joias que a dão e as
  peças de armadura que a têm.
- **FR-009**: A aba Joias DEVE permitir buscar e filtrar pelo nível do slot; o detalhe da joia
  mostra a habilidade (com link) e os materiais.
- **FR-010**: O detalhe da arma DEVE ganhar o card Rampage descrito na US4.
- **FR-011**: Os dados DEVEM funcionar offline, ter a fonte registrada e carregar de forma
  independente: uma falha nos dados de armaduras NÃO DEVE afetar Monstros nem Armas.
- **FR-012**: A navegação entre áreas e abas DEVE preservar o estado de cada uma (filtros, busca,
  posição, item aberto).
- **FR-013**: As telas novas DEVEM seguir a acessibilidade da constituição: sem cortes a 320 dp com
  texto a 200 %, contraste AA, alvos de toque de 48 dp e semântica (slots, níveis de habilidade,
  resistências).

### Key Entities *(include if feature involves data)*

- **Peça de Armadura**: um item vestível de uma parte do corpo; raridade, rank, defesa base,
  resistências, slots, habilidades com nível, materiais, conjunto.
- **Conjunto**: as peças que o jogo agrupa com o mesmo nome base (ex.: "Rathalos X").
- **Habilidade**: nome, descrição, nível máximo e efeito por nível.
- **Joia**: dá uma ou duas habilidades com nível; cabe num slot de nível igual ou maior.
- **Habilidade Rampage / Joia Rampage**: opções Rampage das armas (Baixo/Alto) e joias para o slot
  Rampage (Mestre).
- **Origem de Material**: a mesma da 006 (coleta, monstro grande ou pequeno, missão).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100 % das peças obteníveis das raridades 1 a 10 listadas na fonte estão no catálogo, e
  nenhuma peça cortada aparece.
- **SC-002**: Numa amostra de 20 peças (ao menos duas por raridade), defesa, resistências, slots,
  habilidades e materiais conferem com a fonte; e 10 habilidades e 10 joias conferem.
- **SC-003**: Um usuário encontra os conjuntos que dão uma habilidade em até 3 toques a partir da
  área Armaduras.
- **SC-004**: A lista de conjuntos de qualquer rank aparece em até 1 segundo e rola sem travar.
- **SC-005**: Com os dados de armaduras indisponíveis, 100 % dos cenários de Monstros e Armas
  continuam funcionando.
- **SC-006**: Nenhuma regressão nos cenários de aceitação das features 001 a 006.
- **SC-007**: Ao menos 90 % das peças têm ícone próprio, se a fonte fornecer; caso contrário, um
  ícone por parte do corpo.

## Assumptions

- A fonte é a Kiranico da Rise: Sunbreak (páginas em inglês e pt-BR), a mesma da 006; as origens dos
  materiais reaproveitam o que a 006 já extrai das páginas de item.
- A Kiranico dá só a defesa base de cada peça; a defesa máxima com melhorias fica de fora.
- Conjunto = peças com o mesmo nome base; quando o nome não permitir agrupar com segurança, a fonte
  de conjuntos da wiki é usada, e a regra fica documentada.
- Fora do escopo: talismãs, montagem e otimização de builds (008–009), armaduras em camadas,
  armaduras de World e Wilds, armaduras dos Amigos (Palico/Canyne).
- O visual segue a direção aprovada na 005 e o mockup desta feature (cards discretos, nunca
  aninhados, dourado como único destaque, IM Fell English SC, Averia Serif Libre, Atkinson
  Hyperlegible, ícones de slot do jogo).
