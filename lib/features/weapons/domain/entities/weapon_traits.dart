import 'package:mh_wiki/core/domain/localized_text.dart';

/// What only some weapon types have (006 US4, FR-014). Names keep the game's
/// own wording in en and pt-BR, as Kiranico shows them.
final class WeaponTraits {
  const WeaponTraits({
    this.phial,
    this.shelling,
    this.kinsectLevel,
    this.songs = const [],
    this.arcShot,
    this.chargeShots = const [],
    this.coatings = const [],
    this.deviation,
    this.recoil,
    this.reload,
    this.ammo = const [],
  });

  static const none = WeaponTraits();

  /// Charge Blade and Switch Axe: "Impacto", "Elemento", "Veneno 23"…
  final LocalizedText? phial;

  /// Gunlance: shelling type and level, "Amplo 6".
  final LocalizedText? shelling;

  /// Insect Glaive.
  final int? kinsectLevel;

  /// Hunting Horn: its three songs.
  final List<LocalizedText> songs;

  /// Bow.
  final LocalizedText? arcShot;
  final List<BowShot> chargeShots;
  final List<BowShot> coatings;

  /// Bowguns.
  final LocalizedText? deviation;
  final LocalizedText? recoil;
  final LocalizedText? reload;
  final List<AmmoCapacity> ammo;

  bool get isEmpty =>
      phial == null &&
      shelling == null &&
      kinsectLevel == null &&
      songs.isEmpty &&
      arcShot == null &&
      chargeShots.isEmpty &&
      coatings.isEmpty &&
      deviation == null &&
      ammo.isEmpty;

  /// Bows and bowguns get their own "Munição" card.
  bool get hasAmmo => chargeShots.isNotEmpty || ammo.isNotEmpty;
}

/// A bow charge shot or coating; [locked] ones need a skill (charge level 4)
/// or cannot be used (coatings).
final class BowShot {
  const BowShot({required this.name, this.locked = false});

  final LocalizedText name;
  final bool locked;
}

/// Bowgun ammo types, from Kiranico's abbreviations.
enum AmmoKind {
  normal,
  pierce,
  spread,
  shrapnel,
  sticky,
  cluster,
  flaming,
  water,
  thunder,
  freeze,
  dragon,
  poison,
  paralysis,
  sleep,
  exhaust,
  recover,
  demon,
  armor,
  slicing,
  wyvern,
  tranq;

  /// Elemental ammo lists normal and piercing capacity, not levels.
  bool get elemental =>
      const {flaming, water, thunder, freeze, dragon}.contains(this);
}

/// How many rounds of [kind] a bowgun loads, per level (0 = cannot load).
final class AmmoCapacity {
  const AmmoCapacity({required this.kind, required this.capacity});

  final AmmoKind kind;
  final List<int> capacity;
}
