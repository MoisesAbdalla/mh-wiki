import 'package:mh_wiki/features/monsters/domain/entities/hunting_item.dart';
import 'package:mh_wiki/features/monsters/domain/entities/item_reaction.dart';
import 'package:mh_wiki/features/monsters/domain/entities/party_hp_factors.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';

/// Whether the monster can see (003 research R4).
enum Vision { sees, unknown }

/// HP and hunting-item information of a monster (feature 003).
final class HuntingInfo {
  const HuntingInfo({
    this.hp = const [],
    this.partyFactors,
    this.items = const [],
    this.reactions = const [],
  });

  /// Solo reference HP per rank, in rank order; empty when unknown.
  final List<RankHp> hp;

  /// The game's party scaling; `null` when no source documents it.
  final PartyHpFactors? partyFactors;

  /// The game's hunting items (from the dataset).
  final List<HuntingItem> items;
  final List<ItemReaction> reactions;

  /// Reaction to [itemId]; unknown when the source has none.
  ItemReaction reactionFor(String itemId) {
    for (final reaction in reactions) {
      if (reaction.item == itemId) return reaction;
    }
    return ItemReaction.unknown(itemId);
  }

  /// "Enxerga" only when light affects it; never claims blindness (R4).
  Vision get vision => switch (reactionFor('flash').effect) {
    ReactionEffect.affects || ReactionEffect.conditional => Vision.sees,
    _ => Vision.unknown,
  };
}
