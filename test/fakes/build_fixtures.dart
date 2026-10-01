import 'dart:async';

import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/assistant/domain/assistant_domain.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';

CatalogRef ref(String? id, String en, RefKind kind, {String? pt}) => CatalogRef(
  id: id,
  name: LocalizedText(en: en, ptBr: pt),
  kind: kind,
);

CuratedBuild buildFixture(
  String id, {
  String type = 'great-sword',
  Progress stage = const Progress(ProgressRank.master, 'M1'),
  String label = 'MR 1-2',
  String? name,
}) => CuratedBuild(
  id: id,
  name: name ?? id,
  weaponType: type,
  stage: stage,
  stageLabel: label,
  weapon: BuildItem(
    ref: ref(
      'kamura-warrior-cleaver',
      'Kamura Warrior Cleaver',
      RefKind.weapon,
      pt: 'Cutelo Guerreiro Kamura',
    ),
    decorations: [
      ref(
        'critical-jewel-2',
        'Critical Jewel 2',
        RefKind.decoration,
        pt: 'Joia Crítica 2',
      ),
    ],
  ),
  pieces: [
    BuildPiece(
      part: BuildPart.head,
      item: BuildItem(
        ref: ref(
          'hunters-helm-x',
          "Hunter's Helm X",
          RefKind.piece,
          pt: 'Elmo do Caçador X',
        ),
        decorations: [
          ref(
            'charger-jewel-2',
            'Charger Jewel 2',
            RefKind.decoration,
            pt: 'Joia Energiz. 2',
          ),
        ],
      ),
    ),
    BuildPiece(
      part: BuildPart.waist,
      item: BuildItem(
        ref: ref(
          'chaotic-faulds',
          'Chaotic Faulds',
          RefKind.piece,
          pt: 'Escarcela Caótica',
        ),
      ),
      alternatives: [ref(null, 'Nephilim Tassets', RefKind.piece)],
    ),
  ],
  talisman: BuildTalisman(
    skill: ref(
      'critical-eye',
      'Critical Eye',
      RefKind.skill,
      pt: 'Olho Crítico',
    ),
    level: 3,
    note: 'Critical Eye ・Level 3 with desired slots or better',
  ),
  skills: [
    BuildSkill(
      skill: ref(
        'attack-boost',
        'Attack Boost',
        RefKind.skill,
        pt: 'Reforço de Ataque',
      ),
      level: 7,
      maxLevel: 7,
    ),
    BuildSkill(
      skill: ref(
        'critical-eye',
        'Critical Eye',
        RefKind.skill,
        pt: 'Olho Crítico',
      ),
      level: 6,
      maxLevel: 7,
    ),
  ],
  decorations: [
    DecorationCount(
      ref(
        'critical-jewel-2',
        'Critical Jewel 2',
        RefKind.decoration,
        pt: 'Joia Crítica 2',
      ),
      3,
    ),
    DecorationCount(
      ref(
        'charger-jewel-2',
        'Charger Jewel 2',
        RefKind.decoration,
        pt: 'Joia Energiz. 2',
      ),
      1,
    ),
  ],
  sourceName: 'Game8',
  sourceUrl: 'https://game8.co/games/Monster-Hunter-Rise/archives/380791',
);

/// Builds across the progress scale, two weapon types.
List<CuratedBuild> buildFixtures() => [
  buildFixture(
    'starter',
    stage: const Progress(ProgressRank.low, '1'),
    label: 'Village ★1 to ★4',
  ),
  buildFixture('kamura-warrior', name: 'Kamura Warrior Cleaver Raw Affinity'),
  buildFixture(
    'royal-order',
    stage: const Progress(ProgressRank.master, 'M3'),
    label: 'MR 3-6',
  ),
  buildFixture(
    'fine-kamura',
    stage: const Progress(ProgressRank.master, 'M6'),
    label: 'MR6+',
  ),
  buildFixture(
    'blood-awakening',
    stage: const Progress(ProgressRank.post, '180'),
    label: 'MR180+',
  ),
  buildFixture('bow-build', type: 'bow'),
];

class FakeBuildRepository implements BuildRepository {
  FakeBuildRepository({List<CuratedBuild>? builds, this.failure})
    : builds = builds ?? buildFixtures();

  List<CuratedBuild> builds;
  Failure? failure;
  Completer<void>? completer;
  int loadCount = 0;

  @override
  Future<Result<BuildCatalog>> loadCatalog(Game game) async {
    loadCount++;
    await completer?.future;
    final f = failure;
    return f != null
        ? Err(f)
        : Success(BuildCatalog(game: game, builds: builds));
  }
}

class FakeSavedBuildsRepository implements SavedBuildsRepository {
  List<SavedBuild> saved = [];
  bool refuse = false;

  @override
  Future<List<SavedBuild>> load() async => [...saved];

  @override
  Future<bool> store(List<SavedBuild> builds) async {
    if (refuse) return false;
    saved = [...builds];
    return true;
  }
}

class FakeAssistantPrefsRepository implements AssistantPrefsRepository {
  AssistantPrefs prefs = (progress: Progress.first, weaponType: null);

  @override
  Future<AssistantPrefs> load() async => prefs;

  @override
  Future<void> store(AssistantPrefs value) async => prefs = value;
}
