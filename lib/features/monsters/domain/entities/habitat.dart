import 'package:mh_wiki/core/domain/localized_text.dart';

/// Region or map of a game where a monster can be found (FR-009).
final class Habitat {
  const Habitat({required this.id, required this.name});

  final String id;
  final LocalizedText name;
}
