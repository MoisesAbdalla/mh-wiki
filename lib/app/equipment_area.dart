import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/game_tabs.dart';

/// Builds a game's page with the game tabs as its [header].
typedef GamePageBuilder = Widget Function(Widget header);

/// An area with one page per game behind the game logos (010 FR-001):
/// Armas and Armaduras. Each game keeps its own page and state in an
/// [IndexedStack]; a page is built on its tab's first visit. Games without a
/// page read "em breve".
class EquipmentArea extends StatefulWidget {
  const EquipmentArea({required this.game, required this.pages, super.key});

  /// The game shown, shared with whoever opens the area on a game.
  final ValueNotifier<Game> game;
  final Map<Game, GamePageBuilder> pages;

  @override
  State<EquipmentArea> createState() => _EquipmentAreaState();
}

class _EquipmentAreaState extends State<EquipmentArea> {
  final _visited = <Game>{};

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Game>(
    valueListenable: widget.game,
    builder: (context, game, _) {
      final games = widget.pages.keys.toList();
      final shown = widget.pages.containsKey(game) ? game : games.first;
      _visited.add(shown);
      Widget header() => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Space.gutter(MediaQuery.sizeOf(context).width),
        ),
        child: GameTabs(
          selected: shown,
          includeAll: false,
          enabledGames: widget.pages.keys.toSet(),
          onChanged: (g) {
            if (g != null && widget.pages.containsKey(g)) widget.game.value = g;
          },
        ),
      );
      return IndexedStack(
        index: games.indexOf(shown),
        children: [
          for (final g in games)
            if (_visited.contains(g))
              KeyedSubtree(key: ValueKey(g), child: widget.pages[g]!(header()))
            else
              const SizedBox.shrink(),
        ],
      );
    },
  );
}
