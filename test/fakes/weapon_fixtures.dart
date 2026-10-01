import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_material.dart';
import 'package:mh_wiki/features/weapons/domain/entities/estimated_stars.dart';
import 'package:mh_wiki/core/domain/material_cost.dart';
import 'package:mh_wiki/core/domain/material_sources.dart';
import 'package:mh_wiki/features/weapons/domain/entities/sharpness.dart';
import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_special.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_traits.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_type.dart';

const greatSword = WeaponType(
  id: 'great-sword',
  name: LocalizedText(en: 'Great Sword', ptBr: 'Espadão'),
  ranged: false,
);
const bowType = WeaponType(
  id: 'bow',
  name: LocalizedText(en: 'Bow', ptBr: 'Arco'),
  ranged: true,
);

const sharpnessFixture = Sharpness(
  base: [130, 100, 40, 50, 20, 10, 0],
  handicraft: [130, 100, 40, 50, 20, 60, 0],
);

WeaponId wid(String slug, {Game game = Game.riseSunbreak}) =>
    WeaponId(game, slug);

MaterialCost cost(
  String id,
  String en, {
  int? quantity,
  int? points,
  MaterialSources sources = MaterialSources.none,
}) => MaterialCost(
  material: MonsterMaterial(
    id: id,
    name: LocalizedText(en: en),
  ),
  quantity: points == null ? (quantity ?? 1) : null,
  points: points,
  sources: sources,
);

Weapon buildWeapon(
  String slug, {
  String? en,
  String? ptBr,
  WeaponType type = greatSword,
  int rarity = 1,
  String tree = 'anjanath-tree',
  String treeEn = 'Anjanath Tree',
  int attack = 100,
  int affinity = 0,
  List<WeaponSpecial> special = const [],
  List<int> slots = const [],
  int rampageSlot = 0,
  String? previous,
  List<String> next = const [],
  List<MaterialCost> forge = const [],
  List<MaterialCost> upgrade = const [],
  int stars = 1,
  String? imageAsset,
  WeaponTraits traits = WeaponTraits.none,
}) => Weapon(
  id: wid(slug),
  type: type,
  name: LocalizedText(en: en ?? slug, ptBr: ptBr),
  description: const LocalizedText(en: 'A weapon.'),
  rarity: rarity,
  treeId: tree,
  treeName: LocalizedText(en: treeEn),
  attack: attack,
  affinity: affinity,
  special: special,
  slots: slots,
  rampageSlot: rampageSlot,
  sharpness: type.ranged ? null : sharpnessFixture,
  previous: previous == null ? null : wid(previous),
  next: [for (final n in next) wid(n)],
  forge: forge,
  upgrade: upgrade,
  stars: EstimatedStars(value: stars),
  imageAsset: imageAsset,
  traits: traits,
);

/// The Anjanath Great Sword tree of Rise (real values), plus a branch, a
/// ranged weapon and a second tree.
List<Weapon> anjanathWeapons() => [
  buildWeapon(
    'flammenzahn-i',
    en: 'Flammenzahn I',
    rarity: 3,
    attack: 140,
    affinity: -20,
    special: const [WeaponSpecial(kind: SpecialKind.fire, value: 20)],
    next: ['flammenzahn-ii'],
    forge: [cost('anjanath-scale', 'Anjanath Scale', quantity: 2)],
  ),
  buildWeapon(
    'flammenzahn-ii',
    en: 'Flammenzahn II',
    rarity: 5,
    attack: 200,
    affinity: -20,
    previous: 'flammenzahn-i',
    next: ['gnashing-flammenzahn'],
    stars: 5,
  ),
  buildWeapon(
    'gnashing-flammenzahn',
    en: 'Gnashing Flammenzahn',
    rarity: 6,
    attack: 220,
    affinity: -20,
    previous: 'flammenzahn-ii',
    next: ['gnashing-flammenzahn-plus'],
    stars: 6,
  ),
  buildWeapon(
    'gnashing-flammenzahn-plus',
    en: 'Gnashing Flammenzahn+',
    ptBr: 'Presardente Rangedora+',
    rarity: 8,
    attack: 280,
    affinity: -20,
    special: const [WeaponSpecial(kind: SpecialKind.fire, value: 28)],
    slots: const [3],
    rampageSlot: 2,
    previous: 'gnashing-flammenzahn',
    next: ['lohenzahn', 'lohenzahn-alt'],
    upgrade: [
      cost('anjanath-hardfang', 'Anjanath Hardfang', quantity: 3),
      cost('heavy-anjanath-nosebone', 'Heavy Anjanath Nosebone', quantity: 2),
      cost('anjanath-material-s', 'Anjanath Material(s)', points: 10),
    ],
    stars: 4,
  ),
  buildWeapon(
    'lohenzahn',
    en: 'Lohenzahn',
    rarity: 9,
    attack: 320,
    previous: 'gnashing-flammenzahn-plus',
    stars: 5,
  ),
  buildWeapon(
    'lohenzahn-alt',
    en: 'Aardzahn',
    rarity: 9,
    attack: 310,
    previous: 'gnashing-flammenzahn-plus',
    stars: 5,
  ),
  buildWeapon(
    'bone-blade',
    en: 'Bone Blade',
    tree: 'bone-tree',
    treeEn: 'Bone Tree',
    attack: 80,
  ),
  buildWeapon(
    'hunters-bow',
    en: "Hunter's Bow",
    type: bowType,
    tree: 'bone-tree',
    treeEn: 'Bone Tree',
    attack: 90,
  ),
];

WeaponCatalog weaponCatalog([List<Weapon>? weapons]) => WeaponCatalog(
  game: Game.riseSunbreak,
  types: const [greatSword, bowType],
  weapons: weapons ?? anjanathWeapons(),
);
