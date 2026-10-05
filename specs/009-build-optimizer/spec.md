# Feature Specification: Otimizador de builds da Rise: Sunbreak (Montar build)

**Feature Branch**: `009-build-optimizer`

**Created**: 2026-10-05

**Status**: Draft

**Input**: User description: "Otimizador de builds da Rise: Sunbreak (009, depois da 008 assistente com
builds prontas e salvas; 010 IA opcional). Liga a aba 'Montar build' do Assistente: o caçador escolhe
as habilidades e os níveis, cadastra os seus talismãs, e o app monta, offline, os conjuntos de arma,
peças, talismã e joias que atingem o pedido, dentro do seu progresso."

**Reference**: mockup aprovado em [mockups/approved.html](mockups/approved.html) (quatro telas:
escolher habilidades, meus talismãs, resultados, um resultado). Decisões do usuário:
- 2026-09-30: o otimizador vem logo depois das builds prontas, com talismãs cadastrados pelo
  usuário e respeitando o progresso;
- 2026-10-05: o mockup foi aprovado como está ("ok gostei de como ficou"), com os talismãs dentro de
  Montar build e os resultados em lista.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Montar uma build pelas habilidades (Priority: P1)

O caçador abre Montar build, escolhe as habilidades que quer e o nível de cada uma, e toca em
"Montar build". O app mostra os conjuntos (arma, 5 peças, joias) que atingem tudo dentro do seu
progresso e tipo de arma.

**Why this priority**: é o pedido do usuário: "eu escolho as skills que quero e o assistente monta a
melhor build para aquelas skills".

**Independent Test**: em Mestre M6★ com Espadão, pedir Reforço de Ataque 7, Olho Crítico 7, Reforço
Crítico 3 e Explor. de Fraqueza 3, sem talismã; ver ao menos um resultado "completa" e conferir, peça
por peça e joia por joia, que as habilidades somadas batem com o que o resultado mostra.

**Acceptance Scenarios**:

1. **Given** o Assistente, **When** o usuário toca na aba Montar build, **Then** ela abre (deixa de
   ser "em breve"), com um quadro no topo mostrando o progresso e o tipo de arma escolhidos em
   Recomendadas e a ação "alterar".
2. **Given** a busca de habilidades, **When** o usuário digita parte de um nome (pt-BR ou inglês,
   sem acentos), **Then** aparecem as habilidades que combinam, e ao tocar uma ela entra na lista com
   o nível máximo como sugestão.
3. **Given** uma habilidade na lista, **When** o usuário usa − / +, **Then** o nível muda entre 1 e
   o máximo da habilidade, com os quadradinhos acompanhando; "✕" a remove.
4. **Given** um tipo de arma, **When** a lista está vazia ou curta, **Then** aparecem como sugestão
   as habilidades mais comuns nas builds prontas daquele tipo.
5. **Given** habilidades escolhidas, **When** o usuário toca "Montar build", **Then** o app procura
   sem travar a tela, mostra "procurando…" com a opção de cancelar, e em seguida lista até 10
   conjuntos.
6. **Given** os resultados, **When** exibidos, **Then** cada card mostra os ícones das peças na cor
   da raridade, a arma, o talismã (ou nenhum), cada habilidade pedida com o atingido (ex.: 7/7), a
   defesa máxima e os slots que sobram; a ordem é: atinge tudo → mais slots livres → mais defesa.
7. **Given** "Só peças do meu progresso" ligado (padrão), **When** o app procura, **Then** usa só
   armas e peças disponíveis até o progresso escolhido; desligado, usa todas.
8. **Given** nenhum conjunto que atinja tudo, **When** a busca termina, **Then** aparecem os mais
   próximos com o selo "quase" e o que falta em vermelho; se nada chega perto, uma mensagem clara
   sugere baixar níveis ou ligar todas as peças.

---

### User Story 2 - Ver e salvar um resultado (Priority: P2)

O caçador abre um resultado e vê o conjunto inteiro como no detalhe da 008, com as habilidades
pedidas e as que vêm de brinde, passa para o próximo resultado e salva o que gostar em Minhas builds.

**Why this priority**: sem o detalhe não dá para montar no jogo; salvar liga a 009 às builds salvas
da 008.

**Independent Test**: abrir o 1º resultado, conferir o card "Habilidades pedidas" e "Também vem",
passar para "2 de N" e voltar, salvar e encontrar a build em Minhas builds depois de reabrir o app.

**Acceptance Scenarios**:

1. **Given** um resultado, **When** aberto, **Then** mostra: o card "Habilidades pedidas" com
   quadradinhos (os que faltam em vermelho) e a linha "Também vem" com as outras habilidades; o card
   Equipamento igual ao da 008 (ícone da parte na cor da raridade, nome, joias em botões); o card
   Joias com o total de cada joia.
2. **Given** o detalhe, **When** o usuário toca em "›" ou "‹", **Then** vai para o resultado seguinte
   ou anterior ("1 de 3").
3. **Given** o detalhe, **When** o usuário toca em "Salvar em Minhas builds", **Then** a build é
   salva com um nome padrão (ex.: "Espadão · Reforço de Ataque 7, Olho Crítico 7…") e aparece em
   Minhas builds, onde pode ser renomeada e excluída como na 008.
4. **Given** um item do resultado, **When** tocado, **Then** abre o detalhe em Armas ou Armaduras,
   como na 008.

---

### User Story 3 - Meus talismãs (Priority: P3)

O caçador cadastra os talismãs que tem (até 2 habilidades com nível e 3 slots), edita e exclui; o
Montar build passa a considerá-los.

**Why this priority**: o talismã muda muito o resultado, mas o otimizador já é útil sem ele.

**Independent Test**: cadastrar "Olho Crítico 3, slots ②①"; montar o mesmo pedido da US1 e ver que
ao menos um resultado usa esse talismã e precisa de menos joias de Olho Crítico.

**Acceptance Scenarios**:

1. **Given** Montar build, **When** o usuário toca em "gerenciar" talismãs, **Then** abre a tela Meus
   talismãs com a lista e o formulário "Novo talismã".
2. **Given** o formulário, **When** o usuário escolhe a habilidade 1 com nível, opcionalmente a
   habilidade 2 com nível, e os 3 slots (0 a 4), e salva, **Then** o talismã entra na lista e fica
   guardado no aparelho.
3. **Given** um talismã na lista, **When** o usuário o edita ou exclui (com confirmação), **Then** a
   lista e as próximas buscas refletem a mudança.
4. **Given** "usar meus talismãs" ligado, **When** o app procura, **Then** testa cada talismã
   cadastrado e também nenhum talismã; desligado, só sem talismã.

---

### User Story 4 - Fixar a arma (Priority: P4)

O caçador que já tem uma arma escolhe essa arma; o app monta o resto em volta dela.

**Why this priority**: refinamento comum, mas "qualquer arma do tipo" já atende o caso geral.

**Independent Test**: fixar "Ótimo Cutelo Kamura" e ver todos os resultados com essa arma.

**Acceptance Scenarios**:

1. **Given** o card "Arma e talismãs", **When** o usuário toca em "escolher", **Then** pode buscar uma
   arma do tipo escolhido (dentro do progresso, se o filtro estiver ligado) ou voltar a "qualquer".
2. **Given** uma arma fixa, **When** o app procura, **Then** todos os resultados usam essa arma, com
   os slots e a habilidade dela (se houver).

---

### Edge Cases

- O pedido é impossível (ex.: 6 habilidades no máximo em Baixo 1★): a busca termina com "quase" ou
  com a mensagem para baixar níveis; nunca trava.
- O usuário cancela a busca: volta à tela de escolha com tudo como estava.
- O usuário troca o progresso ou o tipo de arma depois de buscar: os resultados antigos somem e a
  busca precisa ser refeita.
- Uma habilidade só existe em joia de slot 4 e o progresso não tem peças com slot 4: aparece como
  faltando.
- Habilidade com joia acima do máximo (ex.: joia que soma além do nível 7): o atingido para no
  máximo da habilidade.
- Talismã com slots 0–0–0 e sem habilidade 2: aceito.
- Dois resultados iguais (mesmas peças e arma) com joias em ordem diferente: aparecem uma vez só.
- Arquivo de dados ausente ou inválido: só o Montar build mostra o erro; as outras áreas seguem.
- Texto grande (200 %) em 320 dp: listas, passos e slots quebram linha sem cortar.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A aba Montar build do Assistente MUST ficar habilitada; Recomendadas e Minhas builds
  continuam como na 008.
- **FR-002**: Montar build MUST mostrar o progresso e o tipo de arma escolhidos em Recomendadas
  (os mesmos, compartilhados) com uma ação para alterá-los.
- **FR-003**: Users MUST be able to buscar habilidades por nome (pt-BR ou inglês, ignorando acentos
  e maiúsculas), adicioná-las, ajustar o nível de 1 ao máximo e removê-las.
- **FR-004**: O sistema MUST sugerir as habilidades mais frequentes nas builds prontas do tipo de
  arma escolhido.
- **FR-005**: O sistema MUST montar conjuntos com: uma arma do tipo escolhido, uma peça por parte
  (cabeça, tronco, braços, cintura, pernas) ou a parte vazia, um talismã do usuário ou nenhum, e
  joias nos slots livres da arma, das peças e do talismã, respeitando o nível de slot.
- **FR-006**: O nível de cada habilidade num conjunto MUST ser a soma das peças, da habilidade da
  arma (se houver), do talismã e das joias, limitada ao máximo da habilidade; habilidades e joias de
  Rampage NÃO contam.
- **FR-007**: Com "Só peças do meu progresso" ligado (padrão), o sistema MUST usar só armas e peças
  disponíveis até o progresso escolhido; desligado, todas.
- **FR-008**: O sistema MUST mostrar até 10 conjuntos distintos, ordenados por: atinge todos os
  níveis pedidos → mais slots livres → maior defesa máxima.
- **FR-009**: Quando nenhum conjunto atingir tudo, o sistema MUST mostrar os mais próximos
  ("quase"), indicando quanto falta em cada habilidade.
- **FR-010**: A busca MUST rodar offline, sem travar a tela, com indicação "procurando…" e a opção
  de cancelar.
- **FR-011**: O detalhe de um resultado MUST mostrar as habilidades pedidas (atingido/pedido), as
  demais habilidades ("Também vem"), o equipamento no formato da 008 e o total de joias, com
  navegação entre os resultados.
- **FR-012**: Users MUST be able to salvar um resultado em Minhas builds (cópia), com um nome padrão
  que pode ser renomeado depois, como na 008.
- **FR-013**: Users MUST be able to cadastrar, editar e excluir talismãs (habilidade 1 com nível,
  habilidade 2 opcional com nível, três slots de 0 a 4), guardados no aparelho.
- **FR-014**: Com "usar meus talismãs" ligado, o sistema MUST testar cada talismã cadastrado e também
  nenhum talismã.
- **FR-015**: Users MUST be able to fixar uma arma do tipo escolhido ou deixar "qualquer".
- **FR-016**: As habilidades escolhidas, a arma fixa e as opções MUST continuar como estavam ao
  voltar à aba e ao reabrir o app.
- **FR-017**: Nomes de habilidades, peças, armas e joias MUST seguir a preferência de idioma.
- **FR-018**: A interface MUST seguir o estilo Caderninho (005) e o detalhe da 008, e funcionar em
  320 dp com texto em 200 %, com contraste adequado, alvos de toque de 48 dp e semântica para leitor
  de tela (ex.: "Olho Crítico, 5 de 7, faltam 2").

### Key Entities *(include if feature involves data)*

- **Pedido**: as habilidades com o nível desejado, o progresso, o tipo de arma, a arma fixa (ou
  qualquer), e as opções "usar meus talismãs" e "só peças do meu progresso".
- **Talismã do usuário**: até duas habilidades com nível e três slots (0 a 4).
- **Conjunto (resultado)**: arma, até 5 peças, talismã (ou nenhum), joias por slot; as habilidades
  somadas, a defesa máxima, os slots livres e se atinge o pedido ("completa" ou "quase").
- **Build salva**: a mesma da 008, agora também criada a partir de um conjunto.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em 100 % dos resultados conferidos, as habilidades mostradas batem com a soma de
  peças, arma, talismã e joias (conferência automática em todos os resultados de 20 pedidos de
  teste, mais 5 conferidos à mão no jogo ou na wiki).
- **SC-002**: Um pedido de até 5 habilidades mostra os resultados em até 10 segundos num celular
  intermediário, com a tela respondendo durante a busca.
- **SC-003**: Para os pedidos das builds prontas de Mestre e Pós-jogo da 008 (as 5 habilidades
  principais de cada uma, nos níveis que ela atinge sem o talismã, com a mesma arma), o otimizador
  encontra um conjunto "completa" em ao menos 95 % dos casos. As outras habilidades da build vêm de
  brinde e não fazem parte do pedido; um pedido real tem poucas habilidades.
- **SC-004**: Do toque na aba até ver os resultados de um pedido de 4 habilidades, o usuário leva
  menos de 1 minuto.
- **SC-005**: Os talismãs e as escolhas persistem em 100 % dos reinícios do app.

## Assumptions

- O catálogo da 006/007 (armas, peças com slots e habilidades, joias com nível de slot, habilidades
  com nível máximo) é a base; habilidades de set bonus da Sunbreak entram como as demais
  habilidades que já estão no catálogo.
- A disponibilidade por progresso usa a raridade das peças e armas mapeada para o progresso
  (ex.: Baixo até raridade 3, Alto até 7, Mestre por faixa até 10), definida no plano.
- Joias: o usuário tem todas as joias liberadas no progresso (não há inventário de joias).
- Fora do escopo: aprimoramentos Qurious, roupas de layered, Rampage como fonte de habilidade,
  World e Wilds, IA (010), e inventário de joias/peças do usuário.
- A arma pode ter habilidade própria só se o catálogo tiver; caso contrário, só os slots contam.
