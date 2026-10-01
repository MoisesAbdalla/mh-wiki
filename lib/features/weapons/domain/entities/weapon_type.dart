import 'package:mh_wiki/core/domain/localized_text.dart';

/// One of the 14 weapon types of a game (Great Sword, Bow…).
final class WeaponType {
  const WeaponType({
    required this.id,
    required this.name,
    required this.ranged,
  });

  final String id;
  final LocalizedText name;

  /// Bows and bowguns: no sharpness (006 FR-008).
  final bool ranged;

  @override
  bool operator ==(Object other) => other is WeaponType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
