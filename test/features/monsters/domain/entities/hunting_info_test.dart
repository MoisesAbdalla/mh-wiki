import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/item_reaction.dart';

void main() {
  HuntingInfo withFlash(ReactionEffect effect) => HuntingInfo(
    reactions: [ItemReaction(item: 'flash', effect: effect)],
  );

  group('vision (R4)', () {
    test('sees when the flash affects it, even with a condition', () {
      expect(withFlash(ReactionEffect.affects).vision, Vision.sees);
      expect(withFlash(ReactionEffect.conditional).vision, Vision.sees);
    });

    test('never claims blindness: no effect or no data is unknown', () {
      expect(withFlash(ReactionEffect.noEffect).vision, Vision.unknown);
      expect(const HuntingInfo().vision, Vision.unknown);
    });
  });

  test('an item without a reaction is unknown', () {
    final reaction = withFlash(ReactionEffect.affects).reactionFor('sonic');
    expect(reaction.item, 'sonic');
    expect(reaction.effect, ReactionEffect.unknown);
    expect(reaction.detail, isNull);
  });
}
