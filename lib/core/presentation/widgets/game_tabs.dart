import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/widgets/underline_tabs.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Game filter as tabs: "Todos" in text, then the official logo of each game
/// (005 FR-006/FR-007, research R5). `null` = Todos. A logo that cannot be
/// shown falls back to the game's short name.
class GameTabs extends StatelessWidget {
  const GameTabs({
    required this.selected,
    required this.onChanged,
    this.includeAll = true,
    this.enabledGames,
    super.key,
  });

  final Game? selected;
  final ValueChanged<Game?> onChanged;

  /// Shows the "Todos" tab first.
  final bool includeAll;

  /// Games that can be chosen; the others read "World, em breve" (006).
  /// `null` = every game.
  final Set<Game>? enabledGames;

  static String logoAsset(Game game) =>
      'assets/images/games/${game.datasetKey}.webp';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String shortName(Game game) => switch (game) {
      Game.worldIceborne => l10n.filterWorldIceborne,
      Game.riseSunbreak => l10n.filterRiseSunbreak,
      Game.wilds => l10n.filterWilds,
    };
    return UnderlineTabs<Game?>(
      options: [
        if (includeAll) TabOption(value: null, text: l10n.filterAll),
        for (final game in Game.values)
          if (enabledGames?.contains(game) ?? true)
            TabOption(
              value: game,
              text: shortName(game),
              image: logoAsset(game),
              semanticsLabel: l10n.gameName(game),
            )
          else
            TabOption(
              value: game,
              text: l10n.gameComingSoon(shortName(game)),
              image: logoAsset(game),
              semanticsLabel: l10n.gameComingSoon(l10n.gameName(game)),
              enabled: false,
            ),
      ],
      selected: selected,
      onChanged: onChanged,
    );
  }
}
