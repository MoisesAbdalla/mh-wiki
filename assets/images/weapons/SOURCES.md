# Weapon icons

| Folder | Source |
|--------|--------|
| `rise_sunbreak/<slug>.webp` | The weapon's icon on its [Kiranico](https://mhrise.kiranico.com/data/weapons) page (`avatar/weapons/<id>.webp`) |
| `types/<type-id>.webp` | `MHRS-<Type> Icon Rare 1.png` on the [Monster Hunter Wiki](https://monsterhunterwiki.org/wiki/Special:FilePath/MHRS-Great_Sword_Icon_Rare_1.png) |

The icons are artwork of Capcom. They are used locally in this personal study project, the same
way as the monster icons (feature 001). A public release would have to replace them.

`python tool/data/build_rise_weapons.py --icons` makes these files: it downloads each icon and
saves it as a 96 px WebP with alpha. A weapon whose icon cannot be downloaded has no `image` in
`weapons.json`, and the app shows the plate's marker instead.
