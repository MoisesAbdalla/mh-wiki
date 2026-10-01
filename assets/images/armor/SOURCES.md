# Armor icons

| Folder | Source |
|--------|--------|
| `rise_sunbreak/<piece-id>.webp` | The piece's male render on its [Kiranico](https://mhrise.kiranico.com/data/armors) list (`avatar/armors/<id>_m.webp`) |

The icons are artwork of Capcom. They are used locally in this personal study project, the same
way as the monster and weapon icons. A public release would have to replace them.

`python tool/data/build_rise_armor.py --icons` makes these files as 96 px WebP with alpha. A piece
whose icon cannot be downloaded (89 return 404) has no `image` in `armor.json`, and the app shows
the plate's marker instead.
