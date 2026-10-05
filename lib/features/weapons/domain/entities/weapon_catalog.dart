import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/weapons/domain/entities/artian.dart';
import 'package:mh_wiki/features/weapons/domain/entities/rampage.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_type.dart';

/// Every weapon of one game, with its types in display order.
final class WeaponCatalog {
  WeaponCatalog({
    required this.game,
    required this.types,
    required this.weapons,
    this.rampageDecorations = const [],
    this.artian = const [],
  }) : _byId = {for (final w in weapons) w.id: w};

  final Game game;
  final List<WeaponType> types;
  final List<Weapon> weapons;

  /// Decorations for the Rampage slot of Master Rank weapons.
  final List<RampageDecoration> rampageDecorations;

  /// Artian weapons by type (Wilds, 010 US3).
  final List<ArtianType> artian;
  final Map<WeaponId, Weapon> _byId;

  Weapon? byId(WeaponId id) => _byId[id];

  ArtianType? artianOf(String type) =>
      artian.where((a) => a.type == type).firstOrNull;

  /// The Gogma Artian of [type], one per focus, in focus order.
  List<Weapon> gogmaOf(String type) => [
    for (final w in weapons)
      if (w.gogma != null && w.type.id == type) w,
  ]..sort((a, b) => a.gogma!.index.compareTo(b.gogma!.index));

  Weapon? gogma(String type, ArtianFocus focus) =>
      gogmaOf(type).where((w) => w.gogma == focus).firstOrNull;
}
