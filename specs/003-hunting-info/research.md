# Research: Informações de Caçada (003-hunting-info)

**Date**: 2026-09-30 | **Plan**: [plan.md](plan.md) | **Spec**: [spec.md](spec.md)

## R1. Solo HP per rank

- **World: Iceborne**: Kiranico monster page, "Expeditions" table (1 player): one row per rank
  with locale and HP (Rathalos: LR 4,908 / HR 6,565 / MR 20,800). Reference = lowest expedition
  HP of the rank (`basis: expedition`). Monsters without expeditions (e.g. Alatreon): lowest HP of
  the rank's regular quests (`basis: minQuest`), classified by the quest's star prefix (★1–5 LR,
  ★6–9 HR, M★ MR). Kiranico ignores the `players` URL parameter, so only solo HP is used.
- **Rise: Sunbreak**: Kiranico monster page, "Quests" table: category + stars + HP (sometimes
  three values for size variants). Regular categories only: `Village` (LR), `Gathering Hub`
  1–3★ (LR) and 4–7★ (HR), `MR` (MR). Excluded: Event, Arena, Anomaly, Follower, Rampage,
  Challenge, Gathering Hub 8★ (special). Reference = lowest HP of the rank (`basis: minQuest`,
  shown as "a partir de").
- **Wilds**: Kiranico quest list (`/data/quests`): "[Category N★] name", monsters and HP per
  monster. Regular categories only (`Assignments`, `Optional`); rank taken from the quest page's
  rank label, never guessed from stars; quests whose rank cannot be read are skipped. Reference =
  lowest HP of the rank (`basis: minQuest`). The monster page's `BaseHealth` is a raw base value,
  not a quest HP, and is not used.
- **Decision**: store per monster `hp: [{rank, solo, basis, source}]`; absent ranks are omitted.

## R2. Party HP (estimate)

Per-game factors, stored once in each dataset (`partyHpFactors`), applied to the solo HP in the
app and always labeled "aprox." with the source:

| Game | 2 players | 3 players | 4 players | Source |
|------|-----------|-----------|-----------|--------|
| World: Iceborne | ×1.5 | ×2.2–2.6 | ×2.2–2.6 | [Fextralife – Multiplayer](https://monsterhunterworld.wiki.fextralife.com/Multiplayer) ("about 150%", "about 220%–260%") |
| Rise: Sunbreak | — | — | — | No numeric source ([Game8](https://game8.co/games/Monster-Hunter-Rise/archives/322653) gives none) → "Desconhecido" |
| Wilds | ×1.63 | ×2.00 | ×2.34 | Community testing, [Switchblade Gaming](https://www.switchbladegaming.com/monster-hunter-wilds/multiplayer/) |

- **Rationale**: user decision (clarify Q2 = A): a sourced, labeled estimate beats no information;
  nothing unsourced is shown.

## R3. Hunting item reactions

Source: Monster Hunter Wiki game pages (`<Name>_(MHWI)`, `_(MHRS)`, `_(MHWilds)`):

1. Infobox row **Meat · Dung Pods · Flash Pods · Sonic/Screamer Pods** (World and Wilds):
   Dung = % chance to make the monster leave; Flash and Sonic = ✓ / ✗; ✓ may carry a condition in
   parentheses; per the wiki, ✗ means "does nothing outside its universal effects" → `noEffect`.
2. **"Trap & Flash Pod Effectiveness"** table (all three games): Pitfall Trap, Shock Trap and Flash
   Pod/Bomb durations (Rise has no infobox row, so Flash Bomb comes from here, as do Dung Bomb and
   Sonic Bomb from its "Other Items" table).
- **Mapping**: duration > 0 s → `affects` (duration kept); `0s` → `noEffect`; `-` → `unknown`;
  ✓ → `affects` (or `conditional` with the text in parentheses); ✗ → `noEffect`; Dung % > 0 →
  `affects` with "N% de chance de fugir", otherwise `unknown`. When the infobox and the trap
  table disagree about the Flash Pod (seen on Wilds Rathalos: ✓ vs 0s), the infobox wins and
  the conflict is logged in the monster's `sources[].notes`.
- **Items per game** (anything else = not applicable): World/Wilds: Flash Pod, Screamer Pod, Dung
  Pod, Pitfall Trap, Shock Trap; Rise: Flash Bomb, Sonic Bomb, Dung Bomb, Pitfall Trap, Shock Trap.
  Item names are stored per dataset (en; pt-BR only when a verified official name exists).

## R4. Vision

- **Decision**: `sees` when the Flash item affects the monster; otherwise `unknown` (the sources
  never state blindness explicitly, and "not affected by flash" has other causes). Spec
  assumption honored: the app never claims "não enxerga" without a source saying so.

## R5. Schema evolution

- **Decision**: add optional fields to schema v1 (`partyHpFactors`, `huntingItems` at dataset
  level; `hp`, `itemReactions` per monster). Old files stay valid; the parser treats missing
  fields as "Desconhecido". No `schemaVersion` bump (additive, backward compatible).
- **Alternatives**: bump to v2 (needs migration of all files for no behavioural gain).

## R6. Group behaviour ("anda em grupo")

- Out of scope (clarify Q2 = A): no structured source in Kiranico or the Monster Hunter Wiki.
