import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/breakpoints.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_switcher.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monster_detail_page.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_list_pane.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Home screen. Chooses the layout by available width (FR-019):
/// compact → list with a pushed detail route; expanded → list + detail pane.
///
/// The selection lives in the controller, so crossing the breakpoint keeps it
/// (FR-020): shrinking with a selection pushes the detail route; growing with
/// the route open pops it and the pane shows the same monster.
class MonstersPage extends StatefulWidget {
  const MonstersPage({
    required this.controller,
    this.actions,
    this.extraSections,
    super.key,
  });

  final MonsterListController controller;
  final List<Widget>? actions;

  /// Cards the app adds after the monster's own (006 US3).
  final MonsterExtraSections? extraSections;

  @override
  State<MonstersPage> createState() => _MonstersPageState();
}

class _MonstersPageState extends State<MonstersPage> {
  Route<void>? _detailRoute;
  bool _expanded = false;

  MonsterListController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scheduleSync);
  }

  @override
  void didUpdateWidget(MonstersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_scheduleSync);
      widget.controller.addListener(_scheduleSync);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_scheduleSync);
    super.dispose();
  }

  void _scheduleSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncDetailRoute());
  }

  /// Keeps the pushed detail route consistent with layout + selection.
  void _syncDetailRoute() {
    if (!mounted) return;
    final hasSelection = _controller.selectedMonster != null;
    final route = _detailRoute;

    if (!_expanded && hasSelection && route == null) {
      final newRoute = MaterialPageRoute<void>(
        builder: (_) => MonsterDetailPage(
          controller: _controller,
          extraSections: widget.extraSections,
        ),
      );
      _detailRoute = newRoute;
      Navigator.of(context).push(newRoute).then((_) {
        // Popped by the user (back): clear selection. Popped because the
        // layout expanded: _detailRoute was already reset, keep selection.
        if (identical(_detailRoute, newRoute)) {
          _detailRoute = null;
          _controller.clearSelection();
        }
      });
    } else if (route != null && (_expanded || !hasSelection)) {
      _detailRoute = null;
      if (route.isActive) Navigator.of(context).removeRoute(route);
    }
  }

  void _onSelect(Monster monster) => _controller.select(monster.id);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Width from MediaQuery (not LayoutBuilder): this page keeps rebuilding
    // on resize even while the detail route covers it, which is what lets
    // the route be popped when the window grows (FR-020).
    final expanded = MediaQuery.sizeOf(context).width >= Breakpoints.expanded;
    if (expanded != _expanded) {
      _expanded = expanded;
      _scheduleSync();
    }

    final list = MonsterListPane(
      controller: _controller,
      onSelect: _onSelect,
      highlightSelection: expanded,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: Text(l10n.appTitle),
        actions: [...?widget.actions, const SizedBox(width: 8)],
      ),
      body: expanded
          ? Row(
              children: [
                SizedBox(width: Breakpoints.listPaneWidth, child: list),
                const VerticalDivider(width: 1, color: HunterPalette.border),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      final monster = _controller.selectedMonster;
                      final Widget child;
                      if (monster == null) {
                        child = KeyedSubtree(
                          key: const ValueKey('no-selection'),
                          child: Center(
                            child: Text(
                              l10n.selectMonster,
                              style: notebookTitle(
                                size: 20,
                                color: HunterPalette.textMuted,
                              ),
                            ),
                          ),
                        );
                      } else {
                        child = MonsterDetailView(
                          key: ValueKey(monster.id),
                          monster: monster,
                          language: _controller.language,
                          versions: _controller.selectedVersions,
                          onSelectVersion: _controller.select,
                          showGame: _controller.query.game == null,
                          extraSections: widget.extraSections,
                        );
                      }
                      return NotebookSwitcher(child: child);
                    },
                  ),
                ),
              ],
            )
          : list,
    );
  }
}
