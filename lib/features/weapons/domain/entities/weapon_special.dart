import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';

/// Element or status damage of a weapon (e.g. Fire 28).
final class WeaponSpecial {
  const WeaponSpecial({required this.kind, required this.value});

  final SpecialKind kind;
  final int value;

  @override
  bool operator ==(Object other) =>
      other is WeaponSpecial && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);
}
