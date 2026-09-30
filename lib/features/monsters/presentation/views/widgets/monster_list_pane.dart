import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/element_icon.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_entry.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/models/monster_list_state.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/game_filter_bar.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/search_field.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The monster list with its loading, error and partial-failure states.
class MonsterListPane extends StatelessWidget {
  const MonsterListPane({
    required this.controller,
    required this.onSelect,
    this.highlightSelection = false,
    super.key,
  });

  final MonsterListController controller;
  final ValueChanged<Monster> onSelect;

  /// In the expanded layout the selected tile stays highlighted.
  final bool highlightSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => switch (controller.state) {
        MonsterListLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        MonsterListLoadFailed() => _LoadFailed(
          message: l10n.loadFailed,
          retryLabel: l10n.retry,
          onRetry: controller.load,
        ),
        final MonsterListLoaded state => _LoadedList(
          state: state,
          controller: controller,
          onSelect: onSelect,
          highlightSelection: highlightSelection,
        ),
      },
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const _LoadFailed({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 40, color: HunterPalette.gold),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    ),
  );
}

class _LoadedList extends StatelessWidget {
  const _LoadedList({
    required this.state,
    required this.controller,
    required this.onSelect,
    required this.highlightSelection,
  });

  final MonsterListLoaded state;
  final MonsterListController controller;
  final ValueChanged<Monster> onSelect;
  final bool highlightSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = controller.language;
    final showHeaders = state.query.game == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.failedGames.isNotEmpty)
          MaterialBanner(
            content: Text(
              l10n.failedGamesBanner(
                state.failedGames.keys.map(l10n.gameName).join(', '),
              ),
            ),
            leading: const Icon(Icons.warning_amber, color: HunterPalette.gold),
            actions: const [SizedBox.shrink()],
          ),
        SearchField(
          text: state.query.text,
          onChanged: controller.setSearchText,
        ),
        GameFilterBar(
          selected: state.query.game,
          onChanged: controller.setGame,
        ),
        const SizedBox(height: 4),
        Expanded(
          child: state.isEmpty
              ? _NoResults(
                  hasActiveFilters: state.hasActiveFilters,
                  onClear: controller.clearFilters,
                )
              : CustomScrollView(
                  key: const PageStorageKey('monster-list'),
                  slivers: [
                    for (final section in state.sections)
                      SliverMainAxisGroup(
                        slivers: [
                          // Sticky per-game header only in "Todos" (FR-006).
                          if (showHeaders)
                            PinnedHeaderSliver(
                              child: _GameCaption(
                                title: l10n.gameSectionTitle(section.game),
                              ),
                            ),
                          SliverList.builder(
                            itemCount: section.entries.length,
                            itemBuilder: (context, index) {
                              final entry = section.entries[index];
                              return _MonsterTile(
                                entry: entry,
                                language: language,
                                selected:
                                    highlightSelection &&
                                    _isInFamily(entry, state.selectedId),
                                onTap: onSelect,
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// A row is selected when its base or one of its versions is (004).
bool _isInFamily(MonsterEntry entry, MonsterId? selected) =>
    selected != null &&
    (entry.base.id == selected || entry.versions.any((v) => v.id == selected));

class _MonsterTile extends StatelessWidget {
  const _MonsterTile({
    required this.entry,
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final MonsterEntry entry;
  final NameLanguage language;
  final bool selected;
  final ValueChanged<Monster> onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final monster = entry.base;
    final l10n = AppLocalizations.of(context);
    final name = monster.name.resolve(language);
    final classification = monster.classification.resolve(language);
    final matched = entry.matchedVersion?.name.resolve(language);
    final versionsHint = l10n.versionCount(entry.versions.length);
    final muted = textTheme.bodyMedium?.copyWith(
      color: HunterPalette.textMuted,
    );
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return Material(
      color: selected ? HunterPalette.panelHighlight : Colors.transparent,
      child: InkWell(
        onTap: () => onTap(entry.target),
        child: Semantics(
          selected: selected,
          button: true,
          label: [
            name,
            classification,
            ?matched,
            if (entry.versions.isNotEmpty) versionsHint,
          ].join(', '),
          excludeSemantics: true,
          child: DecoratedBox(
            // A hairline between rows; the selected row also gets a gold
            // mark at its left edge (005 contract, List).
            decoration: BoxDecoration(
              border: Border(
                bottom: const BorderSide(color: HunterPalette.borderSubtle),
                left: BorderSide(
                  color: selected ? HunterPalette.gold : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(gutter - 2, 10, gutter, 10),
              child: Row(
                children: [
                  MonsterImage(asset: monster.imageAsset, size: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: notebookTitle(size: 19, height: 1.1),
                        ),
                        const SizedBox(height: 2),
                        // The game is already shown by the section caption
                        // or the active tab (002 US2).
                        Wrap(
                          spacing: 6,
                          children: [
                            Text(
                              classification,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: muted,
                            ),
                            if (matched == null &&
                                entry.versions.isNotEmpty) ...[
                              Text('·', style: muted),
                              Text(versionsHint, style: muted),
                            ],
                          ],
                        ),
                        // The version the search matched opens (004).
                        if (matched != null)
                          Text(
                            matched,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: HunterPalette.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (monster.weaknesses.primaryWeakness case final weak?)
                    _WeaknessBadge(element: weak),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Game caption of a group in "Todos": name and a hairline (005 R10).
class _GameCaption extends StatelessWidget {
  const _GameCaption({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return ColoredBox(
      color: HunterPalette.background,
      child: Padding(
        padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 6),
        child: Row(
          children: [
            Flexible(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: notebookTitle(
                    size: 17,
                    color: HunterPalette.textMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Divider(color: HunterPalette.border, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary weakness on the list item: element symbol and name (002 FR-005,
/// 005 FR-012).
class _WeaknessBadge extends StatelessWidget {
  const _WeaknessBadge({required this.element});

  final ElementType element;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 10),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElementIcon(element: element, size: 16),
        const SizedBox(width: 5),
        Text(
          AppLocalizations.of(context).elementName(element),
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: HunterPalette.text),
        ),
      ],
    ),
  );
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.hasActiveFilters, required this.onClear});

  final bool hasActiveFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 40, color: HunterPalette.gold),
            const SizedBox(height: 16),
            Text(l10n.noResults, textAlign: TextAlign.center),
            if (hasActiveFilters) ...[
              const SizedBox(height: 4),
              Text(l10n.activeFiltersHint, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onClear,
                child: Text(l10n.clearFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
