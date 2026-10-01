# Feature Specification: Assistente de builds da Rise: Sunbreak

**Feature Branch**: `008-build-assistant`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "Assistente de builds da Rise: Sunbreak (terceira da sequência 006–010).
A área Assistente é ligada, com abas Recomendadas, Minhas builds e Montar build ('em breve' até a
009). O caçador diz onde está no jogo e que arma usa; o Assistente mostra as builds prontas da Game8
para agora e as próximas, com detalhe e a opção de salvar."

**Reference**: mockup aprovado em [mockups/approved.html](mockups/approved.html), lista na opção
**A** ("Para agora" e "Próximas"), detalhe da build e Minhas builds. Decisões do usuário em
2026-10-01:
- builds importadas da Game8;
- progresso por estrelas com faixas de pós-jogo;
- o otimizador por habilidades fica para a 009, logo em seguida ("ok podemos manter a ordem").

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Builds para onde estou (Priority: P1)

O caçador abre o Assistente, diz em que ponto do jogo está (rank e estrelas, ou faixa de pós-jogo)
e qual tipo de arma usa, e vê as builds prontas que já pode fazer, separadas das próximas.

**Why this priority**: é a pergunta central do assistente: "que build eu faço agora com esta arma?".

**Independent Test**: escolher Mestre M2★ e Espadão; "Para agora" mostra "Kamura Warrior Cleaver
Raw Affinity" (MR 1–2), e "Próximas" mostra as de MR 3–6 em diante, esmaecidas.

**Acceptance Scenarios**:

1. **Given** a barra de navegação, **When** o usuário toca em Assistente, **Then** a área abre na
   aba Recomendadas (a área deixa de aparecer como "em breve"); a aba Montar build aparece como "em
   breve".
2. **Given** o seletor "Onde você está?", **When** o usuário escolhe um rank (Baixo, Alto, Mestre
   ou Pós-jogo) e uma estrela ou faixa, e um tipo de arma, **Then** a escolha fica salva e reaparece
   ao abrir o app de novo.
3. **Given** um progresso e uma arma, **When** a lista é exibida, **Then** "Para agora" traz as
   builds do estágio do usuário ou anteriores, e "Próximas" as dos estágios seguintes, esmaecidas e
   com "a partir de …".
4. **Given** um card de build, **When** exibido, **Then** mostra o nome original, o estágio, a arma,
   as peças resumidas e as principais habilidades (pt-BR).
5. **Given** uma arma e um estágio sem builds na fonte, **When** a lista é exibida, **Then** aparece
   uma mensagem clara (ex.: "Nenhuma build pronta para este ponto; veja as próximas").

---

### User Story 2 - Ver a build inteira (Priority: P2)

O caçador abre uma build e vê, em cards numerados, o equipamento completo (arma, peças por parte
com as joias de cada slot e alternativas, talismã sugerido), as habilidades somadas e o total de
joias, com a fonte.

**Why this priority**: sem o detalhe a build não pode ser montada no jogo.

**Independent Test**: abrir "Fine Kamura Cleaver Dereliction Strongarm" e conferir com a página da
Game8: arma, as 5 peças (a cintura com a alternativa), joias, talismã Olho Crítico 3 e habilidades
(Reforço de Ataque 7, Olho Crítico 7, Indignação 3…).

**Acceptance Scenarios**:

1. **Given** o detalhe, **When** aberto, **Then** mostra o cabeçalho (nome, estágio, tipo de arma,
   fonte) e os cards 1 Equipamento, 2 Habilidades e 3 Joias.
2. **Given** o card Equipamento, **When** exibido, **Then** cada item mostra a parte (arma, cabeça,
   tronco, braços, cintura, pernas, talismã), o nome em pt-BR, as joias de cada slot e, quando a
   guia der, a alternativa ("ou …"); tocar numa peça, arma ou joia abre seu detalhe no app.
3. **Given** o card Habilidades, **When** exibido, **Then** cada habilidade mostra o nível somado
   em quadradinhos até o máximo; tocar abre a habilidade.
4. **Given** um item da build que não existe no catálogo, **When** exibido, **Then** aparece pelo
   nome da fonte, marcado como "não encontrado no catálogo", sem link.

---

### User Story 3 - Minhas builds (Priority: P3)

O caçador salva uma build pronta em "Minhas builds", dá um nome a ela e pode excluí-la depois.

**Why this priority**: é a base para planejar e para a 009 (ajustar a build salva).

**Independent Test**: salvar uma build, renomear para "Meu Espadão", fechar e abrir o app, e a
build continua lá com o nome novo; excluir e ela some.

**Acceptance Scenarios**:

1. **Given** o detalhe de uma build pronta, **When** o usuário toca em "Salvar em Minhas builds",
   **Then** uma cópia aparece na aba Minhas builds, indicando de qual build veio.
2. **Given** uma build salva, **When** o usuário a renomeia ou exclui, **Then** a mudança fica salva
   no aparelho.
3. **Given** Minhas builds vazia, **When** aberta, **Then** explica como salvar uma build.
4. **Given** uma build salva, **When** aberta, **Then** mostra o mesmo detalhe da build pronta.

---

### Edge Cases

- Peça com alternativa ("Chaotic Faulds / Nephilim Tassets"): a primeira é a principal, as outras
  aparecem como "ou …".
- Item da guia ausente no catálogo (nome diferente, item cortado): marcado e listado no relatório da
  importação; a build continua aparecendo.
- Builds só de pós-jogo para uma arma: "Para agora" vazio com mensagem; as próximas aparecem.
- Rank Baixo com poucas ou nenhuma build: mensagem explicando.
- Falha ao carregar o arquivo de builds: só o Assistente mostra o erro; Monstros, Armas e Armaduras
  funcionam.
- Falha ao gravar Minhas builds no aparelho: aviso, sem perder as builds já salvas.
- Texto a 200 % em 320 dp: sem cortes; o seletor de progresso e os tipos de arma rolam.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A área Assistente DEVE ficar disponível na navegação, com as abas Recomendadas, Minhas
  builds e Montar build (esta "em breve" até a 009).
- **FR-002**: O seletor de progresso DEVE oferecer Baixo (1–3★), Alto (4–7★), Mestre (M1–M6★) e
  Pós-jogo (MR 10+, 50+, 100+, 140+, 180+), e o tipo de arma (14 tipos); a escolha DEVE ficar salva
  no aparelho.
- **FR-003**: O catálogo DEVE conter as builds prontas das páginas da Game8 de cada tipo de arma
  (Rank Mestre e Rank Alto), cada uma com nome original, estágio, arma, peças com alternativas,
  joias por slot, talismã sugerido (habilidade, nível, slots), habilidades resultantes e habilidades
  Rampage, com a página de origem.
- **FR-004**: Cada estágio da fonte DEVE ser mapeado para um ponto do seletor de progresso, com a
  regra documentada (ex.: "MR 1–2" → M1★; "MR 6+" → M6★; "MR 100+" → Pós-jogo MR 100+).
- **FR-005**: A lista DEVE separar "Para agora" (estágio menor ou igual ao do usuário) e "Próximas"
  (estágio maior), na ordem de estágio, para o tipo de arma escolhido.
- **FR-006**: O detalhe DEVE mostrar os cards 1 Equipamento, 2 Habilidades e 3 Joias, e a fonte com
  link; itens do catálogo DEVEM levar ao seu detalhe no app.
- **FR-007**: O usuário DEVE poder salvar uma build pronta, renomear e excluir builds salvas, com
  tudo guardado no aparelho.
- **FR-008**: Itens da fonte que não existem no catálogo DEVEM ser marcados na build e listados no
  relatório da importação.
- **FR-009**: Os dados DEVEM funcionar offline e carregar de forma independente: uma falha nas
  builds NÃO DEVE afetar as outras áreas.
- **FR-010**: As telas novas DEVEM seguir a acessibilidade da constituição (320 dp/200 %, contraste
  AA, alvos de 48 dp, semântica) e os nomes DEVEM seguir a preferência de idioma.

### Key Entities *(include if feature involves data)*

- **Build pronta**: nome, estágio, tipo de arma, arma, peças por parte (com alternativas), joias por
  slot, talismã sugerido, habilidades resultantes, Rampage, fonte.
- **Estágio**: o ponto do jogo em que a build fica disponível (rank e estrela, ou faixa de
  pós-jogo).
- **Progresso do usuário**: o estágio e o tipo de arma escolhidos.
- **Build salva**: uma cópia de uma build pronta, com nome dado pelo usuário e data.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Os 14 tipos de arma têm builds prontas de Rank Mestre, e 100 % das builds da fonte
  estão no catálogo, ou listadas no relatório com o motivo.
- **SC-002**: Numa amostra de 10 builds (tipos diferentes), equipamento, joias, talismã e
  habilidades conferem com a página da fonte; ao menos 95 % dos itens das builds existem no
  catálogo.
- **SC-003**: Com o progresso já escolhido, o usuário vê as builds para agora em 1 toque ao abrir o
  Assistente.
- **SC-004**: Uma build salva continua disponível depois de fechar e abrir o app, em 100 % dos
  casos.
- **SC-005**: Com os dados de builds indisponíveis, 100 % dos cenários das outras áreas continuam
  funcionando.
- **SC-006**: Nenhuma regressão nos cenários das features 001 a 007.

## Assumptions

- A fonte é a Game8 (páginas de builds por arma da Rise: Sunbreak para o Rank Mestre e da Rise base
  para o Rank Alto). O app guarda a composição das builds (fatos sobre o jogo) com crédito e link,
  não o texto das guias. Projeto pessoal de estudo, como nas features anteriores.
- Os nomes das builds ficam como na fonte (inglês); peças, joias, habilidades e arma aparecem em
  pt-BR pelo catálogo.
- A disponibilidade segue o estágio indicado pela guia, não uma estimativa pelas peças.
- O Rank Baixo pode ter poucas ou nenhuma build, porque a fonte quase não as tem.
- Fora do escopo: o otimizador e a busca por habilidades (009), os talismãs do usuário, os
  aprimoramentos Qurious, a edição de peças das builds salvas (009), World e Wilds, e a IA (010).
- O visual segue a direção da 005 e o mockup desta feature.
