import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';

/// Named state or form in which a monster's weaknesses differ (FR-008a).
final class WeaknessState {
  const WeaknessState({
    required this.id,
    required this.name,
    required this.values,
  });

  final String id;
  final LocalizedText name;
  final Map<ElementType, Effectiveness> values;
}
