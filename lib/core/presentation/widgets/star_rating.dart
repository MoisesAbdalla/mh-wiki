import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Three stars (filled in cream, empty dimmed, gold when [highlighted]) or
/// the word "Imune", with an accessible label such as "Fogo: 3 de 3" /
/// "Gelo: imune". Immunity stays distinct from 0 stars (002 FR-006, 005
/// FR-010).
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

  static const _size = 18.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isImmune = effectiveness == Effectiveness.immune;
    final label = isImmune
        ? l10n.immuneSemantics(elementName)
        : l10n.starsSemantics(elementName, effectiveness.stars);

    final Widget visual = isImmune
        ? Text(
            l10n.immune,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HunterPalette.textMuted,
              fontStyle: FontStyle.italic,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Icon(
                  Icons.star_rounded,
                  size: _size,
                  color: i >= effectiveness.stars
                      ? HunterPalette.textDisabled
                      : highlighted
                      ? HunterPalette.gold
                      : HunterPalette.text,
                ),
            ],
          );

    return Semantics(
      label: label,
      container: true,
      child: ExcludeSemantics(child: visual),
    );
  }
}
