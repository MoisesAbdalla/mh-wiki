import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';

/// A weapon in a tree with its depth from the tree's root.
final class WeaponTreeEntry {
  const WeaponTreeEntry(this.weapon, this.depth);

  final Weapon weapon;
  final int depth;
}

/// An upgrade tree (e.g. "Anjanath Tree") of one weapon type, its weapons in
/// display order: roots first, depth first (research R4).
final class WeaponTree {
  const WeaponTree({
    required this.id,
    required this.name,
    required this.entries,
  });

  final String id;
  final LocalizedText name;
  final List<WeaponTreeEntry> entries;
}
