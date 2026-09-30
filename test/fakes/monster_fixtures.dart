import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/breakable_part.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/features/monsters/domain/entities/habitat.dart';
import 'package:mh_wiki/features/monsters/domain/entities/material_drop.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_material.dart';
import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';
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
