import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/widgets/element_icon.dart';
import 'package:mh_wiki/core/presentation/widgets/hunter_panel.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/core/presentation/widgets/ornament_header.dart';
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
      child: HunterPanel(
        margin: const EdgeInsets.all(24),
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
                              child: OrnamentHeader(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 3, 12, 3),
      child: Material(
        color: selected ? HunterPalette.panelHighlight : HunterPalette.panel,
        shape: Border.all(
          color: selected ? HunterPalette.gold : HunterPalette.borderSubtle,
        ),
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
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  MonsterImage(asset: monster.imageAsset, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: HunterPalette.text,
                          ),
                        ),
                        Text(
                          // The game is already shown by the section header or
                          // the active tab (002 US2).
                          classification,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: muted,
                        ),
                        // The version the search matched opens (004).
                        if (matched != null)
                          Text(
                            matched,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: HunterPalette.gold,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (entry.versions.isNotEmpty)
                          Text(
                            versionsHint,
                            style: muted?.copyWith(fontStyle: FontStyle.italic),
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

/// Primary weakness on the list item (002 FR-005).
class _WeaknessBadge extends StatelessWidget {
  const _WeaknessBadge({required this.element});

  final ElementType element;

  @override
  Widget build(BuildContext context) {
    final color = elementColor(element);
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: color)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElementIcon(element: element, size: 16),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context).elementName(element),
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
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
        child: HunterPanel(
          margin: const EdgeInsets.all(24),
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
      ),
    );
  }
}
