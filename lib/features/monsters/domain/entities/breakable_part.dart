import 'package:mh_wiki/core/domain/localized_text.dart';

/// Body part that can be broken; [severable] parts can also be cut (FR-010).
final class BreakablePart {
  const BreakablePart({
    required this.id,
    required this.name,
    required this.severable,
  });

  final String id;
  final LocalizedText name;
  final bool severable;
}
