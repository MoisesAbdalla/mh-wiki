import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/core/presentation/widgets/underline_tabs.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_set_card.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_widgets.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/search_field.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The Armaduras list side: the three tabs and the list of the current tab,
/// with its loading, failure and empty states (007 ui-contract).
class ArmorListPane extends StatelessWidget {
  const ArmorListPane({
    required this.controller,
    this.highlightSelection = false,
    super.key,
  });

  final ArmorController controller;
  final bool highlightSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => switch (controller.state) {
        ArmorLoading() => const Center(child: CircularProgressIndicator()),
        ArmorFailed() => _Message(
          icon: Icons.cloud_off,
          text: l10n.armorLoadFailed,
          action: l10n.retry,
          onAction: controller.load,
        ),
        final ArmorLoaded state => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Space.gutter(MediaQuery.sizeOf(context).width),
              ),
              child: UnderlineTabs<ArmorTab>(
                options: [
                  TabOption(value: ArmorTab.sets, text: l10n.armorTabSets),
                  TabOption(value: ArmorTab.skills, text: l10n.armorTabSkills),
                  TabOption(
                    value: ArmorTab.decorations,
                    text: l10n.armorTabDecorations,
                  ),
                ],
                selected: state.tab,
                onChanged: controller.setTab,
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: state.tab.index,
                children: [
                  _SetList(
                    state: state,
                    controller: controller,
                    highlight: highlightSelection,
                  ),
                  _SkillList(state: state, controller: controller),
                  _DecorationList(state: state, controller: controller),
                ],
              ),
            ),
          ],
        ),
      },
    );
  }
}

class _SetList extends StatelessWidget {
  const _SetList({
    required this.state,
    required this.controller,
    required this.highlight,
  });

  final ArmorLoaded state;
  final ArmorController controller;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = state.setQuery;
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final language = controller.language;
    final chosen = query.skillId == null
        ? null
        : state.catalog.skill(query.skillId!);
    final selected = switch (state.selection) {
      (kind: ArmorTab.sets, :final id) when highlight => id,
      _ => null,
    };

    return CustomScrollView(
      key: const PageStorageKey('armor-sets'),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: gutter),
                child: UnderlineTabs<Rank?>(
                  textSize: 15,
                  options: [
                    TabOption(value: null, text: l10n.rankAll),
                    for (final rank in Rank.values)
                      TabOption(value: rank, text: l10n.rankName(rank)),
                  ],
                  selected: query.rank,
                  onChanged: controller.setRank,
                ),
              ),
              SearchField(
                text: query.text,
                hint: l10n.searchArmorHint,
                onChanged: controller.setSetText,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (chosen != null)
                      InputChip(
                        label: Text(chosen.name.resolve(language)),
                        onDeleted: controller.clearSkill,
                        deleteButtonTooltipMessage: l10n.clearFilters,
                      )
                    else
                      for (final s in controller.skillSuggestions)
                        ActionChip(
                          label: Text(s.name.resolve(language)),
                          onPressed: () => controller.chooseSkill(s.id),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (state.sets.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _Message(
              icon: Icons.search_off,
              text: l10n.noSetsFound,
              action: query.hasFilters ? l10n.clearFilters : null,
              onAction: controller.clearSetFilters,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: SliverList.builder(
              itemCount: state.sets.length,
              itemBuilder: (context, i) {
                final set = state.sets[i];
                return ArmorSetCard(
                  key: ValueKey(set.id),
                  set: set,
                  catalog: state.catalog,
                  selected: set.id == selected,
                  highlightSkill: query.skillId,
                  language: language,
                  onTap: () => controller.select(ArmorTab.sets, set.id),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SkillList extends StatelessWidget {
  const _SkillList({required this.state, required this.controller});

  final ArmorLoaded state;
  final ArmorController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = controller.language;
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    return CustomScrollView(
      key: const PageStorageKey('armor-skills'),
      slivers: [
        SliverToBoxAdapter(
          child: SearchField(
            text: state.skillText,
            hint: l10n.searchSkillHint,
            onChanged: controller.setSkillText,
          ),
        ),
        if (state.skills.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _Message(
              icon: Icons.search_off,
              text: l10n.noSkillsFound,
              onAction: () {},
            ),
          )
        else
          SliverList.builder(
            itemCount: state.skills.length,
            itemBuilder: (context, i) {
              final skill = state.skills[i];
              return InkWell(
                onTap: () => controller.select(ArmorTab.skills, skill.id),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: gutter),
                  child: RuledRow(
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.name.resolve(language),
                          style: notebookTitle(size: 16),
                        ),
                        Text(
                          skill.description.resolve(language),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: muted,
                        ),
                      ],
                    ),
                    trailing: Text(
                      l10n.skillMaxLevel(skill.maxLevel),
                      style: notebookNumber(
                        size: 13,
                        color: HunterPalette.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _DecorationList extends StatelessWidget {
  const _DecorationList({required this.state, required this.controller});

  final ArmorLoaded state;
  final ArmorController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = controller.language;
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    return CustomScrollView(
      key: const PageStorageKey('armor-decorations'),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: gutter),
                child: UnderlineTabs<int?>(
                  textSize: 15,
                  options: [
                    TabOption(value: null, text: l10n.allSlots),
                    for (var level = 1; level <= 4; level++)
                      TabOption(
                        value: level,
                        text: '$level',
                        semanticsLabel: l10n.slotLevelTitle(level),
                      ),
                  ],
                  selected: state.decorationSlot,
                  onChanged: controller.setDecorationSlot,
                ),
              ),
              SearchField(
                text: state.decorationText,
                hint: l10n.searchDecorationHint,
                onChanged: controller.setDecorationText,
              ),
            ],
          ),
        ),
        if (state.decorations.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _Message(
              icon: Icons.search_off,
              text: l10n.noDecorationsFound,
              onAction: () {},
            ),
          )
        else
          SliverList.builder(
            itemCount: state.decorations.length,
            itemBuilder: (context, i) {
              final deco = state.decorations[i];
              final skills = [
                for (final s in deco.skills)
                  '${state.catalog.skill(s.skillId)?.name.resolve(language) ?? s.skillId} '
                      '${l10n.skillLevelShort(s.level)}',
              ].join(' · ');
              return InkWell(
                onTap: () => controller.select(ArmorTab.decorations, deco.id),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: gutter),
                  child: RuledRow(
                    leading: SlotGems(slots: [deco.slotLevel]),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deco.name.resolve(language),
                          style: notebookTitle(size: 16),
                        ),
                        Text(skills, style: muted),
                      ],
                    ),
                  ),
                ),
              );
            },
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
