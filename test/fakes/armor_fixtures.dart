import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_piece.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';

Skill buildSkill(String id, String en, String pt, int maxLevel) => Skill(
  id: id,
  name: LocalizedText(en: en, ptBr: pt),
  description: LocalizedText(en: '$en description'),
  levels: [
    for (var i = 1; i <= maxLevel; i++) LocalizedText(en: '$en effect $i'),
  ],
);

final attackBoost = buildSkill(
  'attack-boost',
  'Attack Boost',
  'Reforço de Ataque',
  7,
);
final partbreaker = buildSkill('partbreaker', 'Partbreaker', 'Quebra-parte', 3);
final criticalBoost = buildSkill(
  'critical-boost',
  'Critical Boost',
  'Reforço Crítico',
  3,
);
final earplugs = buildSkill('earplugs', 'Earplugs', 'Tampões', 5);
final windproof = buildSkill('windproof', 'Windproof', 'Antivento', 3);

ArmorPiece buildPiece(
  String id,
  String en,
  BodyPart part, {
  String set = 'rathalos-x',
  String? pt,
  int rarity = 9,
  int defense = 114,
  int? maxDefense = 174,
  Resistances resistances = const Resistances(
    fire: 3,
    water: 1,
    thunder: -2,
    ice: 1,
    dragon: -3,
  ),
  List<int> slots = const [],
  List<SkillLevel> skills = const [],
}) => ArmorPiece(
  id: id,
  setId: set,
  part: part,
  name: LocalizedText(en: en, ptBr: pt),
  rarity: rarity,
  defense: defense,
  maxDefense: maxDefense,
  resistances: resistances,
  slots: slots,
  skills: skills,
);

/// Rathalos X as in the game (007 research R1), plus a low rank set.
ArmorSet rathalosX() => ArmorSet(
  id: 'rathalos-x',
  name: const LocalizedText(en: 'Rathalos X', ptBr: 'Rathalos X'),
  rarity: 9,
  pieces: [
    buildPiece(
      'rathalos-helm-x',
      'Rathalos Helm X',
      BodyPart.head,
      pt: 'Elmo de Rathalos X',
      slots: const [4],
      skills: const [
        SkillLevel('attack-boost', 1),
        SkillLevel('partbreaker', 1),
        SkillLevel('critical-boost', 1),
      ],
    ),
    buildPiece(
      'rathalos-mail-x',
      'Rathalos Mail X',
      BodyPart.chest,
      pt: 'Arm. de Rathalos X',
      slots: const [3],
      skills: const [
        SkillLevel('attack-boost', 1),
        SkillLevel('partbreaker', 1),
        SkillLevel('earplugs', 1),
      ],
    ),
    buildPiece(
      'rathalos-braces-x',
      'Rathalos Braces X',
      BodyPart.arms,
      pt: 'Avamb. de Rathalos X',
      slots: const [2],
      skills: const [SkillLevel('attack-boost', 2), SkillLevel('earplugs', 2)],
    ),
    buildPiece(
      'rathalos-coil-x',
      'Rathalos Coil X',
      BodyPart.waist,
      pt: 'Cint. de Rathalos X',
      slots: const [2],
      skills: const [
        SkillLevel('attack-boost', 2),
        SkillLevel('windproof', 3),
        SkillLevel('critical-boost', 1),
      ],
    ),
    buildPiece(
      'rathalos-greaves-x',
      'Rathalos Greaves X',
      BodyPart.legs,
      pt: 'Grevas de Rathalos X',
      slots: const [1, 1],
      skills: const [
        SkillLevel('attack-boost', 1),
        SkillLevel('partbreaker', 1),
        SkillLevel('earplugs', 2),
      ],
    ),
  ],
);

ArmorSet leatherSet() => ArmorSet(
  id: 'leather',
  name: const LocalizedText(en: 'Leather', ptBr: 'Couro'),
  rarity: 1,
  pieces: [
    buildPiece(
      'leather-headgear',
      'Leather Headgear',
      BodyPart.head,
      set: 'leather',
      pt: 'Capacete de Couro',
      rarity: 1,
      defense: 2,
      maxDefense: null,
      resistances: Resistances.zero,
      skills: const [SkillLevel('attack-boost', 1)],
    ),
  ],
);

const attackJewel = ArmorDecoration(
  id: 'attack-jewel-2',
  name: LocalizedText(en: 'Attack Jewel 2', ptBr: 'Joia do Ataque 2'),
  slotLevel: 2,
  skills: [SkillLevel('attack-boost', 1)],
);
const attackJewelPlus = ArmorDecoration(
  id: 'attack-jewel-plus-4',
  name: LocalizedText(en: 'Attack Jewel+ 4', ptBr: 'Joia Ataque+ 4'),
  slotLevel: 4,
  skills: [SkillLevel('attack-boost', 2)],
);

ArmorCatalog armorCatalog() => ArmorCatalog(
  game: Game.riseSunbreak,
  sets: [rathalosX(), leatherSet()],
  skills: [attackBoost, partbreaker, criticalBoost, earplugs, windproof],
  decorations: const [attackJewelPlus, attackJewel],
);
