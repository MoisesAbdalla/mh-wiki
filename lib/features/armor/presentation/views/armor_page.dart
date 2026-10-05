import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/breakpoints.dart';
import 'package:mh_wiki/core/presentation/material_droppers.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_switcher.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_detail_views.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_list_panes.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The Armaduras area (007). Like the weapons page: compact → list with a
/// pushed detail route; expanded → list + detail pane, the selection kept in
/// the controller across the breakpoint.
class ArmorPage extends StatefulWidget {
  const ArmorPage({
    required this.controller,
    this.actions,
    this.sources = MaterialSourceLookup.empty,
    this.onOpenMonster,
    this.header,
    super.key,
  });

  /// The area's game tabs, above the list.
  final Widget? header;

  final ArmorController controller;
  final List<Widget>? actions;
  final MaterialSourceLookup sources;
  final ValueChanged<MaterialDropper>? onOpenMonster;

  @override
  State<ArmorPage> createState() => _ArmorPageState();
}

class _ArmorPageState extends State<ArmorPage> {
  Route<void>? _detailRoute;
  bool _expanded = false;

  ArmorController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scheduleSync);
    // Built on the first visit to the area (AppShell).
    _controller.ensureLoaded();
    _scheduleSync();
  }

  @override
  void didUpdateWidget(ArmorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_scheduleSync);
      widget.controller
        ..addListener(_scheduleSync)
        ..ensureLoaded();
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
    final hasSelection = _controller.selection != null;
    final route = _detailRoute;
    if (!_expanded && hasSelection && route == null) {
      final newRoute = MaterialPageRoute<void>(
        builder: (_) => ArmorDetailPage(
          controller: _controller,
          sources: widget.sources,
          onOpenMonster: widget.onOpenMonster,
        ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expanded = MediaQuery.sizeOf(context).width >= Breakpoints.expanded;
    if (expanded != _expanded) {
      _expanded = expanded;
      _scheduleSync();
    }
    final list = ArmorListPane(
      controller: _controller,
      highlightSelection: expanded,
      header: widget.header,
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
                    builder: (context, _) => NotebookSwitcher(
                      child: armorDetailFor(
                        _controller,
                        sources: widget.sources,
                        onOpenMonster: widget.onOpenMonster,
                        empty: KeyedSubtree(
                          key: const ValueKey('no-selection'),
                          child: Center(
                            child: Text(
                              l10n.selectArmorItem,
                              style: notebookTitle(
                                color: HunterPalette.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : list,
    );
  }
}

/// The detail of the controller's selection, or [empty].
Widget armorDetailFor(
  ArmorController controller, {
  required MaterialSourceLookup sources,
  required ValueChanged<MaterialDropper>? onOpenMonster,
  required Widget empty,
}) {
  final catalog = controller.catalog;
  if (catalog == null) return empty;
  final language = controller.language;
  if (controller.selectedSet case final set?) {
    return ArmorSetDetailView(
      key: ValueKey(('set', set.id)),
      set: set,
      catalog: catalog,
      sources: sources,
      onOpenMonster: onOpenMonster,
      language: language,
      onOpenSkill: (s) => controller.select(ArmorTab.skills, s.id),
    );
  }
  if (controller.selectedSkill case final skill?) {
    return SkillDetailView(
      key: ValueKey(('skill', skill.id)),
      skill: skill,
      catalog: catalog,
      language: language,
      onOpenDecoration: (d) => controller.select(ArmorTab.decorations, d.id),
      onOpenSet: (id) => controller.select(ArmorTab.sets, id),
    );
  }
  if (controller.selectedTalisman case final talisman?) {
    return TalismanDetailView(
      key: ValueKey(('talisman', talisman.id)),
      talisman: talisman,
      catalog: catalog,
      sources: sources,
      onOpenMonster: onOpenMonster,
      language: language,
      onOpenSkill: (s) => controller.select(ArmorTab.skills, s.id),
    );
  }
  if (controller.selectedDecoration case final deco?) {
    return DecorationDetailView(
      key: ValueKey(('decoration', deco.id)),
      decoration: deco,
      catalog: catalog,
      sources: sources,
      onOpenMonster: onOpenMonster,
      language: language,
      onOpenSkill: (s) => controller.select(ArmorTab.skills, s.id),
    );
  }
  return empty;
}

/// Full-screen detail used in the compact layout.
class ArmorDetailPage extends StatelessWidget {
  const ArmorDetailPage({
    required this.controller,
    this.sources = MaterialSourceLookup.empty,
    this.onOpenMonster,
    super.key,
  });

  final ArmorController controller;
  final MaterialSourceLookup sources;
  final ValueChanged<MaterialDropper>? onOpenMonster;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(),
      body: NotebookSwitcher(
        child: armorDetailFor(
          controller,
          sources: sources,
          onOpenMonster: onOpenMonster,
          empty: const SizedBox.shrink(),
        ),
      ),
    ),
  );
}
