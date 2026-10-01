import 'package:mh_wiki/core/domain/localized_text.dart';

/// A Rampage skill a Low/High Rank weapon can take (007 research R6).
final class RampageSkill {
  const RampageSkill({
    required this.id,
    required this.name,
    required this.effect,
  });

  final String id;
  final LocalizedText name;
  final LocalizedText effect;
}

/// A Rampage decoration for a Master Rank weapon's Rampage slot.
final class RampageDecoration {
  const RampageDecoration({
    required this.id,
    required this.name,
    required this.slotLevel,
    required this.skill,
    this.weaponTypes = const [],
  });

  final String id;
  final LocalizedText name;
  final int slotLevel;
  final RampageSkill skill;

  /// Type ids it is limited to; empty = every type.
  final List<String> weaponTypes;

  /// Whether it fits a weapon of [typeId] with a Rampage slot of [slot].
  bool fits(String typeId, int slot) =>
      slotLevel <= slot &&
      (weaponTypes.isEmpty || weaponTypes.contains(typeId));
}
