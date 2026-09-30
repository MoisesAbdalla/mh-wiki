import 'package:mh_wiki/core/domain/localized_text.dart';

/// Item obtained from monsters. Named `MonsterMaterial` to avoid clashing with
/// Flutter's `Material` widget.
final class MonsterMaterial {
  const MonsterMaterial({required this.id, required this.name, this.rarity});

  final String id;
  final LocalizedText name;
  final int? rarity;
}
