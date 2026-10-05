import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';

LocalizedText _n(String en) => LocalizedText(en: en, ptBr: '$en (pt)');

OptimizerSkill skill(String id, int max) =>
    OptimizerSkill(id: id, name: _n(id), max: max);

OptimizerDecoration jewel(
  String id,
  String skill,
  int slot, {
  int points = 1,
}) => OptimizerDecoration(
  id: id,
  name: _n(id),
  slot: slot,
  skill: skill,
  points: points,
);

OptimizerPiece piece(
  String id,
  BuildPart part, {
  int rarity = 10,
  List<int> slots = const [],
  int defense = 100,
  Map<String, int> skills = const {},
}) => OptimizerPiece(
  id: id,
  name: _n(id),
  part: part,
  rarity: rarity,
  slots: slots,
  defense: defense,
  skills: skills,
);

OptimizerWeapon weapon(
  String id, {
  String type = 'great-sword',
  int rarity = 10,
  List<int> slots = const [],
  int attack = 200,
  String? trait,
  List<String> elements = const [],
}) => OptimizerWeapon(
  id: id,
  name: _n(id),
  type: type,
  rarity: rarity,
  slots: slots,
  attack: attack,
  trait: trait == null ? null : (key: trait, name: _n(trait)),
  elements: elements,
);

/// A tiny catalog where "attack" reaches 7 only with the right pieces and
/// jewels, and "crit" only with jewels or a talisman.
OptimizerCatalog fixtureCatalog() => OptimizerCatalog(
  game: Game.riseSunbreak,
  skills: [
    skill('attack', 7),
    skill('crit', 7),
    skill('guard', 5),
    skill('nodeco', 3),
  ],
  decorations: [
    jewel('attack-2', 'attack', 2),
    jewel('attack+4', 'attack', 4, points: 2),
    jewel('crit-2', 'crit', 2),
    jewel('guard-3', 'guard', 3),
  ],
  pieces: [
    // Head: a strong one, a dominated one, an identical-profile twin and
    // a rarity-8 one.
    piece(
      'head-a',
      BuildPart.head,
      skills: {'attack': 2},
      slots: [2],
      defense: 150,
    ),
    piece(
      'head-b',
      BuildPart.head,
      skills: {'attack': 1},
      slots: [1],
      defense: 300,
    ),
    piece(
      'head-twin',
      BuildPart.head,
      skills: {'attack': 2},
      slots: [2],
      defense: 120,
    ),
    piece(
      'head-low',
      BuildPart.head,
      rarity: 8,
      skills: {'attack': 1},
      slots: [4],
    ),
    piece('chest-a', BuildPart.chest, skills: {'attack': 2}, slots: [2, 2]),
    piece('chest-slots', BuildPart.chest, slots: [4, 4, 2]),
    piece('arms-a', BuildPart.arms, skills: {'attack': 1}, slots: [4]),
    piece('waist-a', BuildPart.waist, skills: {'crit': 2}, slots: [1]),
    piece(
      'legs-a',
      BuildPart.legs,
      skills: {'attack': 1, 'nodeco': 1},
      slots: [3, 2],
    ),
  ],
  weapons: [
    weapon('sword-4', slots: [4], attack: 300),
    weapon('sword-21', slots: [2, 1], attack: 250),
    weapon('sword-weak', slots: [1], attack: 100),
    weapon('sword-low', rarity: 7, slots: [3]),
    weapon('bow', type: 'bow', slots: [4, 4, 4]),
    weapon('cb-impact', type: 'charge-blade', slots: [4], trait: 'impact'),
    weapon(
      'cb-element',
      type: 'charge-blade',
      slots: [4, 4],
      trait: 'element',
      elements: ['fire'],
    ),
    weapon(
      'cb-ice',
      type: 'charge-blade',
      slots: [2],
      trait: 'element',
      elements: ['ice'],
    ),
  ],
);
