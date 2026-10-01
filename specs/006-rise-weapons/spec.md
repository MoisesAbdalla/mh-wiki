# Feature Specification: Armas da Rise: Sunbreak

**Feature Branch**: `006-rise-weapons`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "Setor de Armas da Rise: Sunbreak no app Caderninho, a primeira de uma
sequência (006 armas, 007 armaduras/habilidades/joias, 008 assistente com builds prontas e salvas,
009 otimizador, 010 IA opcional). Catálogo offline de todas as armas dos 14 tipos, com atributos,
slots, afiação, materiais, árvore de melhoria, ícone e o rank/estrelas em que cada arma fica
disponível; barra de navegação entre as áreas do app; lista agrupada por árvore; detalhe em cards
numerados; card 'Armas feitas com ele' no monstro."

**Reference**: mockup aprovado pelo usuário em [mockups/approved.html](mockups/approved.html)
(telas "Lista de armas", "Detalhe da arma" e "No detalhe do monstro"). Desenho discutido na sessão de
brainstorming de 2026-09-30/10-01 (roteiro 006→010; tudo offline e sem custo; IA opcional adiada).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consultar as armas de um tipo (Priority: P1)

O caçador abre a área Armas, escolhe o tipo de arma que usa (ex.: Grande Espada) e vê todas as armas
desse tipo na Rise: Sunbreak, agrupadas pelas árvores de melhoria, com ataque, elemento ou status e
afinidade à vista. Ele filtra pelo rank em que está e busca uma arma pelo nome.

**Why this priority**: é o catálogo em si; sem ele não há o que consultar nem o que o assistente
das features seguintes possa usar.

**Independent Test**: abrir Armas → Rise → Grande Espada; conferir que a árvore do Anjanath
aparece com as 6 armas em ordem de melhoria, com ataque/elemento/afinidade iguais aos da fonte;
filtrar por Master Rank e buscar "lohen".

**Acceptance Scenarios**:

1. **Given** o app aberto, **When** o usuário toca em "Armas" na barra de navegação, **Then** vê a
   área Armas com a Rise selecionada e o primeiro tipo de arma escolhido.
2. **Given** a área Armas, **When** o usuário escolhe um tipo de arma, **Then** a lista mostra todas
   as armas desse tipo, agrupadas por árvore, cada árvore num card, com as armas em ordem de
   melhoria e um recuo que indica o caminho.
3. **Given** a lista, **When** exibida, **Then** cada arma mostra nome, rank, ataque e, quando
   houver, elemento ou status (com símbolo e valor) e afinidade.
4. **Given** a lista, **When** o usuário escolhe um rank (Low, High ou Master), **Then** só aparecem
   as armas daquele rank, mantendo o agrupamento por árvore.
5. **Given** a lista, **When** o usuário digita parte de um nome (em português ou inglês, sem
   acentos), **Then** aparecem as armas cujo nome casa com o texto.
6. **Given** as abas de jogo da área Armas, **When** exibidas, **Then** World e Wilds aparecem
   indicadas como "em breve" e não podem ser escolhidas.

---

### User Story 2 - Ver tudo sobre uma arma (Priority: P2)

O caçador abre uma arma e vê, em cards numerados, seus atributos (ataque, elemento ou status,
afinidade, slots de joia e de Rampage com nível), a afiação normal e com Artesanato no máximo, os
materiais para criar ou melhorar (com o monstro que os dropa) e a posição da arma na árvore.

**Why this priority**: é o que o caçador consulta para decidir qual arma fazer e o que caçar para
isso.

**Independent Test**: abrir "Gnashing Flammenzahn+" e conferir ataque 280, Fogo 28, afinidade
−20 %, um slot de nível 3, slot Rampage de nível 2, as duas barras de afiação, os quatro materiais
com quantidades, "Dropados por: Anjanath" e a árvore anterior/esta/próxima.

**Acceptance Scenarios**:

1. **Given** uma arma, **When** o detalhe é aberto, **Then** aparecem os cards 1 Atributos,
   2 Afiação, 3 Materiais e 4 Árvore, nessa ordem.
2. **Given** uma arma com slots, **When** exibida, **Then** cada slot mostra seu nível (1 a 4) e o
   slot Rampage aparece separado, também com nível.
3. **Given** uma arma corpo a corpo, **When** exibida, **Then** a afiação aparece como duas barras
   coloridas (normal e com Artesanato no máximo); armas à distância não mostram o card de afiação.
4. **Given** uma arma que se melhora a partir de outra, **When** exibida, **Then** o card Materiais
   mostra os materiais de melhoria com quantidades; uma arma criada do zero mostra os materiais de
   criação.
5. **Given** um material que o app conhece de algum monstro, **When** exibido, **Then** há um link
   para o monstro que o dropa; tocar nele abre o detalhe desse monstro.
6. **Given** o card Árvore, **When** o usuário toca na arma anterior ou numa próxima, **Then** o
   detalhe passa para essa arma.
7. **Given** uma arma, **When** exibida, **Then** o rank e as estrelas em que ela fica disponível
   aparecem com a indicação de que são estimados.

---

### User Story 3 - Do monstro às armas e navegação entre áreas (Priority: P3)

O caçador, olhando um monstro, vê quais armas são feitas com os materiais dele e abre uma delas; e
alterna entre as áreas do app (Monstros, Armas) por uma barra de navegação, que já mostra as áreas
futuras (Armaduras, Assistente) desligadas.

**Why this priority**: liga o catálogo novo ao conteúdo que já existe e prepara o app para as
próximas features; depende das duas primeiras histórias.

**Independent Test**: abrir o Anjanath (Rise) e ver o card "Armas feitas com ele" com a contagem e
as primeiras armas; tocar numa e chegar ao detalhe dela; voltar para Monstros pela barra.

**Acceptance Scenarios**:

1. **Given** um monstro da Rise cujos materiais são usados em armas, **When** o detalhe é aberto,
   **Then** aparece um card "Armas feitas com ele" com a quantidade de armas e uma lista resumida
   (nome, tipo, rank), com a opção de ver todas.
2. **Given** um monstro de World ou Wilds, ou um monstro sem armas, **When** o detalhe é aberto,
   **Then** o card "Armas feitas com ele" não aparece.
3. **Given** qualquer tela principal, **When** exibida, **Then** há uma barra de navegação com
   Monstros, Armas, Armaduras e Assistente; Armaduras e Assistente aparecem desligadas, com a
   indicação de que ainda virão, e não podem ser abertas.
4. **Given** uma tela larga, **When** exibida, **Then** a navegação entre áreas aparece como uma
   coluna lateral em vez de barra inferior.
5. **Given** o usuário em Armas, **When** volta para Monstros, **Then** encontra a lista de monstros
   como a deixou (filtro, busca e posição).

---

### User Story 4 - Dados próprios de cada tipo de arma (Priority: P4)

Adicionada após a revisão do usuário (2026-10-01, mockup `mockups/approved-sources.html`, opção B).
O caçador vê no detalhe o que muda o jeito de jogar com aquele tipo: o frasco da Lâmina Dínamo e do
Machado-Espada, os projéteis da Lançarma, o nível do inseto do Glaive, as músicas do Berrante, os
disparos e revestimentos do Arco e as munições dos Fuzilarcos.

**Why this priority**: decide entre armas parecidas (ex.: Lâmina Dínamo de Impacto ou de Elemento),
mas o catálogo já é útil sem isso.

**Independent Test**: abrir uma Lâmina Dínamo, uma Lançarma, um Berrante, um Arco e um Fuzilarco e
conferir os valores com a Kiranico.

**Acceptance Scenarios**:

1. **Given** uma Lâmina Dínamo ou um Machado-Espada, **When** o usuário abre o detalhe, **Then** o
   card Atributos mostra o frasco (ex.: "Frasco de Impacto") como mais um valor da grade.
2. **Given** uma Lançarma, um Glaive Inseto ou um Berrante, **When** aberto, **Then** a grade mostra
   os projéteis (tipo e nível), o nível do inseto ou as três músicas.
3. **Given** um Arco ou um Fuzilarco, **When** aberto, **Then** um card próprio "Munição" mostra os
   disparos por carga, o tiro de arco e os revestimentos (Arco), ou o desvio, o recuo, a recarga e a
   tabela de munições com a capacidade por nível (Fuzilarcos).

---

### User Story 5 - De onde vem cada material (Priority: P5)

Adicionada após a revisão do usuário (mesmo mockup, opção B). Além dos monstros grandes, o caçador
vê onde coletar minérios e outros itens, de que monstro pequeno vem um material e que missão dá um
ticket, no rank da arma.

**Why this priority**: muitas armas pedem minérios e materiais de monstros pequenos; sem isso o
caçador precisa sair do app para saber onde consegui-los.

**Independent Test**: abrir a Lâmina D. Kamura V e conferir as origens de cada material com as
páginas de item da Kiranico.

**Acceptance Scenarios**:

1. **Given** um material de coleta, **When** o detalhe é aberto, **Then** o material mostra um selo
   "Coleta · N mapas" (ou o nome do mapa, se for um só) no rank da arma.
2. **Given** um material de monstro, **When** aberto, **Then** monstros grandes aparecem como selo
   com link para o monstro e monstros pequenos como selo "<monstro> · pequeno", sem link.
3. **Given** um material que vem de missão, **When** aberto, **Then** um selo mostra o tipo e as
   estrelas da missão (ex.: "Missão · Evento 8★").
4. **Given** um material com origens, **When** o usuário toca nele, **Then** abre a lista completa:
   mapas com a chance de coleta, monstros com o modo de obtenção e a chance, e missões, no rank da
   arma.
5. **Given** um material sem origem nas fontes (ex.: resíduos), **When** aberto, **Then** mostra
   "Origem desconhecida" em vez de inventar uma.

---

### Edge Cases

- Itens que o jogo não permite obter (dados zerados, como "Stuffed Rathalos") não aparecem.
- Arma sem elemento ou status: a lista e o detalhe não mostram esse campo, em vez de mostrar "0".
- Arma com dois atributos especiais (ex.: elemento e status) mostra os dois.
- Material sem monstro conhecido no app (minério, item de mercado, material de outra arma): aparece
  sem link, com as origens de coleta e missão quando houver.
- Material que só existe em outro rank que o da arma: as origens desse rank aparecem, com o rank
  indicado.
- Ícone ausente: marcador padrão no mesmo espaço.
- Árvore com ramificação (uma arma que leva a duas ou mais): todas as próximas aparecem no card
  Árvore, e a lista mostra os ramos com recuo.
- Busca sem resultado e filtro de rank vazio: mensagem explicando, com opção de limpar o filtro.
- Falha ao carregar os dados de armas: só a área Armas e o card "Armas feitas com ele" mostram o
  erro; a área Monstros funciona normalmente.
- Nomes longos e texto a 200 % em telas de 320 dp: sem cortes nem sobreposição; o seletor de tipos e
  a barra de navegação continuam utilizáveis.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O app DEVE ter uma navegação entre áreas (Monstros, Armas, Armaduras, Assistente):
  barra inferior em telas estreitas e coluna lateral em telas largas. Armaduras e Assistente DEVEM
  aparecer desligadas, indicadas como futuras, até as features que as criam.
- **FR-002**: A área Armas DEVE mostrar as abas de jogo com os logos; somente a Rise: Sunbreak tem
  armas nesta feature, e World e Wilds DEVEM aparecer como "em breve", sem poder ser escolhidas.
- **FR-003**: O catálogo DEVE conter todas as armas obteníveis dos 14 tipos da Rise: Sunbreak, de Low
  a Master Rank; itens que o jogo não permite obter DEVEM ficar de fora.
- **FR-004**: Cada arma DEVE ter: nome em português e inglês (português com alternativa em inglês,
  respeitando a preferência de idioma dos nomes já existente), tipo, raridade, ataque, elemento ou
  status com valor (quando houver), afinidade, slots de joia com nível, slot Rampage com nível,
  afiação normal e com Artesanato no máximo (armas corpo a corpo), descrição, ícone, materiais de
  criação e/ou de melhoria com quantidades, arma anterior e próximas na árvore.
- **FR-005**: Cada arma DEVE ter o rank e as estrelas de missão em que fica disponível, estimados
  pelo material mais avançado exigido e pela missão de menor estrela em que o monstro que o dropa
  aparece; esse valor DEVE ser marcado como estimado, com a regra documentada.
- **FR-006**: A área Armas DEVE permitir escolher um dos 14 tipos num seletor que rola na
  horizontal, filtrar por rank (Todos, Low, High, Master) e buscar por nome (português ou inglês,
  sem diferenciar acentos e maiúsculas).
- **FR-007**: A lista DEVE agrupar as armas por árvore de melhoria, uma árvore por card, com as armas
  em ordem de melhoria e recuo indicando o caminho; cada arma mostra nome, rank, ataque, elemento ou
  status e afinidade.
- **FR-008**: O detalhe da arma DEVE mostrar os cards numerados 1 Atributos, 2 Afiação (só armas
  corpo a corpo), 3 Materiais e 4 Árvore, no estilo Caderninho (feature 005).
- **FR-009**: Materiais ligados a monstros conhecidos DEVEM levar ao detalhe do monstro que os dropa;
  armas no card Árvore DEVEM levar ao detalhe da arma.
- **FR-010**: O detalhe de um monstro da Rise DEVE mostrar o card "Armas feitas com ele" quando houver
  armas que usam seus materiais, com a quantidade, uma lista resumida e acesso a todas.
- **FR-011**: Os dados de armas DEVEM funcionar offline, ter a origem registrada (fonte por arma e
  regra do rank estimado) e ser carregados de forma independente: uma falha neles NÃO DEVE afetar a
  área Monstros.
- **FR-012**: A navegação entre áreas DEVE preservar o estado de cada área (filtros, busca, posição
  da lista, item selecionado).
- **FR-013**: O app DEVE manter a acessibilidade da constituição em todas as telas novas: sem cortes
  a 320 dp com texto a 200 %, contraste AA, alvos de toque de 48 dp e semântica para leitores de
  tela (navegação, abas, tipos de arma, atributos, slots, afiação).
- **FR-014**: Cada arma DEVE ter os dados próprios do seu tipo, com os nomes oficiais em pt-BR e en:
  frasco (Lâmina Dínamo, Machado-Espada), projéteis (Lançarma), nível do inseto (Glaive Inseto),
  músicas (Berrante), tiro de arco, disparos por carga e revestimentos (Arco), desvio, recuo, recarga
  e munições com capacidade por nível (Fuzilarcos).
- **FR-015**: Cada material DEVE ter as origens registradas na fonte, por rank: coleta (mapa e
  chance), monstros (grandes e pequenos, modo de obtenção e chance) e missões (tipo, estrelas e
  nome). O detalhe mostra as do rank da arma; se não houver, as do rank mais próximo, indicado.

### Key Entities *(include if feature involves data)*

- **Arma**: um item do catálogo de um jogo; tipo, raridade, atributos (ataque, elemento ou status,
  afinidade), slots, slot Rampage, afiação, descrição, ícone, rank/estrelas estimados, fontes.
- **Tipo de Arma**: um dos 14 tipos (Grande Espada, Espada Longa, Espada e Escudo, Lâminas Duplas,
  Martelo, Berrante, Lança, Lança-Canhão, Espada-Machado, Lâmina Carregada, Glaive Inseto, Arco,
  Besta Pesada, Besta Leve).
- **Árvore de Melhoria**: o encadeamento de armas por melhoria (anterior → próximas), com
  ramificações.
- **Custo de Material**: um material e a quantidade exigida para criar ou melhorar uma arma; liga-se
  ao material e aos monstros que o dropam, quando conhecidos.
- **Origem de Material**: de onde um material vem num rank: um mapa de coleta, um monstro (grande ou
  pequeno) ou uma missão, com a chance quando a fonte a informa.
- **Área do App**: Monstros, Armas, Armaduras, Assistente; cada uma com seu próprio estado.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100 % das armas obteníveis dos 14 tipos da Rise: Sunbreak listadas na fonte estão no
  catálogo, e nenhum item não obtenível aparece.
- **SC-002**: Numa amostra de 20 armas (ao menos uma por tipo), ataque, elemento ou status,
  afinidade, slots, materiais e árvore batem com a fonte em 100 % dos campos.
- **SC-003**: Um usuário encontra uma arma conhecida (ex.: a melhor Grande Espada do Anjanath) e vê
  seus materiais em menos de 20 segundos a partir da tela inicial.
- **SC-004**: A lista de qualquer tipo de arma aparece em até 1 segundo e rola sem travar.
- **SC-005**: Com os dados de armas indisponíveis, 100 % dos cenários da área Monstros continuam
  funcionando.
- **SC-006**: Nenhuma regressão: todos os cenários de aceitação das features 001 a 005 continuam
  passando.
- **SC-007**: Ao menos 95 % das armas têm ícone próprio.

## Assumptions

- A fonte é a Kiranico da Rise: Sunbreak (páginas em inglês e português), a mesma usada para os
  monstros; os ícones também vêm de lá. Como nas features anteriores, as imagens são arte da Capcom
  usada localmente num projeto pessoal de estudo.
- A Kiranico não informa em que missão cada arma é liberada; por isso o rank/estrelas é uma
  estimativa documentada. O seletor de progresso da feature 008 usará esse valor.
- Os nomes dos tipos de arma em português seguem os nomes oficiais do jogo em pt-BR quando a fonte os
  tiver; caso contrário, os usados pela comunidade.
- Fora do escopo: habilidades Rampage de cada arma (entram na 007, junto com habilidades e joias);
  páginas de monstros pequenos; armas de World e Wilds; armaduras; o assistente e o otimizador (008–009); IA (010, opcional e adiada).
- O visual segue a direção aprovada na feature 005 (cards discretos, nunca um dentro do outro,
  dourado como único destaque, IM Fell English SC, Averia Serif Libre, Atkinson Hyperlegible).
