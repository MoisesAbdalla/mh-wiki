import 'package:mh_wiki/features/monsters/domain/entities/material_drop.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_material.dart';

/// All the ways to obtain one material within a rank.
final class MaterialDropGroup {
  const MaterialDropGroup({required this.material, required this.drops});

  final MonsterMaterial material;
  final List<MaterialDrop> drops;
}
