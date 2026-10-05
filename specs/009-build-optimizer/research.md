# Research: Otimizador de builds (Montar build)

## R1. What the catalog gives the optimizer

Measured on `assets/data/rise_sunbreak/` (2026-10-05):
- **Pieces**: 1,371, each with a part, a rarity (1–10), up to 3 slots (levels 1–4), skills with
  levels, and a max defense. 236 pieces have a level-4 slot (rarity 8–10 only).
- **Decorations**: 243. Each one gives **one** skill, 1 to 5 points, and fits a slot of its level
  or higher:
  - `Attack Jewel 2` is Attack Boost +1 in a level-2 slot;
  - `Attack Jewel+ 4` is Attack Boost +2 in a level-4 slot.
  - 128 of the 147 skills have at least one decoration.
- **Weapons**: 3,925 with type, rarity and slots. They give no skills in our catalog; Rampage
  skills and Rampage decorations are left out (spec FR-006).
- **Skills**: 147 with their max level. Sunbreak set bonuses (e.g. "Mail of Hellfire") are skills
  on the pieces like any other, so they sum the same way.

- **Decision**: a skill's level in a set is the sum of the pieces, the talisman and the
  decorations, capped at the skill's max level.

## R2. A compact dataset for the optimizer

- **Decision**: a Python step writes `assets/data/rise_sunbreak/optimizer.json` (schemaVersion 1)
  from `armor.json` and `weapons.json`. It holds only what the search and the result need:
  - skills: id, names, max level;
  - pieces: id, names, part, rarity, slots, skills, max defense;
  - decorations: id, names, slot level, skill, points;
  - weapons: slug, names, type, rarity, slots, attack, image.
- Estimated size is about 1 MB, against 8.9 MB for `weapons.json`.
- **Rationale**:
  - The assistant feature stays independent of the armor and weapons features (constitution I and
    III), like the 008 builds that carry their own names.
  - Loading is quick, and the data can be sent to a background isolate cheaply.
- **Alternatives**:
  - Reuse the armor and weapon repositories: this couples three features, and the full weapons
    file is large.
  - A combined catalog shared by all features: a bigger refactor that 009 does not need.

## R3. Progress → rarity

Highest piece or weapon rarity in the 008 curated builds, by stage:

| Stage | Max rarity seen |
|-------|-----------------|
| Baixo 1–2★ | 2–3 |
| Alto 4★ | 4–7 (mostly 5) |
| Alto 6–7★ | 6–7 |
| Mestre M1★ | 8 |
| Mestre M3★ | 9 (one 10) |
| Mestre M6★ | 10 |
| Pós-jogo (all bands) | 10 |

- **Decision**: the highest allowed rarity for each step:

  | Rank | Steps → max rarity |
  |------|--------------------|
  | Baixo | 1★–3★ → 3 |
  | Alto | 4★ → 5, 5★ → 6, 6★ → 7, 7★ → 7 |
  | Mestre | M1–M2★ → 8, M3–M4★ → 9, M5–M6★ → 10 |
  | Pós-jogo | all bands → 10 |

- **Rationale**: this matches the curated builds, which were written for those stages, and the
  game's rarity bands.
- **Limitation**: inside rarity 10, the gates by Master Rank level (Risen elders, Anomaly / Afflicted
  pieces) are not modelled. The spec already lists this under "Só peças do meu progresso". It is a
  rarity filter, and the quickstart notes it.

## R4. Search algorithm

The search space is far too big to try every combination: 300+ candidates per part at rarity 10,
about 10¹² sets. The decision has five parts.

### 1. Reduce each choice to its useful candidates

- A piece's **profile** is two things:
  - the points of each **wanted** skill, capped at the wanted level;
  - its slot levels, sorted from highest to lowest.
- **Pareto pruning per part**: a piece is dropped when another piece of the same part is at least
  as good in every wanted skill and in every slot position.
  - Among pieces with an identical profile, the one with the highest max defense is kept.
  - Ties are kept as "alternatives", so the result can show "ou …" like the 008 detail.
- **Weapons**: pareto on slots only. Among weapons with equal slots, the highest attack wins, then
  the highest rarity. A fixed weapon is the only candidate.
- **Talismans**: each user talisman, plus "none", pruned the same way.

### 2. Combine the parts by dynamic programming over states

The parts are combined in this order: weapon, talisman, head, chest, arms, waist, legs.

- **State**: the capped wanted-skill vector, plus the count of free slots of each level (1–4).
- After each part, only the pareto-optimal states are kept, each with up to *k* back-pointers to the
  sets that reach it (*k* = 3, for variety).
- The state count is bounded by the product of (wanted level + 1) over the wanted skills, times the
  slot combinations. For 4 skills at 7/7/3/3 this is 1,024 skill vectors. Pareto pruning keeps the
  slot side small.

### 3. Exact decoration check at the end

- For each final state, a small exact search places decorations to cover the remaining deficit.
  - It is memoised on (remaining deficit, slot counts).
  - It is exact because a level-4 slot can hold a +2 jewel or a +1 jewel of a smaller level.
- Jewels go into the smallest slot that fits. The slots left over are the "free slots".

### 4. Ranking

- The order is:
  1. complete sets first;
  2. then by total deficit (for "quase" results);
  3. then by free slot levels (sum), then by free slot count;
  4. then by max defense.
- Up to 10 distinct sets are kept, by their weapon, piece and talisman choice.
- "Também vem" lists the other skills of the chosen pieces and talisman. It is computed after the
  search.

### 5. Runtime

- The search is a pure Dart function in `domain`. It runs in a background isolate, so the screen
  stays responsive (spec FR-010).
- **Cancel**: the isolate is killed. "procurando…" shows how many states it has checked.
- **Benchmark (task)**: 20 test requests on the real data must finish in ≤ 10 s on a mid-range phone
  (spec SC-002). If that fails, the fallbacks are:
  1. lower *k*;
  2. drop the alternatives during the search;
  3. cap the number of states per part, by best "progress towards the request".

- **Rationale**: pareto pruning plus dynamic programming over a capped skill vector is how the
  community set searchers work. It is exact for the "complete" question and needs no external
  solver (no new package, constitution IV).
- **Alternatives**:
  - Brute force with bounds (depth-first search with an optimistic upper bound): simple, but it
    explodes at rarity 10 with weak requests.
  - An ILP/MIP solver: there is no maintained pure-Dart solver, and it is overkill.
  - Greedy: fast but misses sets, so SC-003 would fail.

## R5. Suggested skills

- **Decision**: the suggestions are the skills that appear most often in the 008 curated builds of
  the chosen weapon type and stage band (Master/Post or High/Low).
  - The top 8 are shown, excluding skills already chosen.
  - They are computed from the build catalog the assistant already loads.

## R6. Persistence

- The request is kept in `assistant.optimizer.request.v1`, as JSON: the skills with levels, the fixed
  weapon, and the two toggles.
- The talismans are kept in `assistant.talismans.v1`, as a JSON list.
- A saved result is a `SavedBuild` with a `CuratedBuild` built from it:
  - the source is "Caderninho · Montar build", with an empty URL;
  - the stage is the user's progress;
  - the name defaults to "Espadão · Reforço de Ataque 7, Olho Crítico 7…".

## R7. Tests

- **Unit tests**:
  - capped sums;
  - pareto pruning;
  - the decoration check, including the +2 jewel in a level-4 slot and a jewel that does not fit;
  - ranking and dedupe;
  - the progress → rarity table.
- **Property test (SC-001)**: for every result of 20 requests on the real data, recompute the
  skills from pieces, talisman and decorations, and compare.
- **SC-003 test**: for each Master and Post curated build, request its skill levels with its weapon
  and no talisman; at least 95% must give a "complete" result.
- **Widget, accessibility and integration tests**, like 008.
