import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// ★ to ★★★, ✕ for 0 stars, or an "Imune" tag, with an accessible label
/// such as "Fogo: 3 de 3" / "Gelo: imune". Immunity stays visually distinct
/// from 0 stars.
class StarRating extends StatelessWidget {
  const StarRating({
    required this.elementName,
    required this.effectiveness,
    this.highlighted = false,
    super.key,
  });

  final String elementName;
  final Effectiveness effectiveness;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isImmune = effectiveness == Effectiveness.immune;
    final label = isImmune
        ? l10n.immuneSemantics(elementName)
        : l10n.starsSemantics(elementName, effectiveness.stars);

    final Widget visual;
    if (isImmune) {
      visual = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: HunterPalette.textMuted),
        ),
        child: Text(
          l10n.immune,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: HunterPalette.textMuted,
          ),
        ),
      );
    } else if (effectiveness.stars == 0) {
      visual = const Text(
        '✕',
        style: TextStyle(fontSize: 15, color: HunterPalette.textMuted),
      );
    } else {
      visual = Text(
        '★' * effectiveness.stars,
        style: TextStyle(
          fontSize: 15,
          letterSpacing: 1,
          color: highlighted ? HunterPalette.goldBright : HunterPalette.gold,
        ),
      );
    }

    return Semantics(
      label: label,
      container: true,
      child: ExcludeSemantics(child: visual),
    );
  }
}
