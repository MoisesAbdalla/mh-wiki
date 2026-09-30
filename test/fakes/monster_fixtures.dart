import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/breakable_part.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/features/monsters/domain/entities/habitat.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_item.dart';
import 'package:mh_wiki/features/monsters/domain/entities/item_reaction.dart';
import 'package:mh_wiki/features/monsters/domain/entities/material_drop.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_material.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_section_kind.dart';
import 'package:mh_wiki/features/monsters/domain/entities/party_hp_factors.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';
import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_profile.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_state.dart';

/// Builds a full element map; unspecified elements default to 0 stars.
Map<ElementType, Effectiveness> weaknesses({
  Effectiveness fire = Effectiveness.none,
  Effectiveness water = Effectiveness.none,
  Effectiveness thunder = Effectiveness.none,
  Effectiveness ice = Effectiveness.none,
  Effectiveness dragon = Effectiveness.none,
}) => {
  ElementType.fire: fire,
  ElementType.water: water,
  ElementType.thunder: thunder,
  ElementType.ice: ice,
  ElementType.dragon: dragon,
};

MonsterMaterial material(String id, String en, {String? ptBr, int? rarity}) =>
    MonsterMaterial(
      id: id,
      name: LocalizedText(en: en, ptBr: ptBr),
      rarity: rarity,
    );

MaterialDrop drop(
  MonsterMaterial material,
  Rank rank,
  DropMethod method, {
  double? rate,
  String? partId,
  LocalizedText? methodLabel,
}) => MaterialDrop(
  material: material,
  rank: rank,
  method: method,
  ratePercent: rate,
  partId: partId,
  methodLabel: methodLabel,
);

Monster buildMonster({
  Game game = Game.worldIceborne,
  String slug = 'rathalos',
  String en = 'Rathalos',
  String? ptBr,
  String classificationEn = 'Flying Wyvern',
  Map<ElementType, Effectiveness>? general,
  List<WeaknessState> states = const [],
  List<Habitat> habitats = const [],
  List<BreakablePart> parts = const [],
  List<MaterialDrop> drops = const [],
  String? imageAsset,
  HuntingInfo huntingInfo = const HuntingInfo(),
  String? versionOf,
  VersionKind? versionKind,
  Set<MonsterSectionKind> inheritedSections = const {},
}) => Monster(
  id: MonsterId(game, slug),
  name: LocalizedText(en: en, ptBr: ptBr),
  classification: LocalizedText(en: classificationEn),
  imageAsset: imageAsset,
  weaknesses: WeaknessProfile(
    general:
        general ??
        weaknesses(dragon: Effectiveness.high, thunder: Effectiveness.medium),
    states: states,
  ),
  habitats: habitats,
  parts: parts,
  drops: drops,
  sources: const [SourceRef(name: 'Test', url: 'https://example.com')],
  huntingInfo: huntingInfo,
  versionOf: versionOf == null ? null : MonsterId(game, versionOf),
  versionKind: versionKind,
  inheritedSections: inheritedSections,
);

/// A version of [base] (feature 004) with the given name.
Monster buildVersion(
  Monster base,
  VersionKind kind, {
  required String slug,
  required String en,
  String? ptBr,
  Set<MonsterSectionKind> inherited = const {
    MonsterSectionKind.weaknesses,
    MonsterSectionKind.parts,
    MonsterSectionKind.habitats,
    MonsterSectionKind.itemReactions,
    MonsterSectionKind.classification,
  },
}) => Monster(
  id: MonsterId(base.id.game, slug),
  name: LocalizedText(en: en, ptBr: ptBr),
  classification: base.classification,
  weaknesses: base.weaknesses,
  habitats: base.habitats,
  parts: base.parts,
  drops: const [],
  sources: base.sources,
  imageAsset: base.imageAsset,
  versionOf: base.id,
  versionKind: kind,
  inheritedSections: inherited,
);

extension MonsterTestCopy on Monster {
  /// Same data under a unique slug/name, for bulk (performance) fixtures.
  Monster copyForTest(int index) => Monster(
    id: MonsterId(id.game, '${id.slug}-$index'),
    name: LocalizedText(
      en: '${name.en} $index',
      ptBr: name.ptBr == null ? null : '${name.ptBr} $index',
    ),
    classification: classification,
    weaknesses: this.weaknesses,
    habitats: habitats,
    parts: parts,
    drops: drops,
    sources: sources,
    huntingInfo: huntingInfo,
    versionOf: versionOf,
    versionKind: versionKind,
    inheritedSections: inheritedSections,
  );
}

/// Hunting info exercising the 003 edge cases: an expedition and a
/// "a partir de" HP, factor ranges, every reaction status and a long detail.
const richHuntingInfo = HuntingInfo(
  hp: [
    RankHp(rank: Rank.low, solo: 4908, basis: HpBasis.expedition),
    RankHp(rank: Rank.master, solo: 20800, basis: HpBasis.minQuest),
  ],
  partyFactors: PartyHpFactors(
    factors: {
      2: FactorRange(1.5, 1.5),
      3: FactorRange(2.2, 2.6),
      4: FactorRange(2.2, 2.6),
    },
    source: SourceRef(name: 'Fextralife', url: 'https://example.com'),
  ),
  items: [
    HuntingItem(
      id: 'flash',
      name: LocalizedText(en: 'Flash Pod', ptBr: 'Cápsula de Lampejo'),
    ),
    HuntingItem(
      id: 'sonic',
      name: LocalizedText(en: 'Screamer Pod', ptBr: 'Cápsula de Grito'),
    ),
    HuntingItem(
      id: 'dung',
      name: LocalizedText(en: 'Dung Pod', ptBr: 'Cápsula de Esterco'),
    ),
    HuntingItem(
      id: 'pitfallTrap',
      name: LocalizedText(en: 'Pitfall Trap', ptBr: 'Armadilha de Poço'),
    ),
  ],
  reactions: [
    ItemReaction(
      item: 'flash',
      effect: ReactionEffect.affects,
      detail: LocalizedText(en: 'Lasts 20 s', ptBr: 'Dura 20 s'),
    ),
    ItemReaction(
      item: 'sonic',
      effect: ReactionEffect.conditional,
      detail: LocalizedText(
        en: 'Only while burrowed: it is stunned as if in a Pitfall Trap',
        ptBr:
            'Só quando está enterrado: fica preso como numa Armadilha de Poço',
      ),
    ),
    ItemReaction(item: 'dung', effect: ReactionEffect.noEffect),
  ],
);

/// A monster exercising every detail edge case: states, immunity, severable
/// part, break-part drop, unknown rate and an `other` method.
Monster richMonster({Game game = Game.worldIceborne}) {
  final gem = material('rathalos-ruby', 'Rathalos Ruby', rarity: 8);
  final scale = material(
    'rathalos-scale',
    'Rathalos Scale',
    ptBr: 'Escama de Rathalos',
  );
  return buildMonster(
    game: game,
    huntingInfo: richHuntingInfo,
    general: weaknesses(
      fire: Effectiveness.immune,
      dragon: Effectiveness.high,
      thunder: Effectiveness.medium,
      water: Effectiveness.low,
    ),
    states: [
      WeaknessState(
        id: 'enraged',
        name: const LocalizedText(en: 'Enraged', ptBr: 'Enfurecido'),
        values: weaknesses(ice: Effectiveness.high),
      ),
    ],
    habitats: const [
      Habitat(
        id: 'ancient-forest',
        name: LocalizedText(en: 'Ancient Forest'),
      ),
    ],
    parts: const [
      BreakablePart(
        id: 'head',
        name: LocalizedText(en: 'Head', ptBr: 'Cabeça'),
        severable: false,
      ),
      BreakablePart(
        id: 'tail',
        name: LocalizedText(en: 'Tail', ptBr: 'Cauda'),
        severable: true,
      ),
    ],
    drops: [
      drop(scale, Rank.low, DropMethod.carve, rate: 32),
      drop(scale, Rank.low, DropMethod.tailCarve),
      drop(gem, Rank.high, DropMethod.breakPart, partId: 'head', rate: 3),
      drop(
        gem,
        Rank.high,
        DropMethod.other,
        rate: 1,
        methodLabel: const LocalizedText(
          en: 'Investigation',
          ptBr: 'Investigação',
        ),
      ),
    ],
  );
}
