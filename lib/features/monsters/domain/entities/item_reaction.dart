import 'package:mh_wiki/core/domain/localized_text.dart';

/// How a monster reacts to a hunting item (003 FR-004).
enum ReactionEffect { affects, noEffect, conditional, unknown }

final class ItemReaction {
  const ItemReaction({required this.item, required this.effect, this.detail});

  const ItemReaction.unknown(this.item)
    : effect = ReactionEffect.unknown,
      detail = null;

  final String item;
  final ReactionEffect effect;

  /// Duration, flee chance or condition; required for `conditional`.
  final LocalizedText? detail;
}
