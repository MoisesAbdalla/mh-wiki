import 'package:mh_wiki/features/monsters/domain/entities/monster_material.dart';

/// A material needed to forge or upgrade a weapon: a quantity of one item, or
/// [points] of a category ("Anjanath Material(s) x10 pts.").
final class MaterialCost {
  const MaterialCost({required this.material, this.quantity, this.points})
    : assert((quantity == null) != (points == null));

  final MonsterMaterial material;
  final int? quantity;
  final int? points;
}
