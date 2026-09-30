import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// "Todos" + one chip per game (FR-003). `null` means "Todos".
class GameFilterBar extends StatelessWidget {
  const GameFilterBar({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Game? selected;
  final ValueChanged<Game?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <(Game?, String)>[
      (null, l10n.filterAll),
      (Game.worldIceborne, l10n.filterWorldIceborne),
      (Game.riseSunbreak, l10n.filterRiseSunbreak),
      (Game.wilds, l10n.filterWilds),
    ];

    return Semantics(
      label: l10n.gameFilterLabel,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final (game, label) in options)
              ChoiceChip(
                label: Text(label),
                selected: selected == game,
                onSelected: (_) => onChanged(game),
              ),
          ],
        ),
      ),
    );
  }
}
