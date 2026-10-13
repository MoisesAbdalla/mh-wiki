import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';

/// Element or status damage of a weapon (e.g. Fire 28).
final class WeaponSpecial {
  const WeaponSpecial({
    required this.kind,
    required this.value,
    this.hidden = false,
  });

  final SpecialKind kind;
  final int value;

  /// A World hidden element: it only works with Free Element (011).
  final bool hidden;

  @override
  bool operator ==(Object other) =>
      other is WeaponSpecial &&
      other.kind == kind &&
      other.value == value &&
      other.hidden == hidden;

  @override
  int get hashCode => Object.hash(kind, value, hidden);
}
