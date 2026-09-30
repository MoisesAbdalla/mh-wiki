import 'package:flutter/material.dart';
import 'package:mh_wiki/features/monsters/domain/entities/effectiveness.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// 0–3 stars, or an "Imune" badge, with an accessible label such as
/// "Fogo: 3 de 3" / "Gelo: imune".
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
    final scheme = Theme.of(context).colorScheme;
    final isImmune = effectiveness == Effectiveness.immune;
    final label = isImmune
        ? l10n.immuneSemantics(elementName)
        : l10n.starsSemantics(elementName, effectiveness.stars);

    final Widget visual;
    if (isImmune) {
      visual = Chip(
        label: Text(l10n.immune),
        visualDensity: VisualDensity.compact,
        avatar: const Icon(Icons.block, size: 16),
      );
    } else {
      final color = highlighted ? scheme.primary : scheme.tertiary;
      visual = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Icon(
              i < effectiveness.stars ? Icons.star : Icons.star_border,
              size: 22,
              color: i < effectiveness.stars ? color : scheme.outline,
            ),
        ],
      );
    }

    return Semantics(
      label: label,
      container: true,
      child: ExcludeSemantics(child: visual),
    );
  }
}
