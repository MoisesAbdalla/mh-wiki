import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/breakpoints.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_switcher.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_detail_view.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_list_pane.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The Armas area. Like `MonstersPage`: compact → list with a pushed detail
/// route; expanded → list + detail pane, the selection kept in the
/// controller across the breakpoint.
class WeaponsPage extends StatefulWidget {
  const WeaponsPage({required this.controller, this.actions, super.key});

  final WeaponListController controller;
  final List<Widget>? actions;

  @override
  State<WeaponsPage> createState() => _WeaponsPageState();
}

class _WeaponsPageState extends State<WeaponsPage> {
  Route<void>? _detailRoute;
  bool _expanded = false;

  WeaponListController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scheduleSync);
    // The page is built on the first visit to the area (AppShell).
    _controller.ensureLoaded();
  }

  @override
  void didUpdateWidget(WeaponsPage oldWidget) {
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

  void _syncDetailRoute() {
    if (!mounted) return;
    final hasSelection = _controller.selectedWeapon != null;
    final route = _detailRoute;

    if (!_expanded && hasSelection && route == null) {
      final newRoute = MaterialPageRoute<void>(
        builder: (_) => WeaponDetailPage(controller: _controller),
      );
      _detailRoute = newRoute;
      Navigator.of(context).push(newRoute).then((_) {
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

  void _onSelect(Weapon weapon) => _controller.select(weapon.id);

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
                    listenable: _controller,
                    builder: (context, _) {
                      final weapon = _controller.selectedWeapon;
                      final catalog = _controller.catalog;
                      final Widget child;
                      if (weapon == null || catalog == null) {
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

/// Full-screen detail used in the compact layout.
class WeaponDetailPage extends StatelessWidget {
  const WeaponDetailPage({required this.controller, super.key});

  final WeaponListController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final weapon = controller.selectedWeapon;
        final catalog = controller.catalog;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              weapon == null ? '' : l10n.gameName(weapon.id.game),
              overflow: TextOverflow.ellipsis,
              style: notebookTitle(color: HunterPalette.textMuted),
            ),
          ),
          body: weapon == null || catalog == null
              ? const SizedBox.shrink()
              : NotebookSwitcher(
                  child: WeaponDetailView(
                    key: ValueKey(weapon.id),
                    weapon: weapon,
                    catalog: catalog,
                    onSelectWeapon: (w) => controller.select(w.id),
                  ),
                ),
        );
      },
    );
  }
}
