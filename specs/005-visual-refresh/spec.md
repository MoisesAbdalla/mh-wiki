# Feature Specification: Renovação Visual "Caderninho"

**Feature Branch**: `005-visual-refresh`

**Created**: 2026-09-30

**Status**: Draft

**Input**: User description: "Renovação visual do app ("Caderninho") para deixar de parecer feito por
IA, seguindo a skill frontend-design do Tech Leads Club e a direção validada pelo usuário em
mockups: tema escuro com a paleta atual e o dourado como único acento, nome "Caderninho", logos
oficiais dos jogos como abas, layout editorial sem cards, IM Fell English SC nos títulos, Averia
Serif Libre nos números, Atkinson Hyperlegible no texto, fraquezas com símbolo do elemento e
estrelas, régua de HP, transições curtas; acessibilidade, dados e comportamento inalterados."

**Reference**: mockup aprovado pelo usuário em [mockups/approved.html](mockups/approved.html)
(telas "Lista", "Detalhe" do Rathalos e "Versão" do Arch-Tempered Nergigante, abas da "Opção 2").
As outras direções avaliadas estão em [mockups/directions.html](mockups/directions.html) e a
comparação de fontes em [mockups/fonts.html](mockups/fonts.html).

**Revision (2026-09-30, after the US1 review)**: the user asked to keep cards to separate each
monster in the list and each section of the detail. The approved revision is
[mockups/cards.html](mockups/cards.html): one card per list row and per detail section, with a
subtle bronze edge and slightly lighter background, and ruled rows inside. Cards are never nested.
FR-003 and SC-002 below reflect it.

**Supersedes** (feature 002): a grade de cinco cards de fraqueza (FR-006), as molduras e painéis
emoldurados (FR-002), as fontes de inscrição anteriores e os separadores ornamentais do filtro
"Todos" (FR-010). As demais regras da 002 (tema escuro fixo, miniaturas, regra da fraqueza
principal da lista, acessibilidade) continuam valendo.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Um caderno, não um template (Priority: P1)

O caçador abre o app e o reconhece como um caderno de anotações desenhado para Monster Hunter,
não como um app genérico: o nome "Caderninho" no topo, fundo escuro com um único acento dourado,
títulos numa letra de impressão antiga, números numa serifa macia, e as informações dispostas como
páginas de um caderno: cada monstro e cada seção no seu card discreto, com o conteúdo em linhas
com fios finos, sem molduras douradas nem cards dentro de cards.

**Why this priority**: é a mudança que o usuário pediu (menos "cara de IA") e alcança todas as
telas; as outras histórias refinam partes específicas.

**Independent Test**: navegar por lista, detalhe e configurações (celular e tela larga) e
comparar com o mockup aprovado: marca, paleta, tipografia, cards discretos (sem card dentro de card), seções numeradas e
abas sublinhadas.

**Acceptance Scenarios**:

1. **Given** qualquer tela, **When** o app é aberto, **Then** o topo mostra "Caderninho" (e não
   mais "MH Wiki" / "Caderno do Caçador").
2. **Given** a lista de monstros, **When** exibida, **Then** cada monstro aparece no seu próprio
   card, no novo estilo (borda bronze sutil, sem moldura dourada); o selecionado tem borda dourada.
3. **Given** o detalhe de um monstro, **When** exibido, **Then** cada seção aparece no seu card,
   numerada (1 Fraquezas, 2 Vida, 3 Itens de caça, 4 Materiais, e as demais seções existentes em
   seguida), com o conteúdo em linhas com fios finos e sem card dentro de card.
4. **Given** qualquer tela, **When** exibida, **Then** títulos (marca, abas, nomes de monstros,
   títulos de seção) usam a letra de impressão antiga, números (HP, porcentagens, numeração das
   seções, contagens) usam a serifa macia e o texto corrido usa a letra de alta legibilidade.
5. **Given** um monstro com versões, **When** o detalhe é exibido, **Then** o seletor de versões
   aparece como abas de texto sublinhadas (a ativa sublinhada em dourado), e não como blocos
   preenchidos.
6. **Given** o detalhe numa tela em que a aba do jogo já está visível, **When** exibido, **Then**
   o nome do jogo não se repete acima do nome do monstro.
7. **Given** uma versão que herda seções da forma base, **When** exibida, **Then** a indicação
   "igual à forma base" aparece como nota discreta junto ao título da seção, uma vez por seção.

---

### User Story 2 - Ler fraquezas e vida de relance (Priority: P2)

O caçador descobre em um olhar contra o que atacar e quanto de vida o monstro tem: as fraquezas
aparecem da melhor para a pior, cada uma com o símbolo e a cor do elemento e de zero a três
estrelas, com a melhor destacada em dourado e um carimbo "Melhor"; a vida mostra o valor solo em
destaque e uma régua com as estimativas para 2 e 3–4 caçadores no mesmo eixo.

**Why this priority**: são as duas informações mais consultadas no meio de uma caçada; a nova
forma substitui a grade de cards idênticos, que era um dos sinais de "feito por IA".

**Independent Test**: abrir monstros com perfis diferentes (Rathalos, um monstro sem fraqueza de
2 estrelas, um com imunidade, um com empate na melhor fraqueza, um sem HP) e conferir a ordem, os
símbolos, as estrelas, o carimbo e a régua.

**Acceptance Scenarios**:

1. **Given** o detalhe do Rathalos (World), **When** exibido, **Then** as fraquezas aparecem na
   ordem Dragão (3 estrelas, em dourado, com carimbo "Melhor"), Raio (2), Água (1), Gelo (1) e
   Fogo por último, indicado como sem efeito em texto.
2. **Given** qualquer fraqueza, **When** exibida, **Then** mostra o símbolo do elemento na cor do
   elemento e três posições de estrela, com as estrelas vazias em tom apagado.
3. **Given** um monstro sem nenhuma fraqueza de 2 estrelas ou mais, **When** exibido, **Then**
   nenhuma fraqueza recebe o destaque dourado nem o carimbo, e a lista não mostra fraqueza
   principal (regra atual mantida).
4. **Given** empate na melhor fraqueza (2 estrelas ou mais), **When** exibido, **Then** todas as
   empatadas recebem o destaque dourado e o carimbo.
5. **Given** a lista, **When** um item tem fraqueza principal, **Then** ela aparece com o símbolo
   do elemento e o nome do elemento (regra atual de escolha mantida).
6. **Given** um monstro com HP em mais de um rank, **When** a seção Vida é exibida, **Then** há um
   seletor de rank; o rank escolhido mostra o HP solo em destaque e a régua com as marcas de 1, 2
   e 3–4 caçadores com seus valores.
7. **Given** um monstro com HP num único rank, **When** exibido, **Then** o seletor de rank não
   aparece e o rank é indicado junto ao valor.
8. **Given** um HP marcado como "a partir de" (menor valor das missões), **When** exibido,
   **Then** essa indicação continua visível junto ao valor solo.
9. **Given** um monstro ou versão sem HP conhecido, **When** exibido, **Then** a seção Vida mostra
   "HP desconhecido" sem régua.

---

### User Story 3 - Jogos pelos logos e trocas suaves (Priority: P3)

O caçador troca de jogo tocando no logo oficial do jogo (World: Iceborne, Rise: Sunbreak, Wilds)
e, ao trocar de jogo, monstro ou versão, o conteúdo entra com uma transição curta e suave em vez de
aparecer de uma vez.

**Why this priority**: reforça a identidade e o acabamento; depende do novo visual da US1, mas não
é necessário para ler as informações.

**Independent Test**: tocar em cada aba de jogo e conferir logo, estados ativo/inativo e leitura
por leitor de tela; trocar de monstro e de versão e observar a transição; ativar "reduzir
movimento" no sistema e verificar que a transição some.

**Acceptance Scenarios**:

1. **Given** a barra de jogos, **When** exibida, **Then** "Todos" aparece em texto e cada jogo
   aparece com seu logo oficial com cerca de 46 px de altura; as abas inativas ficam apagadas e a
   ativa aparece em cor cheia com sublinhado dourado.
2. **Given** um leitor de tela, **When** o foco passa por uma aba de logo, **Then** é anunciado o
   nome do jogo ("World: Iceborne", "Rise: Sunbreak", "Wilds") e se a aba está selecionada.
3. **Given** um logo que não pode ser exibido, **When** a barra aparece, **Then** a aba mostra o
   nome do jogo em texto no mesmo lugar.
4. **Given** a troca de monstro, versão ou jogo, **When** acontece, **Then** o novo conteúdo entra
   com uma transição de esmaecer e leve deslizamento de no máximo 300 ms.
5. **Given** a opção de reduzir movimento ativada no sistema, **When** o usuário troca de monstro,
   versão ou jogo, **Then** o conteúdo troca sem animação.

---

### Edge Cases

- Nomes longos (ex.: "Arch-Tempered Nergigante", "Risen Crimson Glow Valstrax") e texto ampliado a
  200% em telas de 320 dp: quebram linha sem cortar nem sobrepor; o carimbo "Melhor" e as estrelas
  continuam visíveis.
- A barra de jogos em 320 dp ou com texto ampliado: os três logos e "Todos" cabem ou passam para
  uma rolagem horizontal legível, sem reduzir os logos a ponto de ficarem ilegíveis.
- Filtro "Todos": o cabeçalho de cada jogo na lista identifica o jogo (logo ou nome) no novo
  estilo, sem os separadores ornamentais antigos.
- Imunidade a um elemento continua distinta de "0 estrelas" (texto em vez de estrelas).
- Sem estimativas de grupo para o jogo: a régua mostra só o valor solo, sem marcas vazias.
- Versão com seção herdada e sem dado próprio de HP/materiais: nota discreta "igual à forma base"
  nas seções herdadas e "desconhecido"/"sem materiais" nas demais, como hoje.
- Estados de carregamento, lista vazia (busca sem resultado) e erro: seguem o novo estilo, sem
  cards.
- Configurações: segue o novo estilo (títulos, fios, abas/opções sem blocos preenchidos).
- Miniatura ausente: o marcador continua ocupando o mesmo espaço, no novo estilo.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O topo do app DEVE exibir o nome "Caderninho", substituindo "MH Wiki" e o subtítulo
  "Caderno do Caçador".
- **FR-002**: O app DEVE continuar sempre no tema escuro, com a paleta atual (fundo marrom-escuro,
  texto creme, texto secundário bege, fios em bronze) e um único acento: o dourado, usado apenas
  para estado ativo/selecionado e destaques (aba ativa, item selecionado, melhor fraqueza,
  marcador do HP solo, numeração das seções, carimbo).
- **FR-003**: Cada monstro da lista e cada seção do detalhe (e de configurações) DEVE ser um card
  próprio no novo estilo (fundo um pouco mais claro que a página, borda bronze sutil, cantos
  levemente arredondados, sem moldura dourada; o selecionado com borda dourada). Dentro de um card
  o conteúdo DEVE usar linhas separadas por fios finos; NÃO DEVE haver card dentro de card. Os
  estados de carregamento, vazio e erro NÃO DEVEM usar painéis.
- **FR-004**: As seções do detalhe DEVEM ser numeradas na ordem em que aparecem, começando por
  1 Fraquezas, 2 Vida, 3 Itens de caça, 4 Materiais, seguidas das demais seções existentes.
- **FR-005**: A tipografia DEVE usar três famílias, todas de licença livre e empacotadas no app
  (funcionam offline): uma letra de impressão antiga em versalete para títulos (marca, abas de
  texto, nomes de monstros, títulos de seção, carimbo), uma serifa macia para números (HP, valores
  da régua, porcentagens, numeração das seções, contagens) e uma letra de alta legibilidade para o
  texto corrido. As fontes anteriores DEVEM deixar de ser usadas.
- **FR-006**: As abas de jogo DEVEM mostrar "Todos" em texto e, para cada jogo, o logo oficial do
  jogo com cerca de 46 px de altura; a aba ativa DEVE aparecer em cor cheia com sublinhado dourado
  e as inativas apagadas.
- **FR-007**: Cada aba de logo DEVE ter rótulo de acessibilidade com o nome do jogo e o estado de
  seleção, e DEVE cair para o nome do jogo em texto se o logo não puder ser exibido.
- **FR-008**: As abas de versão do detalhe DEVEM ser abas de texto sublinhadas (a ativa em
  dourado), sem blocos preenchidos.
- **FR-009**: O detalhe NÃO DEVE repetir o nome do jogo acima do nome do monstro quando o jogo já
  está indicado pela aba ativa ou pelo contexto da tela; a indicação de seção herdada DEVE ser uma
  nota discreta junto ao título da seção.
- **FR-010**: As fraquezas DEVEM ser exibidas em linhas ordenadas da mais para a menos eficaz
  (empates na ordem Fogo, Água, Raio, Gelo, Dragão; imunidades por último), cada linha com o
  símbolo do elemento na cor do elemento, o nome do elemento e de zero a três estrelas, com as
  estrelas vazias em tom apagado; imunidade DEVE aparecer em texto.
- **FR-011**: A(s) melhor(es) fraqueza(s) com 2 estrelas ou mais DEVEM ter as estrelas em dourado
  e o carimbo "Melhor"; sem fraqueza de 2 estrelas ou mais, nenhuma linha recebe o destaque.
- **FR-012**: A fraqueza principal de cada item da lista DEVE ser exibida com o símbolo do
  elemento e o nome do elemento, mantendo a regra atual de escolha (2 estrelas ou mais; empates na
  ordem Fogo, Água, Raio, Gelo, Dragão).
- **FR-013**: A seção Vida DEVE mostrar o HP solo em destaque e, quando houver estimativas de
  grupo, uma régua horizontal com as marcas de 1, 2 e 3–4 caçadores e seus valores no mesmo eixo,
  com a marca solo no acento dourado; com mais de um rank, DEVE haver um seletor de rank; as
  indicações "a partir de" e "HP desconhecido" existentes DEVEM ser mantidas.
- **FR-014**: Os materiais DEVEM ser exibidos em tabelas com fios finos, agrupados por método
  (e rótulo do método, quando houver), com a taxa alinhada à direita.
- **FR-015**: A troca de monstro, versão e jogo DEVE ter uma transição de esmaecer e leve
  deslizamento de no máximo 300 ms, sem efeito de quique; com "reduzir movimento" ativado no
  sistema, a troca DEVE acontecer sem animação.
- **FR-016**: Todas as cores de texto e de ícones informativos DEVEM ter contraste medido e
  documentado: pelo menos 4,5:1 para texto normal e 3:1 para texto grande e ícones sobre o fundo
  em que aparecem.
- **FR-017**: O app DEVE continuar sem cortes ou sobreposição em telas de 320 dp com texto
  ampliado a 200%, com alvos de toque de pelo menos 48 dp e semântica de leitor de tela para abas,
  fraquezas (elemento e número de estrelas) e HP.
- **FR-018**: Dados, busca, filtros, idioma dos nomes, seleção de versões e layout adaptativo
  (lista e detalhe lado a lado em telas largas) DEVEM continuar funcionando exatamente como antes;
  a feature altera apenas a apresentação.
- **FR-019**: A origem dos logos dos jogos DEVE ficar registrada junto às demais fontes do app.

### Key Entities *(include if feature involves data)*

- **Logo do Jogo**: imagem oficial de cada jogo usada na aba correspondente, com nome acessível e
  origem registrada; opcional (há alternativa em texto).
- **Estilo do Elemento**: símbolo e cor de cada um dos cinco elementos (os atuais), usados na lista
  e no detalhe.
- **Tema "Caderninho"**: paleta escura atual com acento dourado único, três famílias tipográficas,
  fios, espaçamentos e a transição padrão.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em comparação lado a lado com o mockup aprovado, lista, detalhe e versão apresentam
  os mesmos elementos: marca "Caderninho", logos nas abas, seções numeradas em cards discretos com linhas de fios finos,
  fraquezas com símbolo e estrelas, carimbo "Melhor", régua de HP e as três fontes.
- **SC-002**: Cada monstro da lista e cada seção do detalhe aparecem num único card, e nenhuma
  tela contém card dentro de card.
- **SC-003**: 100% das cores de texto atingem contraste de 4,5:1 (3:1 para texto grande e ícones)
  sobre o fundo em que aparecem, com os valores documentados.
- **SC-004**: Um usuário identifica a melhor fraqueza e o HP solo de um monstro no detalhe em
  menos de 3 segundos.
- **SC-005**: Um usuário reconhece o jogo de cada aba pelo logo sem ler texto, nos três jogos.
- **SC-006**: A lista com 300 ou mais entradas continua abrindo em até 1 segundo e rolando sem
  travamentos, como na feature 004.
- **SC-007**: Nenhuma regressão: todos os cenários de aceitação das features 001 a 004 continuam
  passando, exceto os visuais substituídos listados em "Supersedes".
- **SC-008**: Com "reduzir movimento" ativado, nenhuma transição animada acontece.

## Assumptions

- O visual segue a skill `frontend-design` do Tech Leads Club (instalada em
  `.claude/skills/frontend-design`) e a direção validada pelo usuário no mockup aprovado;
  mudanças de estilo além do mockup exigem nova validação visual.
- As famílias escolhidas são IM Fell English SC (títulos), Averia Serif Libre (números) e Atkinson
  Hyperlegible (texto), todas com licença livre (OFL) e suporte aos acentos do português.
- Os logos oficiais dos jogos são arte da Capcom, obtidos da Monster Hunter Wiki, e são usados
  localmente, como as miniaturas dos monstros, por se tratar de projeto pessoal/de estudo sem
  publicação em lojas (decisão da feature 001).
- Os símbolos dos elementos são os ícones já usados pelo app; as cores dos elementos e da paleta
  são as atuais, reajustadas apenas se a medição de contraste exigir.
- A régua de HP usa os mesmos fatores de grupo já existentes por jogo; não há dados novos.
- O idioma da interface continua pt-BR, com os textos novos ("Melhor", rótulos das abas de logo)
  vindos dos recursos de localização.
- Fora do escopo: tema claro, novas informações de monstros, novas telas, sons, ilustrações
  grandes dos monstros.
