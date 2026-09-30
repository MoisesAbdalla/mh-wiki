# Feature Specification: Identidade Visual "Caderno do Caçador"

**Feature Branch**: `002-visual-identity`

**Created**: 2026-09-29

**Status**: Draft

**Input**: User description: "Identidade visual do app (direção "Caderno do Caçador"): aplicar em todas as telas o visual inspirado na interface dos jogos Monster Hunter escolhido no protótipo A — tema escuro fixo (não segue o tema do sistema), fundo couro escuro, detalhes dourados, títulos em fonte com cara de inscrição, molduras e separadores ornamentais, fraquezas elementais em grade com ícone e cor por elemento destacando a maior fraqueza, principal fraqueza visível em cada item da lista, habitat e partes lado a lado com etiqueta "cortável", filtros de jogo como abas. Cada monstro deve exibir sua miniatura desenhada (os ícones do caderno de caça dos jogos) ao lado do nome na lista e em destaque no detalhe, para os 30 monstros das três versões; sem miniatura, mostrar um marcador no mesmo estilo."

**Reference**: protótipo A ("Caderno do Caçador") aprovado pelo usuário no canvas
"MH Wiki — Direções de Design" (telas "A · Lista" e "A · Detalhe (Rathalos)").

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reconhecer os monstros pela miniatura (Priority: P1)

O caçador percorre a lista e reconhece cada monstro pela miniatura desenhada que já conhece dos
jogos, sem precisar ler o nome. No detalhe, a miniatura aparece em destaque junto ao nome.

**Why this priority**: é o pedido mais explícito do usuário e o que mais aumenta a identificação
visual; funciona mesmo antes do restante da identidade visual.

**Independent Test**: abrir a lista e verificar que cada um dos 30 monstros exibe sua própria
miniatura ao lado do nome; abrir o detalhe de um monstro e ver a miniatura em destaque.

**Acceptance Scenarios**:

1. **Given** a lista com os três jogos, **When** o usuário a percorre, **Then** cada monstro exibe
   ao lado do nome a miniatura correspondente ao seu jogo (ex.: o Rathalos de World e o de Wilds
   mostram cada um a miniatura do seu jogo).
2. **Given** um monstro, **When** o usuário abre o detalhe, **Then** a miniatura aparece em tamanho
   maior, emoldurada, ao lado do nome e da classificação.
3. **Given** um monstro sem miniatura disponível, **When** ele aparece na lista ou no detalhe,
   **Then** é exibido um marcador no mesmo estilo visual (moldura e cores), sem espaço vazio nem
   imagem quebrada.

---

### User Story 2 - Visual do caderno do caçador em todo o app (Priority: P2)

O caçador usa o app e sente que está consultando o caderno de caça do jogo: fundo escuro de couro,
detalhes dourados, títulos em fonte de inscrição, molduras e separadores ornamentais, em todas as
telas (lista, detalhe, configurações) e em todos os tamanhos de tela.

**Why this priority**: define a identidade do app; depende de nada além do que já existe, mas é
mais amplo que as miniaturas.

**Independent Test**: navegar por lista, detalhe e configurações em celular e em tela larga, com o
sistema do aparelho em modo claro e em modo escuro, e verificar que o visual é sempre o mesmo tema
escuro com os elementos da direção A.

**Acceptance Scenarios**:

1. **Given** o aparelho em modo claro, **When** o app é aberto, **Then** o app aparece no tema
   escuro "Caderno do Caçador" (o tema não acompanha o sistema).
2. **Given** qualquer tela do app, **When** exibida, **Then** usa o fundo escuro, os títulos de
   seção em fonte de inscrição em dourado, e molduras/separadores no estilo do protótipo A.
3. **Given** a lista no filtro "Todos", **When** exibida, **Then** cada jogo tem seu cabeçalho com
   separador ornamental (linhas dos dois lados do nome do jogo).
4. **Given** a tela larga (lista e detalhe lado a lado), **When** exibida, **Then** os dois painéis
   seguem o mesmo visual.

---

### User Story 3 - Informação mais rápida de ler (Priority: P3)

O caçador vê na própria lista a principal fraqueza de cada monstro e, no detalhe, lê as fraquezas
numa grade de cinco elementos com ícone e cor próprios, com a maior fraqueza destacada; habitat e
partes aparecem lado a lado, com a etiqueta "cortável" nas partes que podem ser cortadas.

**Why this priority**: melhora a leitura das informações já existentes; não é pré-requisito das
outras histórias.

**Independent Test**: na lista, conferir que cada item mostra a principal fraqueza do monstro; no
detalhe, conferir a grade de elementos, o destaque da maior fraqueza, o bloco habitat/partes e a
etiqueta "cortável".

**Acceptance Scenarios**:

1. **Given** a lista, **When** exibida, **Then** cada item mostra a principal fraqueza do monstro
   (nome do elemento e sua cor), seguindo a mesma regra de destaque do detalhe.
2. **Given** um monstro sem fraqueza de 2 estrelas ou mais, **When** aparece na lista, **Then** o
   item não mostra fraqueza principal (em vez de mostrar um elemento pouco eficaz como principal).
3. **Given** o detalhe, **When** exibido, **Then** as cinco fraquezas aparecem lado a lado em
   grade, cada uma com ícone e cor do seu elemento, e a maior fraqueza tem moldura de destaque.
4. **Given** o detalhe, **When** exibido, **Then** habitat e partes quebráveis aparecem lado a lado
   em telas com largura suficiente, e a parte cortável tem a etiqueta "Cortável".
5. **Given** a lista, **When** exibida, **Then** os filtros de jogo aparecem como abas ("Todos",
   "World", "Rise", "Wilds"), com a aba ativa claramente destacada.

---

### Edge Cases

- Monstro presente em mais de um jogo: cada versão usa a miniatura do próprio jogo.
- Miniatura ausente ou que falha ao carregar: marcador no mesmo estilo, nunca espaço vazio.
- Nomes longos ("Placa Gélida G. (Exposta)", "Mizutsune Violeta") e textos ampliados até 200%:
  quebram linha sem estourar molduras ou abas.
- Monstro com todas as fraquezas baixas: nenhuma fraqueza destacada nem na lista nem no detalhe.
- Monstro imune a um elemento: a imunidade continua visualmente distinta de "0 estrelas".
- Telas estreitas (320 dp): as quatro abas de jogo cabem ou quebram de forma legível.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O app DEVE usar sempre o tema escuro "Caderno do Caçador", independentemente da
  configuração de tema do sistema.
- **FR-002**: Todas as telas (lista, detalhe, configurações, estados de carregando, vazio e erro)
  DEVEM seguir a identidade visual do protótipo A: fundo escuro de couro, detalhes dourados,
  títulos de seção em fonte de inscrição, molduras e separadores ornamentais.
- **FR-003**: Cada um dos 30 monstros DEVE ter sua miniatura desenhada (ícone do caderno de caça do
  respectivo jogo), exibida ao lado do nome na lista e em destaque no detalhe.
- **FR-004**: Na ausência ou falha da miniatura, o app DEVE exibir um marcador no mesmo estilo
  (moldura dourada e fundo escuro) no mesmo espaço.
- **FR-005**: Cada item da lista DEVE exibir a principal fraqueza do monstro (elemento com a maior
  nota, somente se for de 2 estrelas ou mais), com o nome do elemento e sua cor; empates exibem o
  primeiro na ordem Fogo, Água, Raio, Gelo, Dragão.
- **FR-006**: O detalhe DEVE exibir as fraquezas numa grade de cinco elementos, cada um com ícone
  e cor próprios, e a(s) maior(es) fraqueza(s) com moldura de destaque; imunidade continua
  distinta de 0 estrelas.
- **FR-007**: Cada elemento DEVE ter uma cor própria e um ícone próprio, usados de forma
  consistente na lista e no detalhe.
- **FR-008**: O detalhe DEVE exibir habitat e partes quebráveis lado a lado quando houver largura
  suficiente, e empilhados em telas estreitas; partes cortáveis DEVEM ter a etiqueta "Cortável".
- **FR-009**: Os filtros de jogo DEVEM ser exibidos como abas ("Todos", "World", "Rise",
  "Wilds"), com a aba ativa destacada.
- **FR-010**: No filtro "Todos", os cabeçalhos de seção de cada jogo DEVEM usar o separador
  ornamental (linhas dos dois lados do nome do jogo).
- **FR-011**: A identidade visual DEVE manter as regras de acessibilidade já existentes: contraste
  mínimo de 4,5:1 para textos (3:1 para textos grandes), alvos de toque de pelo menos 48 dp,
  rótulos de acessibilidade nas fraquezas e texto ampliado a 200% sem cortes.
- **FR-012**: Todas as funcionalidades existentes (busca, filtro, idioma dos nomes, layout
  adaptativo, estados de erro) DEVEM continuar funcionando exatamente como antes.

### Key Entities *(include if feature involves data)*

- **Miniatura do Monstro**: imagem desenhada do monstro no estilo do caderno de caça do seu jogo;
  uma por monstro (por jogo); opcional.
- **Estilo do Elemento**: cor e ícone associados a cada um dos cinco elementos.
- **Tema "Caderno do Caçador"**: conjunto fixo de cores, tipografia, molduras e separadores
  aplicado a todo o app.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 30 de 30 monstros exibem sua própria miniatura na lista e no detalhe.
- **SC-002**: 100% das telas do app aparecem no tema escuro com o aparelho em modo claro e em
  modo escuro.
- **SC-003**: 100% dos textos atingem contraste mínimo de 4,5:1 (3:1 para textos de 24 px ou
  mais) sobre o fundo em que aparecem.
- **SC-004**: Um usuário identifica a principal fraqueza de um monstro a partir da lista, sem
  abrir o detalhe, em menos de 5 segundos.
- **SC-005**: Em comparação lado a lado com o protótipo A, a lista e o detalhe apresentam os
  mesmos elementos de identidade (fundo, dourado, fonte de inscrição, molduras, separadores,
  grade de fraquezas, abas).
- **SC-006**: Nenhuma regressão: todos os cenários de aceitação da feature 001 continuam passando.

## Assumptions

- As miniaturas são arte da Capcom e são usadas localmente, pois o app é um projeto pessoal/de
  estudo sem publicação em lojas (decisão registrada na feature 001). Uma eventual publicação
  exigirá substituí-las; como a imagem é opcional por monstro, isso não exige mudança de telas.
- As miniaturas vêm de fontes de referência da comunidade (bancos de dados dos jogos), e a origem
  de cada uma fica registrada junto aos dados.
- A fonte de inscrição dos títulos e a fonte do texto corrido são fontes de uso livre, empacotadas
  com o app (funcionam offline).
- Configurações passa a seguir a mesma identidade; não há novas opções de tema (o tema é fixo).
- Não há imagens grandes/ilustrações dos monstros nesta feature; apenas as miniaturas.
- Fora do escopo: animações elaboradas, sons, novas informações de monstros.
