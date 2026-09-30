<!--
Sync Impact Report
- Version change: (template, unversioned) → 1.0.0
- Modified principles: n/a (initial ratification; all placeholders replaced)
- Added principles:
  I. Clean Architecture por Feature
  II. Presentation em MVC
  III. Regra de Dependência e Injeção Explícita
  IV. Offline-First com Dados Versionados
  V. Multi-Jogo como Conceito de Primeira Classe
  VI. Testes Obrigatórios (TDD Preferido)
  VII. Idioma, Internacionalização e Lints
- Added sections: Restrições Técnicas e de Dados; Fluxo de Desenvolvimento e Quality Gates; Governance
- Removed sections: none
- Templates reviewed (not modified; they read the constitution at runtime):
  ✅ .specify/templates/plan-template.md (Constitution Check gate aplica-se a I–VII)
  ✅ .specify/templates/spec-template.md (sem conflito)
  ✅ .specify/templates/tasks-template.md (tarefas de teste obrigatórias conforme VI)
- Deferred TODOs: none
-->

# MH Wiki (Monster Hunter Flutter) Constitution

## Core Principles

### I. Clean Architecture por Feature

O código DEVE ser organizado por feature (`lib/features/<feature>/`), e cada feature DEVE conter
as camadas `domain`, `data` e `presentation`. Código compartilhado entre features fica em
`lib/core/` seguindo a mesma divisão de camadas.

- `domain` contém entidades, contratos (interfaces) de repositório e casos de uso.
- `domain` DEVE ser Dart puro: NÃO DEVE importar `package:flutter/*` nem qualquer pacote externo
  (exceto `dart:*` e código do próprio `domain`/`core/domain`).
- `data` contém DTOs/models de serialização, datasources e implementações dos repositórios.
- `presentation` contém controllers e views (ver Princípio II).

**Rationale**: isolar regras de negócio de framework e de fonte de dados mantém o domínio
testável sem Flutter e permite trocar a origem dos dados sem reescrever o app.

### II. Presentation em MVC

A camada `presentation` DEVE seguir MVC:

- **Model**: entidades do domínio e objetos imutáveis de estado de tela (ex.: carregando,
  sucesso, vazio, erro).
- **Controller**: classe que estende `ChangeNotifier`, orquestra casos de uso e expõe o estado
  de tela. Controllers NÃO DEVEM acessar datasources ou repositórios diretamente — somente casos
  de uso. Controllers NÃO DEVEM importar widgets nem depender de `BuildContext`.
- **View**: widgets que renderizam o estado e encaminham eventos ao controller. Views NÃO DEVEM
  conter lógica de negócio, filtragem, ordenação ou chamadas a casos de uso.

**Rationale**: separar estado/orquestração da renderização torna controllers testáveis por
unit tests e mantém widgets simples.

### III. Regra de Dependência e Injeção Explícita

- Dependências DEVEM apontar sempre para dentro: `presentation → domain ← data`. `domain` NÃO
  DEVE conhecer `data` nem `presentation`; `presentation` NÃO DEVE importar `data`.
- Toda dependência DEVE ser recebida pelo construtor (injeção explícita), tipada pela abstração.
- A montagem do grafo de objetos DEVE ocorrer em um único composition root (ex.:
  `lib/app/di/`). Service locators ou singletons globais NÃO DEVEM ser acessados de dentro das
  camadas; se usados, ficam restritos ao composition root.

**Rationale**: a regra de dependência é o que garante os benefícios da Clean Architecture;
injeção explícita torna cada classe substituível por fakes em testes.

### IV. Offline-First com Dados Versionados

- O app DEVE funcionar integralmente sem conexão de rede, usando datasets JSON locais
  empacotados como assets.
- Cada arquivo de dados DEVE declarar uma versão de schema (ex.: campo `schemaVersion`), e o
  datasource DEVE rejeitar ou tratar explicitamente versões desconhecidas.
- O acesso aos dados DEVE ocorrer por meio de um datasource abstrato; a implementação local
  (assets) DEVE poder ser substituída ou complementada por uma remota sem alterar `domain` nem
  `presentation`.
- DTOs DEVEM ser convertidos para entidades na camada `data`; entidades NÃO DEVEM conter lógica
  de (de)serialização.

**Rationale**: uma wiki de consulta precisa ser rápida e disponível em qualquer lugar; não há
API oficial cobrindo os três jogos, então a fonte de verdade inicial é local e versionada.

### V. Multi-Jogo como Conceito de Primeira Classe

- O conjunto de jogos suportados DEVE ser modelado explicitamente no domínio (ex.: um enum
  `Game` com World: Iceborne, Rise: Sunbreak e Wilds).
- Toda entidade de conteúdo (monstro, arma, armadura, item, habilidade, mapa etc.) DEVE
  identificar o jogo de origem, e sua identidade DEVE ser única no par (jogo, id).
- Um mesmo conceito presente em mais de um jogo (ex.: Rathalos) DEVE ser representado como
  entidades distintas por jogo; vínculos entre jogos, se existirem, são explícitos e opcionais.
- Toda listagem ou busca DEVE permitir filtrar por jogo.

**Rationale**: dados, mecânicas e balanceamento diferem entre jogos; misturá-los implicitamente
gera informação incorreta na wiki.

### VI. Testes Obrigatórios (TDD Preferido)

- Casos de uso e entidades do `domain` DEVEM ter testes unitários.
- Controllers DEVEM ter testes unitários cobrindo transições de estado (sucesso, vazio, erro).
- Views críticas (listas e telas de detalhe principais, navegação entre elas) DEVEM ter widget
  tests.
- Implementações de datasource/repositório DEVERIAM ter testes que carregam os datasets reais e
  validam o parsing.
- TDD (red → green → refactor) é o fluxo preferido: o teste que falha DEVERIA existir antes da
  implementação.
- Nenhuma alteração é considerada concluída com testes falhando.

**Rationale**: a arquitetura em camadas só entrega valor se cada camada for verificável
isoladamente; testes são a prova disso.

### VII. Idioma, Internacionalização e Lints

- Identificadores, comentários, nomes de arquivos e mensagens de commit DEVEM estar em inglês.
- A UI DEVE estar em pt-BR, e todo texto visível ao usuário DEVE vir de recursos de localização
  (i18n); strings de UI NÃO DEVEM ser hardcoded em widgets. A adição de novos idiomas NÃO DEVE
  exigir mudança de código de feature.
- O projeto DEVE usar `flutter_lints` (ou conjunto mais estrito) e `flutter analyze` DEVE
  terminar sem erros, warnings ou infos pendentes. Supressões de lint DEVEM ser pontuais e
  justificadas em comentário.
- O código DEVE estar formatado com `dart format`.

**Rationale**: consistência de idioma facilita manutenção; i18n desde o início evita
retrabalho; lints limpos mantêm a qualidade uniforme.

## Restrições Técnicas e de Dados

- Stack: Flutter (canal stable) e Dart 3, com null safety e recursos da linguagem Dart 3
  (records, patterns, sealed classes) permitidos e encorajados para estados e resultados.
- Gerenciamento de estado na presentation DEVE usar `ChangeNotifier` do próprio Flutter;
  a adoção de bibliotecas de estado adicionais exige emenda a esta constituição.
- Novos pacotes externos DEVEM ser justificados no `plan.md` da feature (motivo, alternativa
  descartada) e NÃO DEVEM ser usados na camada `domain`.
- Erros esperados (dado ausente, schema inválido, falha de datasource) DEVEM ser modelados
  explicitamente (ex.: tipos de falha/resultados) em vez de exceções não tratadas chegando à UI.
- Dados de conteúdo dos jogos DEVEM registrar sua origem/fonte no dataset para permitir
  auditoria e atualização.

## Fluxo de Desenvolvimento e Quality Gates

- Toda feature segue o fluxo Spec Kit: `/speckit-specify` → (`/speckit-clarify`) →
  `/speckit-plan` → `/speckit-tasks` → (`/speckit-analyze`) → `/speckit-implement`, em branch
  própria.
- O `plan.md` DEVE conter um Constitution Check que verifique os Princípios I–VII; violações
  DEVEM ser justificadas na seção de complexidade ou a proposta deve ser revista.
- Gates obrigatórios antes de considerar uma feature concluída:
  1. `flutter analyze` sem ocorrências;
  2. `dart format --set-exit-if-changed .` sem diferenças;
  3. `flutter test` passando integralmente;
  4. Nenhum import proibido pela regra de dependência (Princípios I e III).
- Features DEVERIAM ser entregues como fatias verticais pequenas (domain + data + presentation
  funcionando de ponta a ponta) em vez de camadas isoladas.

## Governance

- Esta constituição prevalece sobre qualquer outra prática ou convenção do projeto. Em caso de
  conflito entre um artefato (spec, plan, tasks, código) e esta constituição, a constituição vence.
- Emendas DEVEM ser feitas via `/speckit-constitution`, com Sync Impact Report atualizado,
  justificativa e, quando houver impacto em código existente, um plano de migração.
- Versionamento semântico:
  - MAJOR: remoção ou redefinição incompatível de princípios ou regras de governança;
  - MINOR: novo princípio/seção ou expansão material de orientação;
  - PATCH: esclarecimentos, redação e correções sem mudança semântica.
- Toda revisão de plano, tarefas e código DEVE verificar conformidade com os Princípios I–VII;
  complexidade adicional DEVE ser justificada.

**Version**: 1.0.0 | **Ratified**: 2026-09-29 | **Last Amended**: 2026-09-29
