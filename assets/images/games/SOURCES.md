# Game logos

| File | Source |
|------|--------|
| `world_iceborne.webp` | [MHWI-Logo.png](https://monsterhunterwiki.org/wiki/File:MHWI-Logo.png), Monster Hunter Wiki |
| `rise_sunbreak.webp` | [MHRS-Logo.png](https://monsterhunterwiki.org/wiki/File:MHRS-Logo.png), Monster Hunter Wiki |
| `wilds.webp` | [MHWilds-Logo.png](https://monsterhunterwiki.org/wiki/File:MHWilds-Logo.png), Monster Hunter Wiki |

The logos are trademarks and artwork of Capcom. They are used locally in this personal study
project, the same way as the monster icons (feature 001). A public release would have to replace
them.

`tool/data/fetch_game_logos.py` makes these files: it trims each logo to its bounding box and saves
it as a 138 px tall WebP with alpha.
