import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';

/// What the weapon list shows: one type, an optional rank and a search text,
/// or an explicit set of weapons ("Armas feitas com ele", 006 FR-010).
final class WeaponQuery {
  const WeaponQuery({
    required this.typeId,
    this.rank,
    this.text = '',
    this.onlyIds,
    this.onlyLabel,
  });

  final String typeId;
  final Rank? rank;
  final String text;

  /// When set, these weapons are shown whatever their type.
  final Set<WeaponId>? onlyIds;

  /// Label of the [onlyIds] filter chip (e.g. "Armas de Anjanath").
  final String? onlyLabel;

  bool get hasFilters =>
      rank != null || text.trim().isNotEmpty || onlyIds != null;

  WeaponQuery copyWith({
    String? typeId,
    Rank? Function()? rank,
    String? text,
    Set<WeaponId>? Function()? onlyIds,
    String? Function()? onlyLabel,
  }) => WeaponQuery(
    typeId: typeId ?? this.typeId,
    rank: rank != null ? rank() : this.rank,
    text: text ?? this.text,
    onlyIds: onlyIds != null ? onlyIds() : this.onlyIds,
    onlyLabel: onlyLabel != null ? onlyLabel() : this.onlyLabel,
  );
}
