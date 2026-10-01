import 'package:mh_wiki/core/domain/game.dart';
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
  }) : _byId = {for (final w in weapons) w.id: w};

  final Game game;
  final List<WeaponType> types;
  final List<Weapon> weapons;

  /// Decorations for the Rampage slot of Master Rank weapons.
  final List<RampageDecoration> rampageDecorations;
  final Map<WeaponId, Weapon> _byId;

  Weapon? byId(WeaponId id) => _byId[id];
}
