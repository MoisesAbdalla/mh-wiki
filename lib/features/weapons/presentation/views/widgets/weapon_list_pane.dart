import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/game_tabs.dart';
import 'package:mh_wiki/core/presentation/widgets/underline_tabs.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/search_field.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/models/weapon_list_state.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_tree_card.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_type_picker.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The Armas list (006 ui-contract "Armas: list") with its loading, failure
/// and empty states. The filters scroll away with the list, so nothing
/// overflows at 320 dp and 200 % text.
class WeaponListPane extends StatelessWidget {
  const WeaponListPane({
    required this.controller,
    required this.onSelect,
    this.highlightSelection = false,
    this.header,
    super.key,
  });

  final WeaponListController controller;
  final ValueChanged<Weapon> onSelect;

  /// Shown above the list in every state (the area's game tabs); replaces
  /// the list's own game tabs.
  final Widget? header;

  /// In the expanded layout the selected row stays highlighted.
  final bool highlightSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final list = ListenableBuilder(
      listenable: controller,
      builder: (context, _) => switch (controller.state) {
        WeaponListLoading() => const Center(child: CircularProgressIndicator()),
        WeaponListFailed() => _Message(
          icon: Icons.cloud_off,
          text: l10n.weaponsLoadFailed,
          action: l10n.retry,
          onAction: controller.load,
        ),
        final WeaponListLoaded state => _LoadedList(
          state: state,
          controller: controller,
          onSelect: onSelect,
          highlightSelection: highlightSelection,
          gameTabs: header == null,
        ),
      },
    );
    final top = header;
    if (top == null) return list;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        top,
        Expanded(child: list),
      ],
    );
  }
}

class _LoadedList extends StatelessWidget {
  const _LoadedList({
    required this.state,
    required this.controller,
    required this.onSelect,
    required this.highlightSelection,
    this.gameTabs = true,
  });

  final bool gameTabs;
  final WeaponListLoaded state;
  final WeaponListController controller;
  final ValueChanged<Weapon> onSelect;
  final bool highlightSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = state.query;
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final only = query.onlyLabel;

    return CustomScrollView(
      key: const PageStorageKey('weapon-list'),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (gameTabs)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: gutter),
                  child: GameTabs(
                    selected: controller.game,
                    includeAll: false,
                    enabledGames: const {Game.riseSunbreak},
                    onChanged: (_) {},
                  ),
                ),
              WeaponTypePicker(
                types: state.catalog.types,
                selectedId: query.onlyIds == null ? query.typeId : null,
                language: controller.language,
                game: controller.game,
                onChanged: controller.setType,
              ),
              if (only != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InputChip(
                      label: Text(only),
                      onDeleted: controller.clearOnly,
                      deleteButtonTooltipMessage: l10n.clearFilters,
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: gutter),
                  child: UnderlineTabs<Rank?>(
                    textSize: 15,
                    options: [
                      TabOption(value: null, text: l10n.rankAll),
                      for (final rank in controller.game.allowedRanks)
                        TabOption(value: rank, text: l10n.rankName(rank)),
                    ],
                    selected: query.rank,
                    onChanged: controller.setRank,
                  ),
                ),
              SearchField(
                text: query.text,
                hint: l10n.searchWeaponHint,
                onChanged: controller.setSearchText,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        if (state.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _Message(
              icon: Icons.search_off,
              text: l10n.noWeaponsFound,
              action: query.hasFilters ? l10n.clearFilters : null,
              onAction: controller.clearFilters,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: SliverList.builder(
              itemCount: state.trees.length,
              itemBuilder: (context, i) => WeaponTreeCard(
                key: ValueKey(state.trees[i].id),
                tree: state.trees[i],
                selectedId: highlightSelection ? state.selectedId : null,
                language: controller.language,
                onSelect: onSelect,
              ),
            ),
          ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    required this.onAction,
    this.action,
  });

  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final label = action;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: HunterPalette.gold),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            if (label != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(label)),
            ],
          ],
        ),
      ),
    );
  }
}
