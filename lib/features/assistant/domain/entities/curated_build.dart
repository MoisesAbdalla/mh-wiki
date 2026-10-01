import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';

/// What a build item points to in the app's catalog.
enum RefKind { weapon, piece, skill, decoration, rampage }

/// A named item of a build, with its catalog id when the app knows it
/// (008 FR-008).
final class CatalogRef {
  const CatalogRef({required this.name, required this.kind, this.id});

  final String? id;
  final LocalizedText name;
  final RefKind kind;

  bool get known => id != null;
}

/// An equipped item and the decorations in its slots.
final class BuildItem {
  const BuildItem({required this.ref, this.decorations = const []});

  final CatalogRef ref;
  final List<CatalogRef> decorations;
}

enum BuildPart { head, chest, arms, waist, legs }

final class BuildPiece {
  const BuildPiece({
    required this.item,
    this.part,
    this.alternatives = const [],
  });

  /// `null` when the piece is not in the catalog.
  final BuildPart? part;
  final BuildItem item;

  /// Other pieces the guide allows in the same place ("A / B").
  final List<CatalogRef> alternatives;
}

final class BuildTalisman {
  const BuildTalisman({
    required this.skill,
    required this.level,
    required this.note,
    this.decorations = const [],
  });

  final CatalogRef skill;
  final int level;

  /// The guide's requirement, e.g. "Level 3 with desired slots or better".
  final String note;
  final List<CatalogRef> decorations;
}

final class BuildSkill {
  const BuildSkill({
    required this.skill,
    required this.level,
    required this.maxLevel,
  });

  final CatalogRef skill;
  final int level;
  final int maxLevel;
}

final class DecorationCount {
  const DecorationCount(this.decoration, this.count);

  final CatalogRef decoration;
  final int count;
}

/// A ready-made build from a guide (008 data-model).
final class CuratedBuild {
  const CuratedBuild({
    required this.id,
    required this.name,
    required this.weaponType,
    required this.stage,
    required this.stageLabel,
    required this.weapon,
    required this.pieces,
    required this.sourceName,
    required this.sourceUrl,
    this.talisman,
    this.skills = const [],
    this.rampage = const [],
    this.decorations = const [],
  });

  final String id;

  /// As in the source (English).
  final String name;
  final String weaponType;
  final Progress stage;

  /// The guide's own label ("MR 6+", "HR 40 to 99").
  final String stageLabel;
  final BuildItem weapon;
  final List<BuildPiece> pieces;
  final BuildTalisman? talisman;
  final List<BuildSkill> skills;
  final List<CatalogRef> rampage;

  /// Every decoration of the build with its count.
  final List<DecorationCount> decorations;
  final String sourceName;
  final String sourceUrl;

  @override
  bool operator ==(Object other) => other is CuratedBuild && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A build the user kept (008 US3): a full copy, so it survives updates.
final class SavedBuild {
  const SavedBuild({
    required this.id,
    required this.name,
    required this.savedAt,
    required this.build,
  });

  final String id;
  final String name;
  final DateTime savedAt;
  final CuratedBuild build;

  SavedBuild renamed(String name) =>
      SavedBuild(id: id, name: name, savedAt: savedAt, build: build);
}
