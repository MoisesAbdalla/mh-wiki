# Feature Specification: Todos os Monstros Grandes

**Feature Branch**: `004-all-large-monsters`

**Created**: 2026-09-30

**Status**: Draft

**Input**: User description: "Ampliar o wiki para todos os monstros grandes dos três jogos (Monster Hunter World: Iceborne, Rise: Sunbreak e Wilds), incluindo subespécies e variantes, em vez dos 10 monstros curados por jogo. Cada monstro novo deve ter os mesmos dados dos atuais: nomes en/pt-BR, classificação, fraquezas elementais (incluindo por estado), habitats, partes quebráveis, materiais por rank com método e taxa, miniatura do caderno do caçador, HP por rank com estimativa de grupo e reações a itens de caça (feature 003). Os dados continuam offline, com fontes registradas por monstro, e nenhum valor inventado: o que não for verificado aparece como desconhecido. A lista precisa continuar rápida e a busca funcionando com a quantidade maior de monstros."

## Clarifications

### Session 2026-09-30

- Q: Quais monstros devem virar entradas próprias na lista? → A: Todos: espécies base, subespécies, espécies raras, variantes nomeadas (Apex, Ressurgido, Guardião…) e também os níveis/estados Temperado, Arquitemperado, Aflito, Frenesi e Anomalia como entradas separadas.
- Q: Em que ordem os monstros novos devem ser entregues? → A: Um jogo por vez — Wilds, depois Rise: Sunbreak, depois World: Iceborne —, cada jogo completo (US1 + US2 + US3) validado e mesclado antes do próximo.
- Q: Como as versões de um mesmo monstro devem aparecer na lista? → A: Recolhidas: a lista mostra uma linha por monstro base, em ordem alfabética; as versões dele são escolhidas dentro do detalhe.
- Q: Quais entradas ficam recolhidas como "versões" e quais ganham linha própria? → A: Recolhidos na base: níveis (Temperado, Arquitemperado, Aflito, Frenesi, Anomalia) e variantes do mesmo monstro (Apex, Ressurgido, Guardião…). Subespécies e espécies raras (ex.: Rathalos Prateado, Rathian Rosa) têm linha própria.
- Q: Quando uma versão não tem na fonte um dado próprio, o que o detalhe mostra? → A: Herda da base fraquezas, partes, habitats e reações a itens, com a indicação "igual à forma base"; HP e materiais vêm sempre da fonte da própria versão ou aparecem como "Desconhecido".

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Encontrar qualquer monstro grande do jogo (Priority: P1)

O caçador abre o wiki no jogo que está jogando e encontra qualquer monstro grande que aparece
nele — não só os 10 mais conhecidos —, com a mesma página de detalhe que já existe: nomes,
classificação, fraquezas, habitats, partes quebráveis e materiais por rank.

**Why this priority**: hoje o wiki cobre só 30 monstros; quem enfrenta um monstro fora dessa
lista não encontra nada. Cobrir o elenco completo é o que torna o app útil no dia a dia.

**Entrega**: por jogo, na ordem Wilds → Rise: Sunbreak → World: Iceborne; cada jogo entra
completo (esta história e as seguintes) antes do próximo começar.

**Independent Test**: escolher, em cada jogo, monstros que não estavam entre os 30 originais
(incluindo uma subespécie e uma variante) e conferir que aparecem na lista, com detalhe completo
e dados batendo com as fontes registradas.

**Acceptance Scenarios**:

1. **Given** um jogo selecionado, **When** o usuário vê a lista, **Then** ela contém todos os
   monstros grandes desse jogo presentes nas fontes, incluindo subespécies, variantes nomeadas e
   as versões Temperado, Arquitemperado, Aflito, Frenesi e Anomalia, cada uma como entrada
   própria.
2. **Given** um monstro novo, **When** o usuário abre o detalhe, **Then** vê as mesmas seções
   dos monstros atuais (fraquezas, habitats, partes, materiais, HP, itens de caça), cada uma com
   dados verificados ou com a indicação explícita de desconhecido.
3. **Given** um monstro que existe em mais de um jogo, **When** o usuário troca de jogo, **Then**
   vê os dados de cada jogo separadamente, como já acontece hoje.
4. **Given** um dado que as fontes não confirmam (ex.: taxa de drop, pt-BR de um nome, reação a
   um item), **When** ele seria exibido, **Then** aparece como desconhecido (ou o nome em
   inglês, conforme a regra atual), nunca um valor inventado.

---

### User Story 2 - Informações de caçada para todos (Priority: P2)

O caçador quer, para qualquer monstro grande, o HP por rank com a estimativa de grupo e as
reações a Flash, Sonic/Screamer, Dung e armadilhas, como já existe para os 30 monstros.

**Why this priority**: é a informação da feature 003; depende do elenco completo (US1) mas pode
ser entregue logo depois, já que as seções exibem "desconhecido" quando faltam dados.

**Independent Test**: abrir monstros novos de cada jogo e conferir HP e reações contra as fontes
registradas; monstros sem dado mostram "HP desconhecido" / "Desconhecido".

**Acceptance Scenarios**:

1. **Given** um monstro novo com HP nas fontes, **When** o detalhe é exibido, **Then** mostra o
   HP de referência de cada rank em que ele existe e a estimativa de grupo do jogo.
2. **Given** um monstro novo, **When** a seção de itens de caça é exibida, **Then** cada item do
   jogo mostra a reação registrada na fonte ou "Desconhecido".

---

### User Story 3 - Lista grande continua rápida e fácil de usar (Priority: P3)

Com várias vezes mais monstros, o caçador continua abrindo a lista, rolando e buscando sem
travamentos, e reconhece cada monstro pela miniatura.

**Why this priority**: garante que o aumento de conteúdo não piore a experiência; é validável com
o elenco completo já carregado.

**Independent Test**: com todos os monstros carregados, medir abertura da lista, rolagem e busca
em um celular intermediário; conferir que cada monstro tem miniatura ou o marcador padrão.

**Acceptance Scenarios**:

1. **Given** o elenco completo, **When** o usuário abre a lista ou troca de jogo, **Then** ela
   aparece sem espera perceptível e rola sem engasgos.
2. **Given** o elenco completo, **When** o usuário digita na busca (nome em pt-BR ou inglês, com
   ou sem acento), **Then** os resultados se atualizam enquanto digita.
3. **Given** um monstro com versões, **When** o usuário vê a lista, **Then** ela mostra uma única
   linha para ele (com a indicação de quantas versões existem), e no detalhe o usuário escolhe
   a versão a exibir.
4. **Given** uma busca que casa com o nome de uma versão (ex.: "arquitemperado"), **When** o
   usuário toca no resultado, **Then** o detalhe abre já na versão encontrada.
5. **Given** um monstro sem miniatura do caderno do caçador disponível, **When** ele aparece na
   lista ou no detalhe, **Then** mostra o marcador padrão, sem quebrar o layout.

### Edge Cases

- Subespécie ou espécie rara com nome parecido ao da espécie base (ex.: "Rathalos" e "Rathalos
  Prateado"): linhas próprias na lista; a busca por "rathalos" encontra todas.
- Variante do mesmo monstro (ex.: "Rathalos Apex", "Rathalos Guardião"): fica recolhida como
  versão da espécie base; se a espécie base não existir no jogo, a variante vira a linha
  própria e as versões dela ficam recolhidas nela.
- Versão Temperado/Arquitemperado/Aflito/Frenesi/Anomalia de um monstro: é uma entrada própria,
  com nome que deixa clara a versão (ex.: "Rathalos Arquitemperado"); a busca por "rathalos"
  encontra a base e todas as versões. Fraquezas, partes, habitats e reações a itens
  que a fonte não traz para a versão são herdados da base e marcados "igual à forma base"; HP e
  materiais nunca são herdados (vêm da fonte da versão ou aparecem como desconhecidos).
- Monstro que aparece apenas em Mestre (ou só em Alto) no jogo: mostra apenas os ranks em que
  existe, em todas as seções.
- Monstro sem partes quebráveis ou sem materiais conhecidos: seção mostra a mensagem de vazio
  já existente, nunca uma lista inventada.
- Monstro final/especial sem missão regular nem expedição (ex.: chefes de história, eventos):
  HP pode ficar desconhecido; o restante dos dados aparece normalmente.
- Nome pt-BR oficial inexistente ou não verificado: usa o nome em inglês (regra atual).
- Correções nos 30 monstros originais descobertas durante a ampliação: aplicadas com a fonte
  registrada.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Cada jogo MUST listar todos os monstros grandes presentes nas fontes de dados
  para o jogo completo (incluindo expansão e atualizações gratuitas publicadas), incluindo
  subespécies, espécies raras, variantes nomeadas e as versões Temperado, Arquitemperado,
  Aflito, Frenesi e Anomalia, cada uma como entrada própria.
- **FR-002**: Cada monstro novo MUST ter os mesmos campos dos monstros atuais: nomes en/pt-BR,
  classificação, fraquezas (gerais e por estado), habitats, partes quebráveis, materiais por
  rank com método e taxa, miniatura, HP por rank e reações a itens de caça.
- **FR-003**: Todo dado exibido MUST vir de uma fonte registrada no próprio monstro (ou, para
  versões, da forma base conforme FR-006c, com a indicação); dados não verificados MUST aparecer
  como desconhecido (ou omitidos, conforme a regra da seção), nunca estimados sem rótulo.
- **FR-004**: O app MUST continuar funcionando totalmente offline com o elenco completo.
- **FR-005**: A busca MUST continuar encontrando monstros por nome pt-BR ou inglês, ignorando
  maiúsculas e acentos, em todo o elenco do jogo selecionado.
- **FR-006**: A lista MUST mostrar uma linha por monstro base, em ordem alfabética, com
  miniatura (ou o marcador padrão) e a indicação de quantas versões ele tem; as versões MUST
  ficar recolhidas na lista.
- **FR-006a**: O detalhe MUST permitir escolher entre a base e cada versão do monstro, trocando
  todas as seções para os dados da versão escolhida; a busca MUST considerar os nomes das
  versões e abrir o detalhe na versão encontrada.
- **FR-006b**: MUST ser versão (recolhida) de uma espécie base: os níveis Temperado,
  Arquitemperado, Aflito, Frenesi e Anomalia e as variantes do mesmo monstro (Apex, Ressurgido,
  Guardião…). Subespécies e espécies raras MUST ter linha própria, com suas próprias versões.
- **FR-006c**: Numa versão, fraquezas, partes quebráveis, habitats e reações a itens sem dado
  próprio na fonte MUST ser herdados da forma base e exibidos com a indicação "igual à forma
  base"; HP e materiais MUST NOT ser herdados (vêm da fonte da versão ou aparecem como
  desconhecidos).
- **FR-007**: Os 30 monstros atuais MUST manter seus dados (salvo correções com fonte) e
  continuar passando nas verificações existentes.
- **FR-008**: Todos os dados de todos os monstros MUST passar pela validação de formato do
  conjunto de dados antes de serem distribuídos com o app.
- **FR-009**: As regras de acessibilidade e visual das features 002 e 003 (contraste, texto em
  200%, telas de 320 dp, alvos de toque) MUST valer para todos os monstros novos.
- **FR-010**: A ampliação MUST ser entregue um jogo por vez, na ordem Wilds, Rise: Sunbreak,
  World: Iceborne; ao fim de cada jogo, o app MUST estar utilizável com aquele jogo completo e os
  demais no estado anterior (os 10 monstros curados).

### Key Entities

- **Monstro**: entrada de um monstro grande em um jogo, com os mesmos atributos dos atuais;
  subespécies, variantes e versões (Temperado, Arquitemperado, Aflito, Frenesi, Anomalia) são
  entradas próprias. Subespécies e espécies raras são monstros base (linha própria); níveis e
  variantes do mesmo monstro são versões ligadas à sua espécie base.
- **Versão**: entrada ligada a um monstro base (nível ou variante), com dados próprios e
  escolhida no detalhe desse monstro.
- **Fonte**: referência registrada por monstro e por conjunto de dados, com notas sobre como
  cada dado foi obtido.
- **Elenco do jogo**: conjunto completo de monstros grandes de um jogo, definido pelas fontes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% dos monstros grandes listados nas fontes de cada jogo aparecem no app
  (elenco conferido contra a lista de monstros grandes da fonte principal de cada jogo).
- **SC-002**: Em uma amostra de pelo menos 10 monstros novos por jogo, 100% dos valores
  exibidos batem com as fontes registradas.
- **SC-003**: 100% dos monstros têm fraquezas, classificação e pelo menos um habitat ou a
  indicação explícita de dado desconhecido; nenhum campo aparece vazio sem explicação.
- **SC-004**: Com o elenco completo, a lista de um jogo aparece em até 1 segundo após abrir o
  app ou trocar de jogo, em um celular intermediário.
- **SC-005**: Os resultados da busca se atualizam em até 300 ms após cada tecla digitada.
- **SC-006**: Pelo menos 95% dos monstros têm miniatura própria; o restante mostra o marcador
  padrão sem quebrar o layout.

## Assumptions

- **Monstro grande com entrada própria**: tudo que as fontes listam como monstro grande
  (espécie base, subespécies, espécies raras, variantes nomeadas) e cada versão Temperado,
  Arquitemperado, Aflito, Frenesi e Anomalia que exista no jogo e tenha dados próprios nas
  fontes (ex.: HP, drops ou missões específicas). Versões sem nenhum dado próprio nas fontes não
  são criadas só para preencher a lista.
- **Versão do conteúdo**: cobre o que estiver publicado nas fontes na data da coleta (World:
  Iceborne completo com atualizações; Rise: Sunbreak completo com atualizações; Wilds: versão
  atual das fontes). Monstros lançados depois ficam para uma atualização de dados.
- **Fontes**: as mesmas das features 001–003 (Kiranico, Monster Hunter Wiki, mhw-db.com,
  Fextralife) e as mesmas regras documentadas (ex.: estrelas de fraqueza derivadas de hitzones
  em Rise e Wilds; HP de referência e fatores de grupo da feature 003).
- **Miniaturas**: os ícones do caderno do caçador de cada jogo, obtidos da mesma forma que na
  feature 002; quando não houver ícone, usa-se o marcador padrão já existente.
- **Fora do escopo**: monstros pequenos, endêmicos, missões, armas e armaduras; novas telas ou
  filtros (ex.: por classificação) — podem virar features futuras.
- **Tamanho do app**: o aumento de tamanho causado pelos dados e miniaturas é aceitável, desde
  que o app continue offline e dentro dos limites das lojas.
