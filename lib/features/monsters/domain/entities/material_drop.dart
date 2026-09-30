import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_material.dart';

/// One way to obtain a material in a rank ("Forma de Obtenção", FR-011).
final class MaterialDrop {
  const MaterialDrop({
    required this.material,
    required this.rank,
    required this.method,
    this.methodLabel,
    this.partId,
    this.ratePercent,
  });

  final MonsterMaterial material;
  final Rank rank;
  final DropMethod method;

  /// Present only for [DropMethod.other].
  final LocalizedText? methodLabel;

  /// Present only for [DropMethod.breakPart]; references a part id (FR-011a).
  final String? partId;

  /// `null` means the rate is unknown (FR-011b).
  final double? ratePercent;
}
