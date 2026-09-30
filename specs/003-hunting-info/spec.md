# Feature Specification: Informações de Caçada

**Feature Branch**: `003-hunting-info`

**Created**: 2026-09-30

**Status**: Draft

**Input**: User description: "Informações de caçada na página do monstro: mostrar o HP total do monstro caçando sozinho e em grupo (party de 2 a 4 caçadores), se o monstro enxerga ou não (ex.: afetado ou não por Flash Pod / bomba de luz, monstros cegos), se costuma aparecer em manada/grupo, e como reage a Sound Pod / Screamer Pod (bomba sônica), além de outras reações a itens de caça úteis (armadilhas, Dung Pod), para os monstros dos três jogos. Informações que não existirem no jogo ou na fonte devem aparecer como "não se aplica" ou "desconhecido", nunca inventadas."

## Clarifications

### Session 2026-09-30

- Q: Qual HP mostrar? → A: Um valor de referência por rank (Baixo/Alto/Mestre), solo e em grupo; missões especiais e eventos ficam de fora.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Saber quanto HP o monstro tem (Priority: P1)

Antes de sair para a caçada, o caçador quer saber quão resistente é o monstro: o HP total quando
caça sozinho e quando caça com amigos (2, 3 ou 4 caçadores), para planejar tempo, consumíveis e
se vale chamar ajuda.

**Why this priority**: é a informação numérica mais pedida e muda bastante entre caçar sozinho
e em grupo.

**Independent Test**: abrir o detalhe de um monstro e conferir o HP para 1 caçador e para
grupos, por rank, contra a fonte registrada.

**Acceptance Scenarios**:

1. **Given** o detalhe de um monstro, **When** o usuário vê a seção de HP, **Then** vê o HP
   total para caçada solo e para grupo, com um valor de referência por rank em que o monstro
   existe (Baixo, Alto, Mestre — conforme o jogo); missões especiais e eventos ficam de fora.
2. **Given** um jogo em que o HP de grupo é igual para 2, 3 e 4 caçadores, **When** a seção é
   exibida, **Then** mostra um único valor "Grupo (2–4)"; quando o jogo diferencia, mostra um
   valor por quantidade de caçadores.
3. **Given** um monstro que não existe em algum rank, **When** a seção é exibida, **Then** esse
   rank não aparece (nunca um HP vazio ou zero).

---

### User Story 2 - Como o monstro reage aos itens de caça (Priority: P2)

O caçador quer saber, de relance, se vale levar bombas de luz, bombas sônicas, bombas de esterco
e armadilhas: se o monstro enxerga (é afetado por luz), se reage a som, se cai em armadilhas.

**Why this priority**: evita desperdiçar itens e muda a estratégia (ex.: não usar Flash Pod em
monstro cego).

**Independent Test**: abrir o detalhe de monstros com reações diferentes (ex.: um cego e um que
reage a som) e conferir cada item contra a fonte.

**Acceptance Scenarios**:

1. **Given** o detalhe de um monstro, **When** o usuário vê a seção de itens de caça, **Then**
   vê, para cada item relevante do jogo (Flash Pod, Sound/Screamer Pod, Dung Pod, Armadilha de
   Fosso, Armadilha de Choque), se o monstro é afetado, não é afetado, ou se é desconhecido.
2. **Given** um monstro que não enxerga, **When** o detalhe é exibido, **Then** há a indicação
   clara "Não enxerga" e o Flash Pod aparece como "não afeta".
3. **Given** um item que não existe naquele jogo, **When** a seção é exibida, **Then** ele
   aparece como "não se aplica" ou é omitido — nunca como "afeta" ou "não afeta".
4. **Given** uma reação com efeito especial (ex.: o som só afeta quando o monstro está
   enterrado), **When** exibida, **Then** a condição aparece junto ("afeta quando enterrado").

---

### User Story 3 - Saber se o monstro anda em grupo (Priority: P3)

O caçador quer saber se o monstro costuma aparecer em manada ou acompanhado de outros da mesma
espécie, para não ser pego de surpresa.

**Why this priority**: útil, mas menos frequente e com menos dados disponíveis nas fontes.

**Independent Test**: abrir um monstro conhecido por andar em manada e um solitário e conferir a
indicação.

**Acceptance Scenarios**:

1. **Given** um monstro que aparece em manada, **When** o detalhe é exibido, **Then** mostra
   "Costuma aparecer em grupo".
2. **Given** um monstro sem informação na fonte, **When** o detalhe é exibido, **Then** mostra
   "Desconhecido".

---

### Edge Cases

- Monstros que só existem em arena ou missão especial: HP pode vir de uma única missão; indicar
  a origem do valor.
- HP que varia por missão (missões especiais, eventos): o valor de referência não inclui eventos.
- Reações que dependem de estado do monstro (enterrado, voando, enfurecido): mostrar a condição.
- Itens com nomes diferentes entre jogos (Sound Pod / Screamer Pod / Sonic Bomb): exibidos com o
  nome oficial em pt-BR do respectivo jogo quando houver.
- Dado ausente para um monstro: "Desconhecido"; item inexistente no jogo: "Não se aplica".
- Monstros que não podem ser capturados: Armadilhas aparecem como "não afeta" quando a fonte
  indicar.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O detalhe do monstro DEVE ter uma seção de HP com o HP total de referência de cada
  rank em que o monstro existe (Baixo, Alto, Mestre — conforme o jogo), para caçada solo e para
  grupo de caçadores. Missões especiais e eventos não entram no valor de referência.
- **FR-002**: Quando o jogo define o mesmo HP para 2, 3 e 4 caçadores, o app DEVE mostrar um
  único valor de grupo; quando define valores diferentes, DEVE mostrar um por quantidade.
- **FR-003**: O detalhe DEVE indicar se o monstro enxerga ("Enxerga" / "Não enxerga" /
  "Desconhecido").
- **FR-004**: O detalhe DEVE mostrar a reação do monstro a cada item de caça relevante do jogo
  (Flash Pod, Sound/Screamer Pod, Dung Pod, Armadilha de Fosso, Armadilha de Choque) com um de:
  "Afeta", "Não afeta", "Afeta com condição" (com a condição descrita), "Não se aplica" (item
  não existe no jogo) ou "Desconhecido".
- **FR-005**: O detalhe DEVE indicar se o monstro costuma aparecer em grupo ("Em grupo" /
  "Solitário" / "Desconhecido").
- **FR-006**: Nenhum valor desta feature pode ser inventado: sem fonte, o app mostra
  "Desconhecido"; a fonte de cada informação DEVE ficar registrada nos dados.
- **FR-007**: As novas seções DEVEM seguir a identidade visual "Caderno do Caçador" e as regras de
  acessibilidade existentes (contraste, alvos de toque, texto a 200%, rótulos para leitores de
  tela).
- **FR-008**: Todos os textos novos DEVEM estar em pt-BR; nomes de itens seguem a preferência de
  idioma dos nomes do jogo (pt-BR ou inglês), com a mesma regra de alternativa em inglês.
- **FR-009**: As funcionalidades existentes (lista, busca, filtros, idioma, layout adaptativo)
  DEVEM continuar funcionando como antes.

### Key Entities *(include if feature involves data)*

- **HP do Monstro**: HP total por rank (quando aplicável) e por quantidade de caçadores (1, ou
  grupo 2–4 / 2, 3, 4), com a origem do valor.
- **Reação a Item de Caça**: item (Flash Pod, Sound/Screamer Pod, Dung Pod, Armadilha de Fosso,
  Armadilha de Choque), efeito (afeta / não afeta / afeta com condição / não se aplica /
  desconhecido) e condição opcional.
- **Visão**: enxerga / não enxerga / desconhecido.
- **Comportamento em grupo**: em grupo / solitário / desconhecido.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Para 100% dos 30 monstros atuais, a seção de HP mostra valores que coincidem com a
  fonte registrada.
- **SC-002**: Para 100% dos 30 monstros, cada reação a item de caça é "Afeta", "Não afeta",
  "Afeta com condição", "Não se aplica" ou "Desconhecido", sem campos vazios, e cada valor
  diferente de "Desconhecido" tem fonte registrada.
- **SC-003**: Um usuário descobre se pode usar Flash Pod num monstro em menos de 10 segundos a
  partir da lista.
- **SC-004**: Nenhuma regressão: todos os cenários das features 001 e 002 continuam passando.

## Assumptions

- As informações vêm das mesmas fontes de referência da comunidade já usadas (bancos de dados e
  wikis dos jogos) e ficam registradas por monstro.
- A feature cobre os 30 monstros atuais; a ampliação para todos os monstros grandes (próxima
  feature) coletará estes campos junto.
- "Enxerga" é derivado da reação ao Flash Pod quando a fonte não tiver um campo próprio (um
  monstro que não é afetado por luz por ser cego é "Não enxerga"); quando o motivo não for
  cegueira, o app mostra apenas a reação ao item.
- HP de eventos e missões especiais não entra no valor de referência.
- Sem novas telas: as informações entram na página de detalhe existente.
