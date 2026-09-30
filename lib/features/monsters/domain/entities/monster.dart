import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/breakable_part.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/habitat.dart';
import 'package:mh_wiki/features/monsters/domain/entities/hunting_info.dart';
import 'package:mh_wiki/features/monsters/domain/entities/material_drop.dart';
import 'package:mh_wiki/features/monsters/domain/entities/material_drop_group.dart';
import 'package:mh_wiki/features/monsters/domain/entities/method_drop_group.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_section_kind.dart';
import 'package:mh_wiki/features/monsters/domain/entities/source_ref.dart';
import 'package:mh_wiki/features/monsters/domain/entities/version_kind.dart';
import 'package:mh_wiki/features/monsters/domain/entities/weakness_profile.dart';

/// A large monster of one specific game.
final class Monster {
  const Monster({
    required this.id,
    required this.name,
    required this.classification,
    required this.weaknesses,
    required this.habitats,
    required this.parts,
    required this.drops,
    required this.sources,
    this.imageAsset,
    this.huntingInfo = const HuntingInfo(),
    this.versionOf,
    this.versionKind,
    this.inheritedSections = const {},
  });

  final MonsterId id;
  final LocalizedText name;
  final LocalizedText classification;
  final WeaknessProfile weaknesses;
  final List<Habitat> habitats;
  final List<BreakablePart> parts;
  final List<MaterialDrop> drops;
  final List<SourceRef> sources;

  /// `null` means the UI shows a generic placeholder.
  final String? imageAsset;

  /// HP and hunting-item reactions (feature 003); empty when unknown.
  final HuntingInfo huntingInfo;

  /// The base monster when this entry is a version of it (feature 004).
  final MonsterId? versionOf;
  final VersionKind? versionKind;

  /// Sections copied from the base because the sources give none of their
  /// own; shown as "Igual à forma base" (FR-006c).
  final Set<MonsterSectionKind> inheritedSections;

  bool get isVersion => versionOf != null;

  /// Drops grouped by rank (low → high → master), then by material in order
  /// of first appearance. Ranks without drops are omitted.
  Map<Rank, List<MaterialDropGroup>> get dropsByRank {
    final result = <Rank, List<MaterialDropGroup>>{};
    for (final rank in Rank.values) {
      final byMaterial = <String, List<MaterialDrop>>{};
      for (final drop in drops.where((d) => d.rank == rank)) {
        byMaterial.putIfAbsent(drop.material.id, () => []).add(drop);
      }
      if (byMaterial.isEmpty) continue;
      result[rank] = [
        for (final rows in byMaterial.values)
          MaterialDropGroup(material: rows.first.material, drops: rows),
      ];
    }
    return result;
  }

  /// The drops of [rank] grouped by how they are obtained, keyed by method,
  /// part and label, in order of first appearance (005 FR-014).
  List<MethodDropGroup> dropsByMethod(Rank rank) {
    final groups = <(DropMethod, String?, String?), List<MaterialDrop>>{};
    for (final drop in drops.where((d) => d.rank == rank)) {
      groups
          .putIfAbsent((
            drop.method,
            drop.partId,
            drop.methodLabel?.en,
          ), () => [])
          .add(drop);
    }
    return [
      for (final rows in groups.values)
        MethodDropGroup(
          method: rows.first.method,
          partId: rows.first.partId,
          methodLabel: rows.first.methodLabel,
          drops: rows,
        ),
    ];
  }

  BreakablePart? partById(String id) {
    for (final part in parts) {
      if (part.id == id) return part;
    }
    return null;
  }

  @override
  bool operator ==(Object other) => other is Monster && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
