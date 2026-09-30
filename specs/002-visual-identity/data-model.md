# Data Model: Identidade Visual (002-visual-identity)

No schema change: the dataset schema v1 of feature 001
([monster-dataset.schema.json](../001-monster-wiki/contracts/monster-dataset.schema.json)) already
has the optional per-monster `image` field.

## Data changes

| Where | Change |
|-------|--------|
| `assets/data/<game>/monsters.json` → each monster | `image`: `assets/images/monsters/<game>/<slug>.webp` |
| `assets/data/<game>/monsters.json` → `sources` | new entry "Monster Hunter Wiki (icons)" with the icon URL pattern |
| `assets/images/monsters/<game>/<slug>.webp` | 30 files, 256×256 WebP with transparency |

## Domain addition

### WeaknessProfile.primaryWeakness (derived)

| Rule | Value |
|------|-------|
| `mostEffective` empty | `null` (list shows no primary weakness) |
| otherwise | first of `mostEffective` in order fire, water, thunder, ice, dragon |

## Presentation tokens (not data; for reference)

| Token | Value |
|-------|-------|
| background | `#16120E` |
| panel | `#1F1812` |
| panel border | `#5A4526` (strong) / `#3B2E1D` (subtle) |
| gold (accent) | `#E0BD6A` (hover/emphasis `#F3D68E`, frame `#8A6A33`) |
| text | `#EFE4C8` |
| muted text | `#B9A67F` |
| text on gold | `#1C150D` |
| fire / water / thunder / ice / dragon | `#F07A4A` / `#6FB2F0` / `#F0CF4A` / `#A9E2F2` / `#C592F0` |
