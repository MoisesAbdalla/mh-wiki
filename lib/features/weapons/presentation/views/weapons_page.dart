import 'package:flutter/material.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/weapons/presentation/views/artian_simulator_page.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/artian_controller.dart';
import 'package:mh_wiki/core/presentation/breakpoints.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_switcher.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/core/presentation/material_droppers.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapon_detail_page.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_detail_view.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_list_pane.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The Armas area. Like `MonstersPage`: compact → list with a pushed detail
/// route; expanded → list + detail pane, the selection kept in the
/// controller across the breakpoint.
class WeaponsPage extends StatefulWidget {
  const WeaponsPage({
    required this.controller,
    this.actions,
    this.sources = MaterialSourceLookup.empty,
    this.onOpenMonster,
    this.header,
    this.onOpenSkill,
    this.artians,
    super.key,
  });

  /// The user's Artian and the simulator (Wilds).
  final ArtianController? artians;

  /// The area's game tabs, above the list.
  final Widget? header;

  /// Opens a weapon skill in Armaduras (Wilds).
  final ValueChanged<String>? onOpenSkill;

  final WeaponListController controller;
  final List<Widget>? actions;

  /// "Dropado por" sources and navigation, given by the app layer.
  final MaterialSourceLookup sources;
  final ValueChanged<MaterialDropper>? onOpenMonster;

  @override
  State<WeaponsPage> createState() => _WeaponsPageState();
}

class _WeaponsPageState extends State<WeaponsPage> {
  Route<void>? _detailRoute;
  bool _expanded = false;

  WeaponListController get _controller => widget.controller;
  ArtianController? get _artians => widget.artians;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scheduleSync);
    _artians?.addListener(_scheduleSync);
    _artians?.ensureLoaded();
    // The page is built on the first visit to the area (AppShell), maybe
    // with a weapon already chosen from a monster (006 US3).
    _controller.ensureLoaded();
    _scheduleSync();
  }

  @override
  void didUpdateWidget(WeaponsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_scheduleSync);
      widget.controller.addListener(_scheduleSync);
    }
    if (oldWidget.artians != widget.artians) {
      oldWidget.artians?.removeListener(_scheduleSync);
      widget.artians?.addListener(_scheduleSync);
      widget.artians?.ensureLoaded();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_scheduleSync);
    _artians?.removeListener(_scheduleSync);
    super.dispose();
  }

  void _scheduleSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncDetailRoute());
  }

  void _syncDetailRoute() {
    if (!mounted) return;
    final artians = _artians;
    final artian = artians?.selection != null;
    final hasSelection = _controller.selectedWeapon != null || artian;
    final route = _detailRoute;

    if (!_expanded && hasSelection && route == null) {
      final newRoute = MaterialPageRoute<void>(
        builder: (_) => artian
            ? ArtianSimulatorPage(
                weapons: _controller,
                artians: artians!,
                onOpenGogmazios: _openGogmazios,
              )
            : WeaponDetailPage(
                controller: _controller,
                sources: widget.sources,
                onOpenMonster: widget.onOpenMonster,
                onOpenSkill: widget.onOpenSkill,
              ),
      );
      _detailRoute = newRoute;
      Navigator.of(context).push(newRoute).then((_) {
        if (identical(_detailRoute, newRoute)) {
          _detailRoute = null;
          _controller.clearSelection();
          _artians?.close();
        }
      });
    } else if (route != null && (_expanded || !hasSelection)) {
      _detailRoute = null;
      if (route.isActive) Navigator.of(context).removeRoute(route);
    }
  }

  /// Gogmazios in Monstros, through the "Dropado por" link.
  VoidCallback? get _openGogmazios => switch (widget.onOpenMonster) {
    final open? => () => open(
      const MaterialDropper(
        id: MonsterId(Game.wilds, 'gogmazios'),
        name: 'Gogmazios',
      ),
    ),
    null => null,
  };

  void _onSelect(Weapon weapon) {
    _artians?.close();
    _controller.select(weapon.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expanded = MediaQuery.sizeOf(context).width >= Breakpoints.expanded;
    if (expanded != _expanded) {
      _expanded = expanded;
      _scheduleSync();
    }

    final list = WeaponListPane(
      controller: _controller,
      onSelect: _onSelect,
      highlightSelection: expanded,
      header: widget.header,
      artians: _artians,
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
                SizedBox(width: Breakpoints.listPaneWidth + 40, child: list),
                const VerticalDivider(width: 1, color: HunterPalette.border),
                Expanded(
                  child: ListenableBuilder(
                    listenable: Listenable.merge([_controller, ?_artians]),
                    builder: (context, _) {
                      final weapon = _controller.selectedWeapon;
                      final catalog = _controller.catalog;
                      final artians = _artians;
                      final simulator = artians == null
                          ? null
                          : artianSimulatorFor(
                              _controller,
                              artians,
                              onOpenGogmazios: _openGogmazios,
                            );
                      final Widget child;
                      if (simulator != null) {
                        child = simulator;
                      } else if (weapon == null || catalog == null) {
                        child = KeyedSubtree(
                          key: const ValueKey('no-selection'),
                          child: Center(
                            child: Text(
                              l10n.selectWeapon,
                              style: notebookTitle(
                                color: HunterPalette.textMuted,
                              ),
                            ),
                          ),
                        );
                      } else {
                        child = WeaponDetailView(
                          key: ValueKey(weapon.id),
                          weapon: weapon,
                          catalog: catalog,
                          onSelectWeapon: _onSelect,
                          sources: widget.sources,
                          onOpenMonster: widget.onOpenMonster,
                          onOpenSkill: widget.onOpenSkill,
                          language: _controller.language,
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
