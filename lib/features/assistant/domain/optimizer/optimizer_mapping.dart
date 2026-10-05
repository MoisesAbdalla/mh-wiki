import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_search.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';

/// The skills seen most often in the curated builds of [weaponType] at a
/// similar stage (Master and Post together, High and Low together), not yet
/// [chosen]; at most [limit] (009 research R5).
List<String> suggestSkills(
  Iterable<CuratedBuild> builds,
  String weaponType,
  Progress progress, {
  Iterable<String> chosen = const [],
  int limit = 8,
}) {
  bool late(ProgressRank r) =>
      r == ProgressRank.master || r == ProgressRank.post;
  final band = late(progress.rank);
  final counts = <String, int>{};
  for (final b in builds) {
    if (b.weaponType != weaponType || late(b.stage.rank) != band) continue;
    for (final s in b.skills) {
      final id = s.skill.id;
      if (id != null) counts[id] = (counts[id] ?? 0) + 1;
    }
  }
  final skip = chosen.toSet();
  final ranked = counts.entries.where((e) => !skip.contains(e.key)).toList()
    ..sort(
      (a, b) => b.value != a.value ? b.value - a.value : a.key.compareTo(b.key),
    );
  return [for (final e in ranked.take(limit)) e.key];
}

/// A [BuildSet] as a build that can be shown with the 008 detail and saved
/// in Minhas builds.
CuratedBuild buildSetToCurated(
  BuildSet set,
  OptimizerCatalog catalog, {
  required String id,
  required String name,
  required String weaponType,
  required Progress stage,
  required String stageLabel,
  required String sourceName,
  Map<String, int> wanted = const {},
}) {
  CatalogRef skillRef(String skill) => CatalogRef(
    id: skill,
    name: catalog.skills[skill]?.name ?? LocalizedText(en: skill),
    kind: RefKind.skill,
  );
  CatalogRef decoRef(OptimizerDecoration d) =>
      CatalogRef(id: d.id, name: d.name, kind: RefKind.decoration);
  List<CatalogRef> decosOf(EquipSlot holder) {
    final placed = [
      for (final d in set.decorations)
        if (d.holder == holder) d,
    ]..sort((a, b) => a.index - b.index);
    return [for (final d in placed) decoRef(d.decoration)];
  }

  CatalogRef pieceRef(OptimizerPiece p) =>
      CatalogRef(id: p.id, name: p.name, kind: RefKind.piece, rarity: p.rarity);

  final weapon = set.weapon;
  final talisman = set.talisman;
  final talismanSkills = talisman?.skills.entries.toList() ?? const [];
  final counts = <String, (OptimizerDecoration, int)>{};
  for (final d in set.decorations) {
    final c = counts[d.decoration.id];
    counts[d.decoration.id] = (d.decoration, (c?.$2 ?? 0) + 1);
  }
  final skills = set.skills.entries.toList()
    ..sort((a, b) {
      final wa = wanted.containsKey(a.key), wb = wanted.containsKey(b.key);
      if (wa != wb) return wa ? -1 : 1;
      return b.value - a.value;
    });

  return CuratedBuild(
    id: id,
    name: name,
    weaponType: weaponType,
    stage: stage,
    stageLabel: stageLabel,
    weapon: BuildItem(
      ref: CatalogRef(
        id: weapon?.id,
        name: weapon?.name ?? const LocalizedText(en: '—'),
        kind: RefKind.weapon,
        rarity: weapon?.rarity,
        image: weapon?.image,
      ),
      decorations: decosOf(EquipSlot.weapon),
    ),
    pieces: [
      for (final part in BuildPart.values)
        if (set.pieces[part] case final p?)
          BuildPiece(
            part: part,
            item: BuildItem(
              ref: pieceRef(p),
              decorations: decosOf(equipSlotOf(part)),
            ),
            alternatives: [
              for (final a
                  in set.alternatives[part] ?? const <OptimizerPiece>[])
                pieceRef(a),
            ],
          ),
    ],
    talisman: talismanSkills.isEmpty
        ? null
        : BuildTalisman(
            skill: skillRef(talismanSkills.first.key),
            level: talismanSkills.first.value,
            note: '',
            decorations: decosOf(EquipSlot.talisman),
            second: talismanSkills.length > 1
                ? (
                    skill: skillRef(talismanSkills[1].key),
                    level: talismanSkills[1].value,
                  )
                : null,
            slots: talisman!.slots,
          ),
    skills: [
      for (final e in skills)
        BuildSkill(
          skill: skillRef(e.key),
          level: e.value,
          maxLevel: catalog.skills[e.key]?.max ?? e.value,
        ),
    ],
    decorations: [
      for (final (d, n)
          in counts.values.toList()..sort((a, b) => b.$1.slot - a.$1.slot))
        DecorationCount(decoRef(d), n),
    ],
    sourceName: sourceName,
    sourceUrl: '',
  );
}
