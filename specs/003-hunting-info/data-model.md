# Data Model: Informações de Caçada (003-hunting-info)

Additive to feature 001's model and schema v1 (see research R5).

## Dataset level

### partyHpFactors (optional)

```json
"partyHpFactors": {
  "2": {"min": 1.5, "max": 1.5},
  "3": {"min": 2.2, "max": 2.6},
  "4": {"min": 2.2, "max": 2.6},
  "source": {"name": "Fextralife", "url": "https://…", "notes": "about 150% / 220%–260%"}
}
```
Absent → party HP "Desconhecido" (Rise).

### huntingItems

```json
"huntingItems": [{"id": "flash", "name": {"en": "Flash Pod"}}, …]
```
Ids: `flash`, `sonic`, `dung`, `pitfallTrap`, `shockTrap`. Names per game (Rise: "Flash Bomb",
"Sonic Bomb", "Dung Bomb"; World/Wilds: "Flash Pod", "Screamer Pod", "Dung Pod").

## Monster level

### hp (optional list)

| Field | Type | Rules |
|-------|------|-------|
| `rank` | Rank | allowed for the game; unique in the list |
| `solo` | int | > 0 |
| `basis` | `expedition` \| `minQuest` | `minQuest` → UI shows "a partir de" |

### itemReactions (optional list)

| Field | Type | Rules |
|-------|------|-------|
| `item` | item id | must be in the dataset's `huntingItems` |
| `effect` | `affects` \| `noEffect` \| `conditional` \| `unknown` | |
| `detail` | LocalizedText? | e.g. "Duração: 10 s", "50% de chance de fugir"; required for `conditional` |

Items of the game missing from the list → "Desconhecido"; items not in `huntingItems` → "Não se
aplica" (not shown as a row).

## Domain

- `HuntingInfo { List<RankHp> hp; PartyHpFactors? partyFactors; List<ItemReaction> reactions;
  Vision vision }`, built by the mapper.
- `RankHp.partyEstimate(players)` → `(min, max)` rounded to the nearest 10, or `null` without
  factors.
- `Vision` derived (research R4): `sees` if the `flash` reaction is `affects`/`conditional`,
  else `unknown`.
- Validation (DTO): hp ranks unique and allowed; `solo > 0`; reaction items exist; `conditional`
  has `detail`; factors 2–4 with `0 < min ≤ max`.
