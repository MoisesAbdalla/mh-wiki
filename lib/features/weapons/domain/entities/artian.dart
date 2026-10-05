import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/weapons/domain/entities/sharpness.dart';

/// One Artian weapon of a type and rarity (010 research R2).
final class ArtianBase {
  const ArtianBase({
    required this.type,
    required this.rarity,
    required this.name,
    required this.attack,
    required this.affinity,
    required this.slots,
    this.sharpness,
    this.imageAsset,
  });

  final String type;
  final int rarity;
  final LocalizedText name;

  /// Displayed attack.
  final int attack;
  final int affinity;
  final List<int> slots;
  final Sharpness? sharpness;
  final String? imageAsset;
}

enum ArtianBoost { attack, affinity, element, sharpness, ammo }

/// The focus of a Gogma Artian (Gogmazios, Title Update 3): the Tarred
/// Device used to upgrade a rarity 8 Artian.
enum ArtianFocus { attack, affinity, element }

/// What a reinforcement roll of one kind adds, and how many times it can.
typedef ArtianBoostRule = ({ArtianBoost kind, int value, int max});

/// The Artian rules of a weapon type.
final class ArtianType {
  const ArtianType({
    required this.type,
    required this.bases,
    required this.elementsByRarity,
    required this.infusion,
    required this.attackPart,
    required this.affinityPart,
    required this.boosts,
    required this.rolls,
  });

  final String type;

  /// Rarity 6, 7 and 8.
  final List<ArtianBase> bases;

  /// Rarity → element or status kind → value. Kinds missing for a rarity
  /// cannot be chosen (bowguns, and status bows).
  final Map<int, Map<String, int>> elementsByRarity;

  /// Extra element when all 3 parts share it.
  final int infusion;

  /// Displayed attack one part with the Attack bonus adds.
  final int attackPart;

  /// Affinity one part with the Affinity bonus adds.
  final int affinityPart;
  final List<ArtianBoostRule> boosts;

  /// Reinforcement rolls in total.
  final int rolls;

  ArtianBase? base(int rarity) =>
      bases.where((b) => b.rarity == rarity).firstOrNull;

  ArtianBoostRule? boost(ArtianBoost kind) =>
      boosts.where((b) => b.kind == kind).firstOrNull;
}

/// The user's choices for an Artian (010 US3): the element, how many of the
/// 3 parts carry it, how many parts give Attack (the rest give Affinity),
/// and the reinforcement rolls they got.
final class ArtianBuild {
  const ArtianBuild({
    required this.type,
    required this.rarity,
    this.element,
    this.elementParts = 0,
    this.attackParts = 3,
    this.boosts = const {},
  });

  static const parts = 3;

  final String type;
  final int rarity;

  /// Element or status kind, or null for none.
  final String? element;

  /// Parts carrying [element]: 2 gives the element, 3 adds the infusion.
  final int elementParts;

  /// Parts with the Attack bonus; the others give Affinity.
  final int attackParts;
  final Map<ArtianBoost, int> boosts;

  int get affinityParts => parts - attackParts;

  int get rollsUsed => boosts.values.fold(0, (a, b) => a + b);

  ArtianBuild copyWith({
    int? rarity,
    String? element,
    bool clearElement = false,
    int? elementParts,
    int? attackParts,
    Map<ArtianBoost, int>? boosts,
  }) => ArtianBuild(
    type: type,
    rarity: rarity ?? this.rarity,
    element: clearElement ? null : element ?? this.element,
    elementParts: elementParts ?? this.elementParts,
    attackParts: attackParts ?? this.attackParts,
    boosts: boosts ?? this.boosts,
  );
}

/// The numbers of an Artian build.
typedef ArtianResult = ({
  int attack,
  int affinity,
  String? element,
  int? elementValue,
  bool infusion,
  Sharpness? sharpness,
  List<int> slots,
  int ammo,
});

/// Whether [build] respects the rules: parts and rolls in range, each boost
/// under its maximum and allowed for the type, and an element the type has.
bool validArtian(ArtianType t, ArtianBuild build) {
  if (t.base(build.rarity) == null) return false;
  if (build.attackParts < 0 || build.attackParts > ArtianBuild.parts) {
    return false;
  }
  if (build.elementParts < 0 || build.elementParts > ArtianBuild.parts) {
    return false;
  }
  final element = build.element;
  if (element != null &&
      !(t.elementsByRarity[build.rarity]?.containsKey(element) ?? false)) {
    return false;
  }
  if (build.rollsUsed > t.rolls) return false;
  for (final e in build.boosts.entries) {
    final rule = t.boost(e.key);
    if (e.value < 0 || (e.value > 0 && rule == null)) return false;
    if (rule != null && e.value > rule.max) return false;
  }
  return true;
}

/// The final stats of [build] (010 research R2):
/// - attack: base + Attack parts + Attack rolls;
/// - affinity: base + Affinity parts + Affinity rolls;
/// - element: only with 2+ parts of it; +infusion with 3; + Element rolls;
/// - sharpness: Sharpness rolls lengthen the top colour.
ArtianResult simulateArtian(ArtianType t, ArtianBuild build) {
  final base = t.base(build.rarity)!;
  int boosts(ArtianBoost k) =>
      (build.boosts[k] ?? 0) * (t.boost(k)?.value ?? 0);

  final attackRoll = t.boost(ArtianBoost.attack);
  // An Attack roll is +5 raw; the type's rule stores it as displayed attack.
  final attack =
      base.attack +
      build.attackParts * t.attackPart +
      (build.boosts[ArtianBoost.attack] ?? 0) * (attackRoll?.value ?? 0);
  final affinity =
      base.affinity +
      build.affinityParts * t.affinityPart +
      boosts(ArtianBoost.affinity);

  final element = build.element;
  final hasElement = element != null && build.elementParts >= 2;
  final infusion = hasElement && build.elementParts == ArtianBuild.parts;
  final elementValue = hasElement
      ? (t.elementsByRarity[build.rarity]?[element] ?? 0) +
            (infusion ? t.infusion : 0) +
            boosts(ArtianBoost.element)
      : null;

  Sharpness? sharpness = base.sharpness;
  final extra = boosts(ArtianBoost.sharpness);
  if (sharpness != null && extra > 0) {
    List<int> lengthen(List<int> bar) {
      final out = [...bar];
      final top = out.lastIndexWhere((v) => v > 0);
      out[top < 0 ? 0 : top] += extra;
      return out;
    }

    sharpness = Sharpness(
      base: lengthen(sharpness.base),
      handicraft: lengthen(sharpness.handicraft),
    );
  }

  return (
    attack: attack,
    affinity: affinity,
    element: hasElement ? element : null,
    elementValue: elementValue,
    infusion: infusion,
    sharpness: sharpness,
    slots: base.slots,
    ammo: boosts(ArtianBoost.ammo),
  );
}

/// An Artian the user built and saved (010 FR-012).
final class MyArtian {
  const MyArtian({required this.id, required this.name, required this.build});

  final String id;
  final String name;
  final ArtianBuild build;

  MyArtian renamed(String name) => MyArtian(id: id, name: name, build: build);
}

abstract interface class MyArtianRepository {
  Future<List<MyArtian>> load();

  /// Writes the whole list; `false` when the device refused.
  Future<bool> store(List<MyArtian> artians);
}
