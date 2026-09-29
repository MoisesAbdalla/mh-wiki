# Feature Specification: Wiki de Monstros

**Feature Branch**: `001-monster-wiki`

**Created**: 2026-09-29

**Status**: Draft

**Input**: User description: "Wiki de monstros: listar os monstros de Monster Hunter World: Iceborne, Rise: Sunbreak e Wilds, com filtro por jogo e busca por nome, e uma tela de detalhe de cada monstro mostrando fraquezas elementais, habitat, partes quebráveis e materiais obtidos."

## Clarifications

### Session 2026-09-29

- Q: O app vai ser publicado nas lojas ou é um projeto pessoal/de estudo sem distribuição pública? → A: Projeto pessoal/estudo na v1; imagens de referência podem ser usadas localmente, sem publicação em lojas.
- Q: Em quais plataformas o app precisa funcionar na v1? → A: Celular, tablet, web e desktop (Windows), com layout adaptativo.
- Q: Como os nomes dos monstros e materiais devem aparecer: pt-BR oficial ou inglês? → A: O usuário escolhe nas configurações se os nomes aparecem em pt-BR ou em inglês.
- Q: Quando o filtro está em "Todos", como a lista deve ser organizada? → A: Seções por jogo (World: Iceborne, Rise: Sunbreak, Wilds), cada uma em ordem alfabética.
- Q: A fraqueza elemental deve ter uma única nota por elemento ou uma nota por estado do monstro? → A: Nota geral por elemento e, apenas para monstros que mudam de fraqueza, notas adicionais por estado nomeado.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consultar as fraquezas de um monstro (Priority: P1)

Um caçador está prestes a enfrentar um monstro e quer saber rapidamente qual elemento usar.
Ele abre o app, vê a lista de monstros, toca no monstro desejado e visualiza a tela de detalhe
com as fraquezas elementais, o habitat, as partes quebráveis e os materiais que o monstro fornece.

**Why this priority**: é o motivo principal de existir uma wiki de monstros — preparar a caçada.
Uma lista navegável com detalhe já entrega valor mesmo sem filtro ou busca.

**Independent Test**: com um conjunto de monstros de pelo menos um jogo disponível, abrir o app,
selecionar um monstro na lista e verificar que a tela de detalhe mostra as quatro seções
(fraquezas, habitat, partes quebráveis, materiais) com os dados corretos daquele monstro.

**Acceptance Scenarios**:

1. **Given** o app aberto na lista de monstros, **When** o usuário toca em um monstro,
   **Then** a tela de detalhe desse monstro é exibida, indicando nome e jogo de origem.
2. **Given** a tela de detalhe de um monstro, **When** o usuário observa a seção de fraquezas,
   **Then** vê a eficácia de cada elemento (Fogo, Água, Raio, Gelo, Dragão) em uma escala
   comparável, destacando o(s) elemento(s) mais eficaz(es).
3. **Given** a tela de detalhe de um monstro, **When** o usuário observa as demais seções,
   **Then** vê os habitats (regiões/mapas) onde o monstro aparece, a lista de partes quebráveis
   (e cortáveis, quando aplicável) e os materiais obtidos.
4. **Given** a tela de detalhe, **When** o usuário volta, **Then** retorna à lista na mesma
   posição e com os mesmos filtros de antes.
5. **Given** o app em uma tela larga (tablet em paisagem, web ou desktop), **When** o usuário
   seleciona um monstro, **Then** o detalhe aparece ao lado da lista, que continua visível.

---

### User Story 2 - Filtrar monstros por jogo (Priority: P2)

O caçador está jogando apenas um dos três jogos e quer ver somente os monstros desse jogo,
sem misturar dados de outros títulos.

**Why this priority**: os dados diferem entre jogos; sem filtro, a lista combinada dos três
jogos fica longa e propensa a confusão (ex.: o mesmo monstro em três versões).

**Independent Test**: com monstros dos três jogos carregados, selecionar um jogo e verificar
que apenas monstros daquele jogo aparecem; limpar o filtro e verificar que todos voltam.

**Acceptance Scenarios**:

1. **Given** a lista com monstros dos três jogos, **When** o usuário seleciona "Rise: Sunbreak",
   **Then** apenas monstros de Rise: Sunbreak são exibidos.
2. **Given** um filtro de jogo ativo, **When** o usuário seleciona "Todos", **Then** monstros dos
   três jogos são exibidos em seções por jogo (World: Iceborne, Rise: Sunbreak, Wilds), cada
   seção em ordem alfabética.
3. **Given** um monstro presente em mais de um jogo (ex.: Rathalos), **When** a lista mostra
   "Todos", **Then** cada versão aparece como item separado dentro da seção do seu jogo.

---

### User Story 3 - Buscar monstro pelo nome (Priority: P3)

O caçador sabe o nome do monstro e quer encontrá-lo diretamente sem rolar a lista.

**Why this priority**: acelera o acesso quando o usuário já sabe o que procura; complementa o
filtro por jogo.

**Independent Test**: digitar parte do nome de um monstro e verificar que a lista mostra apenas
os monstros correspondentes, respeitando o filtro de jogo ativo.

**Acceptance Scenarios**:

1. **Given** a lista de monstros, **When** o usuário digita "rath", **Then** a lista mostra
   apenas monstros cujo nome contém "rath" (ex.: Rathalos, Rathian e variantes).
2. **Given** um filtro de jogo ativo e um termo de busca, **When** ambos são aplicados,
   **Then** o resultado respeita os dois critérios ao mesmo tempo.
3. **Given** um termo sem correspondência, **When** a busca é aplicada, **Then** o app exibe
   uma mensagem de "nenhum monstro encontrado" com opção de limpar a busca.
4. **Given** um termo digitado sem acentos ou com maiúsculas/minúsculas diferentes, **When** a
   busca é aplicada, **Then** o resultado é o mesmo que com a grafia exata.

---

### Edge Cases

- Monstro sem nenhuma parte quebrável ou sem habitat fixo (ex.: monstros de arena/eventos):
  a seção correspondente informa explicitamente "nenhuma" em vez de ficar vazia ou sumir.
- Monstro sem fraquezas elementais relevantes (todas as eficácias baixas): a seção mostra todos
  os elementos sem destacar nenhum como mais eficaz.
- Monstro imune a um elemento: a imunidade é mostrada de forma distinta de "pouco eficaz".
- Monstro com estados em que um elemento passa de pouco eficaz para muito eficaz: a nota geral e
  a nota do estado aparecem juntas, sem que uma sobrescreva a outra.
- Variantes e subespécies (ex.: Rathalos Prateado, Rathalos Celeste) são monstros distintos,
  com detalhe próprio.
- Dados de um jogo indisponíveis ou corrompidos: os demais jogos continuam acessíveis e o
  usuário vê uma mensagem clara de que os dados daquele jogo não puderam ser carregados.
- Busca combinada com filtro sem resultados: a mensagem de vazio indica que há filtro ativo e
  permite limpá-lo.
- Material obtido por várias formas (ex.: entalhe e quebra de parte) em ranks diferentes: cada
  combinação rank + forma aparece com sua própria taxa, sem duplicar o material de forma confusa.
- Monstro sem materiais em algum rank (ex.: não existe no Rank Mestre): o rank não é exibido
  ou é indicado como indisponível, nunca como lista vazia sem explicação.
- Nomes muito longos devem aparecer completos ou truncados de forma legível, sem quebrar o layout.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O app DEVE exibir uma lista de monstros contendo, para cada item, nome, jogo de
  origem e uma representação visual identificável (ícone ou imagem, quando disponível).
- **FR-002**: O app DEVE cobrir os jogos Monster Hunter World: Iceborne, Monster Hunter Rise:
  Sunbreak e Monster Hunter Wilds. A v1 DEVE conter um subconjunto representativo de
  aproximadamente 10 monstros grandes por jogo, incluindo ao menos um monstro presente nos três
  jogos, ao menos uma variante/subespécie e ao menos um monstro sem partes quebráveis ou sem
  habitat fixo, quando existir no jogo.
- **FR-002a**: A inclusão de novos monstros em versões futuras DEVE exigir apenas a adição de
  dados, sem alteração de telas ou regras do app.
- **FR-003**: O usuário DEVE poder filtrar a lista por um jogo específico ou ver todos os jogos.
- **FR-004**: O usuário DEVE poder buscar monstros por nome, com correspondência parcial,
  sem diferenciar maiúsculas/minúsculas nem acentos.
- **FR-005**: Busca e filtro por jogo DEVEM poder ser combinados, e o resultado DEVE atualizar
  conforme o usuário digita.
- **FR-006**: A lista DEVE ser apresentada em ordem alfabética por nome dentro de cada jogo. Com
  o filtro "Todos", a lista DEVE ser dividida em seções com cabeçalho por jogo, na ordem World:
  Iceborne, Rise: Sunbreak, Wilds; seções sem resultados (ex.: após uma busca) NÃO DEVEM ser
  exibidas.
- **FR-007**: Ao selecionar um monstro, o app DEVE exibir uma tela de detalhe com: nome, jogo,
  classificação (ex.: Wyvern Voadora), fraquezas elementais, habitats, partes quebráveis e
  materiais obtidos.
- **FR-008**: As fraquezas elementais DEVEM cobrir Fogo, Água, Raio, Gelo e Dragão, cada uma com
  um nível de eficácia em escala comum a todos os jogos, distinguindo imunidade.
- **FR-008a**: Todo monstro DEVE ter uma nota geral por elemento. Monstros cuja fraqueza muda
  conforme o estado ou forma (ex.: "Enfurecido", "Espinhos endurecidos") PODEM ter, além da nota
  geral, notas por estado nomeado; nesse caso, a tela de detalhe DEVE mostrar a nota geral em
  destaque e as notas por estado identificadas pelo nome do estado. Monstros sem estados NÃO
  DEVEM exibir nenhuma seção de estados.
- **FR-009**: A seção de habitat DEVE listar as regiões/mapas do jogo em que o monstro aparece.
- **FR-010**: A seção de partes quebráveis DEVE listar as partes que podem ser quebradas e
  indicar quais podem ser cortadas.
- **FR-011**: A seção de materiais DEVE listar os materiais obtidos do monstro agrupados por rank
  (Baixo, Alto, Mestre — conforme o jogo), e, para cada material, cada forma de obtenção
  (ex.: entalhe no corpo, entalhe na cauda, recompensa de captura, quebra de parte específica,
  recompensa de missão, material caído) com a respectiva taxa de obtenção em porcentagem.
- **FR-011a**: Quando a forma de obtenção for quebra de parte, o app DEVE indicar qual parte deve
  ser quebrada, vinculada à lista de partes quebráveis.
- **FR-011b**: Quando a taxa de obtenção de uma forma não for conhecida, o app DEVE exibir
  "taxa desconhecida" em vez de omitir a forma de obtenção ou mostrar um valor inventado.
- **FR-012**: O app DEVE funcionar integralmente sem conexão com a internet.
- **FR-013**: Monstros que existem em mais de um jogo DEVEM ser tratados como entradas distintas,
  cada uma com os dados específicos do seu jogo.
- **FR-014**: Toda a interface DEVE estar em português do Brasil.
- **FR-015**: Ao voltar do detalhe para a lista, o app DEVE preservar filtro, busca e posição de
  rolagem.
- **FR-016**: Quando uma seção do detalhe não tiver dados, o app DEVE indicá-lo explicitamente
  (ex.: "Nenhuma parte quebrável").
- **FR-017**: Falhas ao carregar os dados de um jogo NÃO DEVEM impedir o uso dos demais jogos, e
  o usuário DEVE ser informado da falha.
- **FR-018**: O app DEVE funcionar em celular (Android), tablet, navegador web e desktop
  Windows, com as mesmas funcionalidades em todas as plataformas.
- **FR-019**: Em telas estreitas (celular em retrato), lista e detalhe DEVEM ser telas separadas
  com navegação entre elas; em telas largas (tablet em paisagem, web e desktop), lista e detalhe
  DEVEM ser exibidos lado a lado, e selecionar um monstro atualiza o painel de detalhe sem sair
  da lista.
- **FR-020**: Ao redimensionar a janela (web/desktop) ou girar o aparelho, o app DEVE alternar
  entre os dois layouts preservando o monstro selecionado, o filtro e a busca.
- **FR-021**: O app DEVE oferecer uma configuração "Idioma dos nomes do jogo" com as opções
  Português (Brasil) e Inglês, que controla como são exibidos os nomes de monstros, materiais,
  habitats e partes; o restante da interface permanece em pt-BR. O padrão é Português (Brasil).
- **FR-022**: A preferência de idioma dos nomes DEVE ser lembrada entre sessões e aplicada
  imediatamente a todas as telas ao ser alterada, sem reiniciar o app.
- **FR-023**: A busca por nome DEVE encontrar monstros tanto pelo nome em pt-BR quanto pelo nome
  em inglês, independentemente da preferência de exibição.
- **FR-024**: Quando um nome não tiver tradução oficial em pt-BR, o app DEVE exibir o nome em
  inglês como alternativa.
- **FR-025**: A ordem alfabética da lista (FR-006) DEVE seguir o idioma de nomes selecionado.

### Key Entities *(include if feature involves data)*

- **Jogo**: um dos títulos suportados (World: Iceborne, Rise: Sunbreak, Wilds). Nome de exibição
  e ordem de apresentação.
- **Monstro**: criatura de um jogo específico. Nome em pt-BR e em inglês, jogo de origem, classificação, imagem/ícone,
  fraquezas, habitats, partes quebráveis e materiais. Identificado de forma única pelo par
  (jogo, identificador).
- **Fraqueza Elemental**: relação entre um monstro e um elemento, com nível de eficácia
  (incluindo imunidade). Existe sempre uma fraqueza geral por elemento; opcionalmente, fraquezas
  adicionais vinculadas a um Estado do Monstro.
- **Estado do Monstro**: condição ou forma nomeada (em pt-BR e em inglês) em que as fraquezas de
  um monstro diferem das gerais. Opcional; existe apenas para monstros que mudam de fraqueza.
- **Habitat**: região ou mapa de um jogo onde o monstro pode ser encontrado.
- **Parte Quebrável**: parte do corpo do monstro que pode ser quebrada, com indicação de ser
  cortável.
- **Material**: item obtido do monstro, com nome em pt-BR e em inglês e raridade quando
  disponível.
- **Preferência de Idioma dos Nomes**: escolha do usuário (pt-BR ou inglês) para exibição de
  nomes do jogo; guardada no dispositivo.
- **Forma de Obtenção**: como um material é obtido de um monstro em um rank específico — tipo
  (entalhe, captura, quebra de parte, recompensa de missão, material caído etc.), parte
  relacionada quando aplicável, e taxa de obtenção em porcentagem (ou desconhecida).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Um usuário consegue sair da abertura do app até ver as fraquezas de um monstro
  específico em menos de 15 segundos.
- **SC-002**: Os resultados da busca e do filtro aparecem em menos de 0,5 segundo após cada
  alteração, com a base completa de monstros carregada.
- **SC-003**: A tela de detalhe abre em menos de 1 segundo após o toque no monstro.
- **SC-004**: 100% das funcionalidades desta feature funcionam com o dispositivo em modo avião
  (no navegador web, após o primeiro carregamento).
- **SC-008**: Os cenários de aceitação das três histórias passam nas quatro plataformas
  (celular Android, tablet, web e desktop Windows).
- **SC-005**: Para 100% dos monstros da v1, as fraquezas, os materiais e as taxas de obtenção
  exibidos coincidem com a fonte de referência registrada nos dados.
- **SC-007**: Um usuário consegue responder "como obtenho o material X deste monstro e com que
  chance?" a partir da tela de detalhe em menos de 20 segundos.
- **SC-006**: 9 em cada 10 usuários de teste encontram um monstro pedido (por nome ou navegando
  pelo jogo) na primeira tentativa, sem ajuda.

## Assumptions

- "Monstros" nesta feature são os monstros grandes (caçáveis como alvo de missão); monstros
  pequenos/ambientais ficam fora do escopo da v1.
- World: Iceborne inclui os monstros do jogo base World; Rise: Sunbreak inclui os do jogo base
  Rise; Wilds inclui os monstros disponíveis na data de montagem dos dados, incluindo
  atualizações gratuitas já lançadas.
- Os nomes em pt-BR seguem a localização oficial de cada jogo; os nomes em inglês seguem a
  localização oficial em inglês. Cada monstro, material, habitat e parte tem os dois nomes
  cadastrados nos dados.
- A escala de eficácia elemental segue o padrão dos próprios jogos (0 a 3 estrelas, com
  indicação de imunidade), normalizada para ser comparável entre os três títulos.
- Fraquezas por parte do corpo (hitzones), status (veneno, sono etc.) e armadilhas ficam fora
  do escopo desta feature, podendo ser adicionados em features futuras.
- As taxas de obtenção refletem a versão mais recente de cada jogo na data de montagem dos dados;
  histórico de alterações de taxas entre patches está fora do escopo.
- A escolha exata dos ~10 monstros por jogo é feita na montagem dos dados, respeitando os
  critérios de representatividade do FR-002.
- O app é de consulta, sem contas de usuário, favoritos ou sincronização nesta feature; a única
  informação guardada no dispositivo é a preferência de idioma dos nomes.
- Os dados são mantidos pelo projeto e distribuídos junto com o app; atualizações de conteúdo
  chegam por atualização do app.
- A v1 é um projeto pessoal/de estudo, sem publicação em lojas de aplicativos. Imagens/ícones
  de referência dos monstros podem ser usados localmente; quando um monstro não tiver imagem,
  um marcador visual genérico é exibido. Uma eventual publicação futura exigirá revisão de
  direitos das imagens, sem mudança nas telas (a imagem é sempre opcional por monstro).
