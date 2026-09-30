import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/monsters/domain/entities/drop_method.dart';
import 'package:mh_wiki/features/monsters/domain/entities/material_drop.dart';

/// The materials of one rank obtained the same way: "Entalhe", "Quebrar
/// cabeça", "Prêmio da missão: …" (005 FR-014).
final class MethodDropGroup {
  const MethodDropGroup({
    required this.method,
    required this.drops,
    this.partId,
    this.methodLabel,
  });

  final DropMethod method;

  /// Set for [DropMethod.breakPart].
  final String? partId;

  /// Set for [DropMethod.other].
  final LocalizedText? methodLabel;

  /// In dataset order.
  final List<MaterialDrop> drops;
}
