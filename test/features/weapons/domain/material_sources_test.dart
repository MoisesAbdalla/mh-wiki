import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/weapons/domain/entities/material_sources.dart';

/// 006 FR-015: the sources shown are the weapon's rank, else the nearest.
void main() {
  GatheringSource at(String map, Rank rank) => GatheringSource(
    map: LocalizedText(en: map),
    rank: rank,
  );

  const quest = QuestSource(
    name: LocalizedText(en: 'Q'),
    category: LocalizedText(en: 'Event Quests'),
    stars: '8',
  );

  final sources = MaterialSources(
    gathering: [at('Jungle', Rank.low), at('Citadel', Rank.master)],
    quests: const [quest],
  );

  test('keeps the weapon rank when it has sources', () {
    final r = sources.forRank(Rank.master);
    expect(r.rank, Rank.master);
    expect(r.gathering.single.map.en, 'Citadel');
    expect(r.quests, [quest]);
  });

  test('falls back to a lower rank first, then a higher one', () {
    expect(sources.forRank(Rank.high).rank, Rank.low);
    final onlyMaster = MaterialSources(gathering: [at('Citadel', Rank.master)]);
    expect(onlyMaster.forRank(Rank.low).rank, Rank.master);
  });

  test('no sources gives an empty result in the weapon rank', () {
    final r = MaterialSources.none.forRank(Rank.high);
    expect(r.isEmpty, isTrue);
    expect(r.rank, Rank.high);
  });
}
