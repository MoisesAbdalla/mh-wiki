import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/models/monster_list_state.dart';
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
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48),
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
            leading: const Icon(Icons.warning_amber),
            actions: const [SizedBox.shrink()],
          ),
        Expanded(
          child: CustomScrollView(
            key: const PageStorageKey('monster-list'),
            slivers: [
              for (final section in state.sections) ...[
                if (showHeaders)
                  SliverToBoxAdapter(
                    child: _SectionHeader(title: l10n.gameName(section.game)),
                  ),
                SliverList.builder(
                  itemCount: section.monsters.length,
                  itemBuilder: (context, index) {
                    final monster = section.monsters[index];
                    return ListTile(
                      leading: MonsterImage(asset: monster.imageAsset),
                      title: Text(
                        monster.name.resolve(language),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        l10n.monsterSubtitle(
                          l10n.gameName(monster.id.game),
                          monster.classification.resolve(language),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected:
                          highlightSelection && monster.id == state.selectedId,
                      onTap: () => onSelect(monster),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}
