import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/material_sources.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/data/dtos/json_reader.dart';

/// `{en, ptBr?}` as a [LocalizedText].
LocalizedText readLocalized(JsonReader r) =>
    LocalizedText(en: r.string('en'), ptBr: r.optionalString('ptBr'));

/// A material's `sources` object, as weapons.json and armor.json write it
/// (006 research R13, 007 research R5).
MaterialSources readMaterialSources(JsonReader r) {
  int? rate(JsonReader x) => x.optionalNumber('rate')?.toInt();
  return MaterialSources(
    gathering: [
      for (final g in r.optionalObjects('gathering'))
        GatheringSource(
          map: readLocalized(g.object('map')),
          rank: g.enumValue('rank', Rank.values),
          rate: rate(g),
        ),
    ],
    monsters: [
      for (final m in r.optionalObjects('monsters'))
        MonsterSource(
          name: readLocalized(m.object('name')),
          rank: m.enumValue('rank', Rank.values),
          method: readLocalized(m.object('method')),
          rate: rate(m),
          slug: m.optionalString('slug'),
        ),
    ],
    quests: [
      for (final q in r.optionalObjects('quests'))
        QuestSource(
          name: readLocalized(q.object('name')),
          category: readLocalized(q.object('category')),
          stars: q.string('stars'),
          rate: rate(q),
        ),
    ],
  );
}
