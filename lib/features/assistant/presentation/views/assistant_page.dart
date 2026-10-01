import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/breakpoints.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_switcher.dart';
import 'package:mh_wiki/core/presentation/widgets/underline_tabs.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/assistant_lists.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/build_detail_view.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The Assistente area (008). Like Armaduras: compact → list with a pushed
/// detail route; expanded → list + detail pane, the selection kept in the
/// controller across the breakpoint.
class AssistantPage extends StatefulWidget {
  const AssistantPage({
    required this.controller,
    this.actions,
    this.typePicker,
    this.typeName,
    this.onOpen,
    super.key,
  });

  final AssistantController controller;
  final List<Widget>? actions;
  final TypePickerBuilder? typePicker;
  final String Function(String typeId)? typeName;

  /// Opens a known build item in Armas or Armaduras.
  final ValueChanged<CatalogRef>? onOpen;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  Route<void>? _detailRoute;
  bool _expanded = false;

  AssistantController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scheduleSync);
    // Built on the first visit to the area (AppShell).
    _controller.ensureLoaded();
    _scheduleSync();
  }

  @override
  void didUpdateWidget(AssistantPage oldWidget) {
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
        builder: (_) => ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => Scaffold(
            appBar: AppBar(),
            body: NotebookSwitcher(
              child: _detail(context, empty: const SizedBox.shrink()),
            ),
          ),
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

  Widget _detail(BuildContext context, {required Widget empty}) {
    final selection = _controller.selection;
    if (selection == null) return empty;
    final saved = selection.saved;
    return BuildDetailView(
      key: ValueKey(('build', saved?.id ?? selection.build.id)),
      curated: selection.build,
      language: _controller.language,
      typeName: widget.typeName,
      savedName: saved?.name,
      onOpen: widget.onOpen,
      onSave: saved == null ? () => _save(context, selection.build) : null,
      onRename: saved == null ? null : () => _rename(context),
      onDelete: saved == null ? null : () => _delete(context),
    );
  }

  Future<void> _save(BuildContext context, CuratedBuild build) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (await _controller.save(build)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.buildSaved)));
    }
  }

  Future<void> _rename(BuildContext context) async {
    final saved = _controller.selection?.saved;
    if (saved == null) return;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _RenameDialog(initial: saved.name),
    );
    if (name != null) await _controller.rename(saved, name);
  }

  Future<void> _delete(BuildContext context) async {
    final saved = _controller.selection?.saved;
    if (saved == null) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteBuildConfirm(saved.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.deleteBuild,
              style: const TextStyle(color: HunterPalette.negative),
            ),
          ),
        ],
      ),
    );
    if (ok ?? false) await _controller.delete(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expanded = MediaQuery.sizeOf(context).width >= Breakpoints.expanded;
    if (expanded != _expanded) {
      _expanded = expanded;
      _scheduleSync();
    }
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final list = ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: UnderlineTabs<AssistantTab>(
              options: [
                TabOption(
                  value: AssistantTab.recommended,
                  text: l10n.assistantTabRecommended,
                ),
                TabOption(
                  value: AssistantTab.saved,
                  text: l10n.assistantTabSaved,
                ),
                TabOption(
                  value: AssistantTab.build,
                  text: l10n.assistantTabBuild,
                  semanticsLabel: l10n.areaComingSoon(l10n.assistantTabBuild),
                  enabled: false,
                ),
              ],
              selected: _controller.tab,
              onChanged: _controller.selectTab,
            ),
          ),
          Expanded(
            child: switch (_controller.tab) {
              AssistantTab.saved => SavedBuildsList(
                controller: _controller,
                highlightSelection: expanded,
              ),
              _ => RecommendedList(
                controller: _controller,
                typePicker: widget.typePicker,
                highlightSelection: expanded,
              ),
            },
          ),
        ],
      ),
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
                      child: _detail(
                        context,
                        empty: KeyedSubtree(
                          key: const ValueKey('no-selection'),
                          child: Center(
                            child: Text(
                              l10n.selectBuild,
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

/// Asks for a saved build's new name.
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.renameBuild),
      content: TextField(
        controller: _text,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.buildName),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_text.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
