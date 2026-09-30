import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/widgets/game_tabs.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Game filter shown as tabs above the list (002 FR-009).
class GameFilterBar extends StatelessWidget {
  const GameFilterBar({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Game? selected;
  final ValueChanged<Game?> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).gameFilterLabel,
    container: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GameTabs(selected: selected, onChanged: onChanged),
    ),
  );
}
