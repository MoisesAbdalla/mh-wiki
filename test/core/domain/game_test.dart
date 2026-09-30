import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';

void main() {
  test('display order is World, Rise, Wilds', () {
    expect(Game.worldIceborne.displayOrder, 0);
    expect(Game.riseSunbreak.displayOrder, 1);
    expect(Game.wilds.displayOrder, 2);
  });

  test('dataset keys match asset folders', () {
    expect(Game.worldIceborne.datasetKey, 'world_iceborne');
    expect(Game.riseSunbreak.datasetKey, 'rise_sunbreak');
    expect(Game.wilds.datasetKey, 'wilds');
  });

  test('Wilds has no master rank', () {
    expect(Game.worldIceborne.allowedRanks, contains(Rank.master));
    expect(Game.riseSunbreak.allowedRanks, contains(Rank.master));
    expect(Game.wilds.allowedRanks, [Rank.low, Rank.high]);
  });

  test('fromDatasetKey resolves known keys and rejects unknown', () {
    expect(Game.fromDatasetKey('wilds'), Game.wilds);
    expect(Game.fromDatasetKey('rise_sunbreak'), Game.riseSunbreak);
    expect(Game.fromDatasetKey('generations'), isNull);
  });
}
