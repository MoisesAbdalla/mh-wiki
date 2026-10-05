import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/core/presentation/widgets/slot_icon.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_widgets.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_search.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/optimizer_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/views/talismans_page.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/assistant_labels.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/build_detail_view.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The Montar build tab (009): the request, or the results once searched.
class OptimizerTab extends StatelessWidget {
  const OptimizerTab({
    required this.controller,
    this.typeName,
    this.highlightSelection = false,
    super.key,
  });

  final OptimizerController controller;
  final String Function(String typeId)? typeName;
  final bool highlightSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = controller;
    if (c.loading && c.catalog == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.catalog == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.optimizerLoadFailed,
              textAlign: TextAlign.center,
              style: notebookTitle(size: 18, color: HunterPalette.textMuted),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: c.load, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    return switch (c.phase) {
      OptimizerResults(:final sets) => OptimizerResultsList(
        controller: c,
        sets: sets,
        typeName: typeName,
        highlightSelection: highlightSelection,
      ),
      _ => OptimizerRequestView(controller: c, typeName: typeName),
    };
  }
}

/// A thin strip with the request's context and one action ("alterar").
class _ContextStrip extends StatelessWidget {
  const _ContextStrip({
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, 10, gutter, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: HunterPalette.borderSubtle),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: HunterPalette.text),
                ),
              ),
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  foregroundColor: HunterPalette.gold,
                  minimumSize: const Size(48, 48),
                ),
                child: Text(action),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _typeOf(OptimizerController c, String Function(String)? typeName) =>
    typeName?.call(c.assistant.weaponType) ?? c.assistant.weaponType;

// ------------------------------------------------------------ request

/// Screen 1: the skills wanted, the weapon and talisman options, and the
/// button (009 ui-contract).
class OptimizerRequestView extends StatefulWidget {
  const OptimizerRequestView({
    required this.controller,
    this.typeName,
    super.key,
  });

  final OptimizerController controller;
  final String Function(String typeId)? typeName;

  @override
  State<OptimizerRequestView> createState() => _OptimizerRequestViewState();
}

class _OptimizerRequestViewState extends State<OptimizerRequestView> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _add(String id) {
    widget.controller.addSkill(id);
    _search.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = widget.controller;
    final language = c.assistant.language;
    final catalog = c.catalog!;
    final type = _typeOf(c, widget.typeName);
    final progress = progressText(l10n, c.assistant.progress);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final matches = c.matchingSkills(_search.text).take(8).toList();
    final chosen = c.skills.entries.toList();
    final searching = c.phase is OptimizerSearching;
    final small = Theme.of(context).textTheme.bodySmall;

    return ListView(
      key: const PageStorageKey('optimizer-request'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _ContextStrip(
          text:
              '${rankText(l10n, c.assistant.progress.rank)} · $progress · $type',
          action: l10n.alter,
          onTap: () => c.assistant.selectTab(AssistantTab.recommended),
        ),
        NotebookSection(
          number: 1,
          title: l10n.skillsWanted,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (c.canAddSkill)
                TextField(
                  key: const Key('skill-search'),
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l10n.searchSkill,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                  ),
                ),
              for (final s in matches)
                Semantics(
                  button: true,
                  label: l10n.addSkill(s.name.resolve(language)),
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => _add(s.id),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add,
                            size: 18,
                            color: HunterPalette.gold,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s.name.resolve(language))),
                          SkillPips(level: s.max, max: s.max),
                        ],
                      ),
                    ),
                  ),
                ),
              for (final (i, e) in chosen.indexed)
                _SkillRow(
                  skill: catalog.skills[e.key]!,
                  level: e.value,
                  language: language,
                  ruled: i < chosen.length - 1,
                  onLevel: (v) => c.setLevel(e.key, v),
                  onRemove: () => c.removeSkill(e.key),
                ),
              if (c.suggestions case final sugg
                  when sugg.isNotEmpty && c.canAddSkill) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.commonForType(type),
                  style: small?.copyWith(color: HunterPalette.textDisabled),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in sugg)
                      ActionChip(
                        labelStyle: small?.copyWith(
                          color: HunterPalette.textMuted,
                        ),
                        label: Text('+ ${s.name.resolve(language)}'),
                        tooltip: l10n.addSkill(s.name.resolve(language)),
                        onPressed: () => _add(s.id),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        NotebookSection(
          number: 2,
          title: l10n.weaponAndTalismans,
          child: Column(
            children: [
              RuledRow(
                label: _TwoLines(
                  l10n.weaponLabel,
                  c.fixedWeapon?.name.resolve(language) ??
                      l10n.anyWeaponUpTo(type, progress),
                ),
                trailing: TextButton(
                  key: const Key('choose-weapon'),
                  onPressed: () => showWeaponPicker(context, c),
                  child: Text(l10n.chooseWeapon),
                ),
              ),
              if (c.fixedWeaponId == null) ...[
                if (c.traitOptions case final traits when traits.isNotEmpty)
                  _FilterRow(
                    key: const Key('trait-filter'),
                    label: c.assistant.weaponType == 'gunlance'
                        ? l10n.shellingLabel
                        : l10n.phialLabel,
                    options: [
                      (value: null, text: l10n.anyWeapon),
                      for (final t in traits)
                        (value: t.key, text: t.name.resolve(language)),
                    ],
                    selected: c.weaponTrait,
                    onSelected: c.setWeaponTrait,
                  ),
                if (c.elementOptions case final elements
                    when elements.length > 1)
                  _FilterRow(
                    key: const Key('element-filter'),
                    label: l10n.elementOrStatus,
                    options: [
                      (value: null, text: l10n.anyWeapon),
                      for (final e in elements)
                        (value: e, text: elementName(l10n, e)),
                    ],
                    selected: c.weaponElement,
                    onSelected: c.setWeaponElement,
                  ),
                if (c.matchingWeaponCount == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n.noWeaponForFilter(progress),
                      style: small?.copyWith(color: HunterPalette.negative),
                    ),
                  ),
              ],
              RuledRow(
                label: _TwoLines(
                  l10n.myTalismans,
                  '${l10n.talismansCount(c.talismans.length)} · ${l10n.useTalismans}',
                ),
                trailing: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Switch(
                      key: const Key('use-talismans'),
                      value: c.useTalismans,
                      onChanged: c.setUseTalismans,
                    ),
                    TextButton(
                      key: const Key('manage-talismans'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TalismansPage(controller: c),
                        ),
                      ),
                      child: Text(l10n.manage),
                    ),
                  ],
                ),
              ),
              RuledRow(
                ruled: false,
                label: _TwoLines(
                  l10n.onlyMyProgress,
                  l10n.upToRarity(progress, maxRarityFor(c.assistant.progress)),
                ),
                trailing: Switch(
                  key: const Key('only-my-progress'),
                  value: c.onlyMyProgress,
                  onChanged: c.setOnlyMyProgress,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: searching
              ? _SearchingCard(
                  checked: (c.phase as OptimizerSearching).checked,
                  onCancel: c.cancel,
                )
              : FilledButton(
                  key: const Key('build-it'),
                  style: FilledButton.styleFrom(
                    backgroundColor: HunterPalette.gold,
                    foregroundColor: HunterPalette.textOnGold,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: chosen.isEmpty || c.matchingWeaponCount == 0
                      ? null
                      : c.build,
                  child: Text(
                    l10n.buildIt,
                    style: notebookTitle(
                      size: 17,
                      color: HunterPalette.textOnGold,
                    ),
                  ),
                ),
        ),
        if (chosen.isEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(gutter + 4, 8, gutter, 0),
            child: EmptySectionText(l10n.chooseSkills),
          ),
      ],
    );
  }
}

/// An element or status kind's name ("Fogo", "Veneno", "Sem elemento").
String elementName(AppLocalizations l10n, String kind) => switch (kind) {
  'fire' => l10n.elementFire,
  'water' => l10n.elementWater,
  'thunder' => l10n.elementThunder,
  'ice' => l10n.elementIce,
  'dragon' => l10n.elementDragon,
  'poison' => l10n.statusPoison,
  'sleep' => l10n.statusSleep,
  'paralysis' => l10n.statusParalysis,
  'blast' => l10n.statusBlast,
  _ => l10n.noElement,
};

/// A weapon filter: its label and one choice chip per option.
class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final List<({String? value, String text})> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: HunterPalette.borderSubtle)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.row),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(label)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final o in options)
                ChoiceChip(
                  label: Text(o.text),
                  selected: o.value == selected,
                  showCheckmark: false,
                  selectedColor: HunterPalette.panelHighlight,
                  side: BorderSide(
                    color: o.value == selected
                        ? HunterPalette.gold
                        : HunterPalette.border,
                  ),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: o.value == selected
                        ? HunterPalette.gold
                        : HunterPalette.textMuted,
                  ),
                  onSelected: (_) => onSelected(o.value),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _TwoLines extends StatelessWidget {
  const _TwoLines(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title),
      Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: HunterPalette.textMuted),
      ),
    ],
  );
}

/// One chosen skill: name and pips, − level +, and ✕.
class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.skill,
    required this.level,
    required this.language,
    required this.ruled,
    required this.onLevel,
    required this.onRemove,
  });

  final OptimizerSkill skill;
  final int level;
  final NameLanguage language;
  final bool ruled;
  final ValueChanged<int> onLevel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = skill.name.resolve(language);
    return RuledRow(
      ruled: ruled,
      label: Semantics(
        label: l10n.skillLevelOf(name, level, skill.max),
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name),
            const SizedBox(height: 4),
            SkillPips(level: level, max: skill.max),
          ],
        ),
      ),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton(
            tooltip: l10n.decreaseSkill(name),
            onPressed: level > 1 ? () => onLevel(level - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          ExcludeSemantics(
            child: Text('$level', style: notebookNumber(size: 15, bold: true)),
          ),
          IconButton(
            tooltip: l10n.increaseSkill(name),
            onPressed: level < skill.max ? () => onLevel(level + 1) : null,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: l10n.removeSkill(name),
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: HunterPalette.textDisabled),
          ),
        ],
      ),
    );
  }
}

class _SearchingCard extends StatelessWidget {
  const _SearchingCard({required this.checked, required this.onCancel});

  final int checked;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      child: Material(
        color: HunterPalette.panel,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: HunterPalette.gold),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${l10n.searching} ${l10n.searchingChecked(checked)}',
                ),
              ),
              TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ weapon

/// A searchable list of weapons of the type within the progress, with
/// "Qualquer" first (009 US4).
Future<void> showWeaponPicker(BuildContext context, OptimizerController c) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: HunterPalette.panel,
      builder: (context) => _WeaponPicker(controller: c),
    );

class _WeaponPicker extends StatefulWidget {
  const _WeaponPicker({required this.controller});

  final OptimizerController controller;

  @override
  State<_WeaponPicker> createState() => _WeaponPickerState();
}

class _WeaponPickerState extends State<_WeaponPicker> {
  String _text = '';

  void _pick(String? id) {
    widget.controller.setFixedWeapon(id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = widget.controller;
    final language = c.assistant.language;
    final weapons = c.weaponsMatching(_text);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                key: const Key('weapon-search'),
                autofocus: true,
                onChanged: (v) => setState(() => _text = v),
                decoration: InputDecoration(
                  hintText: l10n.searchWeapon,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text(l10n.anyWeapon),
                    selected: c.fixedWeaponId == null,
                    onTap: () => _pick(null),
                  ),
                  for (final w in weapons)
                    ListTile(
                      leading: w.image == null
                          ? null
                          : Image.asset(
                              w.image!,
                              width: 32,
                              height: 32,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox(width: 32),
                            ),
                      title: Text(w.name.resolve(language)),
                      subtitle: Text('${l10n.rarity(w.rarity)} · ${w.attack}'),
                      trailing: Wrap(
                        spacing: 2,
                        children: [
                          for (final s in w.slots) SlotIcon(level: s, size: 16),
                        ],
                      ),
                      selected: c.fixedWeaponId == w.id,
                      onTap: () => _pick(w.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ results

/// Screen 3: the sets found (009 ui-contract).
class OptimizerResultsList extends StatelessWidget {
  const OptimizerResultsList({
    required this.controller,
    required this.sets,
    this.typeName,
    this.highlightSelection = false,
    super.key,
  });

  final OptimizerController controller;
  final List<BuildSet> sets;
  final String Function(String typeId)? typeName;
  final bool highlightSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = controller;
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final type = _typeOf(c, typeName);
    final progress = progressText(l10n, c.assistant.progress);
    return ListView(
      key: const PageStorageKey('optimizer-results'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _ContextStrip(
          text: '${l10n.skillsCount(c.skills.length)} · $progress · $type',
          action: l10n.edit,
          onTap: c.editRequest,
        ),
        if (sets.isEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(gutter + 4, 12, gutter, 12),
            child: EmptySectionText(l10n.noBuildSets),
          )
        else ...[
          _Caption(l10n.setsFound(sets.length)),
          for (final (i, s) in sets.indexed)
            ResultCard(
              key: ValueKey(('result', i)),
              index: i,
              set: s,
              controller: c,
              selected: highlightSelection ? c.selected == i : i == 0,
              onTap: () => c.select(i),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(gutter + 4, 12, gutter, 0),
            child: Text(
              l10n.rankingNote,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: HunterPalette.textDisabled),
            ),
          ),
        ],
      ],
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter + 4, 6, gutter, 2),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: notebookTitle(size: 15, color: HunterPalette.textMuted),
        ),
      ),
    );
  }
}

/// "completa" in green or "quase" in red.
class CompleteSeal extends StatelessWidget {
  const CompleteSeal({required this.complete, super.key});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = complete ? HunterPalette.positive : HunterPalette.negative;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          complete ? l10n.setComplete : l10n.setAlmost,
          style: notebookNumber(size: 12, color: color, bold: true),
        ),
      ),
    );
  }
}

/// The talisman as "Olho Crítico 3 + Artesanato 1", or "nenhum".
String talismanText(
  UserTalisman? t,
  OptimizerCatalog catalog,
  NameLanguage language,
  AppLocalizations l10n,
) {
  if (t == null) return l10n.noTalisman;
  return [
    for (final e in t.skills.entries)
      '${catalog.skills[e.key]?.name.resolve(language) ?? e.key} ${e.value}',
  ].join(' + ');
}

class ResultCard extends StatelessWidget {
  const ResultCard({
    required this.index,
    required this.set,
    required this.controller,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final int index;
  final BuildSet set;
  final OptimizerController controller;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = controller;
    final catalog = c.catalog!;
    final language = c.assistant.language;
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final small = Theme.of(context).textTheme.bodySmall;
    final rarest = set.pieces.values.fold<int>(
      1,
      (r, p) => p.rarity > r ? p.rarity : r,
    );
    final skills = c.skills.entries.toList();
    final w = set.weapon;
    final weapon = w == null
        ? '—'
        : [
            w.name.resolve(language),
            ?w.trait?.name.resolve(language),
            for (final e in w.elements) elementName(l10n, e),
          ].join(' · ');

    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, Space.row, gutter, 0),
      child: Semantics(
        container: true,
        button: true,
        selected: selected,
        child: Material(
          color: selected ? HunterPalette.panelHighlight : HunterPalette.panel,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: selected ? HunterPalette.gold : HunterPalette.borderSubtle,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.optionN(index + 1),
                          style: notebookTitle(size: 18),
                        ),
                      ),
                      CompleteSeal(complete: set.complete),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ExcludeSemantics(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final part in BuildPart.values)
                          if (set.pieces[part] case final p?)
                            _MiniIcon(partIcon(part.name, p.rarity)),
                        if (set.talisman != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _MiniIcon(partIcon('talisman', rarest)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.weaponWithTalisman(
                      weapon,
                      talismanText(set.talisman, catalog, language, l10n),
                    ),
                    style: small?.copyWith(color: HunterPalette.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        for (final (i, e) in skills.indexed) ...[
                          if (i > 0) const TextSpan(text: ' · '),
                          TextSpan(
                            text: l10n.skillGot(
                              catalog.skills[e.key]?.name.resolve(language) ??
                                  e.key,
                              (set.skills[e.key] ?? 0).clamp(0, e.value),
                              e.value,
                            ),
                            style: TextStyle(
                              color: set.missing.containsKey(e.key)
                                  ? HunterPalette.negative
                                  : HunterPalette.text,
                            ),
                          ),
                        ],
                      ],
                    ),
                    style: small,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.maxDefense(set.defense),
                        style: small?.copyWith(color: HunterPalette.textMuted),
                      ),
                      if (set.freeSlots.isNotEmpty) ...[
                        Text(
                          '· ${l10n.freeSlots}',
                          style: small?.copyWith(
                            color: HunterPalette.textMuted,
                          ),
                        ),
                        for (final s in set.freeSlots)
                          SlotIcon(level: s, size: 16),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 30,
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: HunterPalette.panelHighlight,
      borderRadius: BorderRadius.circular(3),
    ),
    child: Image.asset(
      asset,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    ),
  );
}

// ------------------------------------------------------------- detail

/// Screen 4: one result as the 008 detail, with "Habilidades pedidas" and
/// "‹ 1 de N ›" (009 ui-contract).
class OptimizerResultDetail extends StatelessWidget {
  const OptimizerResultDetail({
    required this.controller,
    required this.index,
    required this.onSave,
    this.typeName,
    this.onOpen,
    super.key,
  });

  final OptimizerController controller;
  final int index;
  final String Function(String typeId)? typeName;
  final ValueChanged<CatalogRef>? onOpen;
  final ValueChanged<CuratedBuild> onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = controller;
    final sets = switch (c.phase) {
      OptimizerResults(:final sets) => sets,
      _ => const <BuildSet>[],
    };
    if (index >= sets.length) return const SizedBox.shrink();
    final language = c.assistant.language;
    final type = _typeOf(c, typeName);
    final skillNames = [
      for (final e in c.skills.entries)
        '${c.catalog!.skills[e.key]?.name.resolve(language) ?? e.key} ${e.value}',
    ];
    final name =
        '$type · ${skillNames.take(3).join(', ')}${skillNames.length > 3 ? '…' : ''}';
    final progress = progressText(l10n, c.assistant.progress);
    final curated = c.curatedOf(
      index,
      name: name,
      stageLabel: progress,
      sourceName: l10n.optimizerSource,
    )!;
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return BuildDetailView(
      key: ValueKey(('result', index)),
      curated: curated,
      language: language,
      typeName: typeName,
      requested: c.skills,
      title: l10n.optionN(index + 1),
      seal: CompleteSeal(complete: sets[index].complete),
      top: Padding(
        padding: EdgeInsets.symmetric(horizontal: gutter),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.resultsBack,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: HunterPalette.textMuted),
              ),
            ),
            IconButton(
              tooltip: l10n.resultOf(index, sets.length),
              onPressed: index > 0 ? () => c.select(index - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(l10n.resultOf(index + 1, sets.length)),
            IconButton(
              tooltip: l10n.resultOf(index + 2, sets.length),
              onPressed: index < sets.length - 1
                  ? () => c.select(index + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
      onOpen: onOpen,
      onSave: () => onSave(curated),
    );
  }
}
