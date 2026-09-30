import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';

/// One row of the monster list: a base monster with its versions collapsed
/// under it (spec FR-006).
final class MonsterEntry {
  const MonsterEntry({
    required this.base,
    this.versions = const [],
    this.matchedVersion,
  });

  final Monster base;

  /// In [VersionKind] order.
  final List<Monster> versions;

  /// Set when the search matched only this version's name (FR-006a).
  final Monster? matchedVersion;

  /// The monster the row opens.
  Monster get target => matchedVersion ?? base;
}
