import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/game_icons.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/element_icon.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/features/weapons/domain/entities/artian.dart';
import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/artian_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/sharpness_bar.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/slot_badges.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_special_label.dart';
import 'package:mh_wiki/features/weapons/presentation/weapon_labels.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The Artian simulator (010 ui-contract, mockup B): 1 Monte a sua, with the
/// element, the 3 parts and the reinforcement rolls; 2 Resultado, live; and
/// save, rename and delete for the user's own.
class ArtianSimulatorView extends StatefulWidget {
  const ArtianSimulatorView({
    required this.type,
    required this.rarity,
    required this.catalog,
    required this.artians,
    this.mine,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final ArtianType type;
  final int rarity;
  final WeaponCatalog catalog;
  final ArtianController artians;

  /// The saved Artian being edited, or `null` for a fresh build of the base.
  final MyArtian? mine;
  final NameLanguage language;

  @override
  State<ArtianSimulatorView> createState() => _ArtianSimulatorViewState();
}

class _ArtianSimulatorViewState extends State<ArtianSimulatorView> {
  late ArtianBuild _build =
      widget.mine?.build ??
      ArtianBuild(type: widget.type.type, rarity: widget.rarity);

  ArtianType get _type => widget.type;

  void _set(ArtianBuild next) {
    if (validArtian(_type, next)) setState(() => _build = next);
  }

  void _boost(ArtianBoost kind, int delta) => _set(
    _build.copyWith(
      boosts: {..._build.boosts, kind: (_build.boosts[kind] ?? 0) + delta},
    ),
  );

  Future<String?> _askName(String initial) => showDialog<String>(
    context: context,
    builder: (context) => _NameDialog(initial: initial),
  );

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final base = _type.base(_build.rarity)!;
    final name = (await _askName(base.name.resolve(widget.language)))?.trim();
    if (name == null || name.isEmpty || !mounted) return;
    final saved = await widget.artians.save(name, _build);
    if (saved != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.artianSaved)));
    }
  }

  Future<void> _rename(MyArtian mine) async {
    final name = (await _askName(mine.name))?.trim();
    if (name == null || name.isEmpty) return;
    await widget.artians.rename(mine.id, name);
  }

  Future<void> _delete(MyArtian mine) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteArtianConfirm(mine.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteBuild),
          ),
        ],
      ),
    );
    if (ok ?? false) await widget.artians.delete(mine.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final base = _type.base(_build.rarity)!;
    final result = simulateArtian(_type, _build);
    final elements = _type.elementsByRarity[_build.rarity] ?? const {};
    final typeName =
        widget.catalog.types
            .where((t) => t.id == _type.type)
            .firstOrNull
            ?.name
            .resolve(widget.language) ??
        _type.type;
    final mine = widget.mine;
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    final rollsLeft = _type.rolls - _build.rollsUsed;

    String boostLabel(ArtianBoostRule rule) => switch (rule.kind) {
      ArtianBoost.attack => l10n.artianBoostAttack(rule.value),
      ArtianBoost.affinity => l10n.artianBoostAffinity(rule.value),
      ArtianBoost.element => l10n.artianBoostElement(rule.value),
      ArtianBoost.sharpness => l10n.artianBoostSharpness(rule.value),
      ArtianBoost.ammo => l10n.artianBoostAmmo(rule.value),
    };

    return ListView(
      key: PageStorageKey(('artian', _type.type, _build.rarity, mine?.id)),
      padding: const EdgeInsets.only(bottom: Space.section),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(gutter, 18, gutter, Space.card),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        mine?.name ?? base.name.resolve(widget.language),
                        style: notebookTitle(size: 32, height: 1.05),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        '$typeName ${l10n.artianGroup}',
                        l10n.rarity(base.rarity),
                        if (mine != null) base.name.resolve(widget.language),
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: HunterPalette.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MonsterImage(
                asset:
                    base.imageAsset ??
                    GameIcons.weaponType(
                      _type.type,
                      Game.wilds,
                      rarity: base.rarity,
                    ),
                size: 84,
                emphasized: true,
              ),
            ],
          ),
        ),
        NotebookSection(
          number: 1,
          title: l10n.artianBuild,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (elements.isNotEmpty) ...[
                Text(l10n.artianElement, style: muted),
                const SizedBox(height: 6),
                Wrap(
                  key: const Key('artian-elements'),
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.artianNoElement),
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                      selected: _build.element == null,
                      onSelected: (_) => _set(
                        _build.copyWith(clearElement: true, elementParts: 0),
                      ),
                    ),
                    for (final e in elements.keys)
                      ChoiceChip(
                        label: Text(
                          l10n.specialName(SpecialKind.values.byName(e)),
                        ),
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                        selected: _build.element == e,
                        onSelected: (_) => _set(
                          _build.copyWith(
                            element: e,
                            elementParts: _build.element == null
                                ? ArtianBuild.parts
                                : _build.elementParts,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              _Heading(
                text: l10n.artianParts(ArtianBuild.parts),
                note: l10n.artianElementHint,
              ),
              if (_build.element case final element?)
                _Stepper(
                  key: const Key('artian-part-element'),
                  label: l10n.specialName(SpecialKind.values.byName(element)),
                  value: _build.elementParts,
                  onChanged: (v) => _set(_build.copyWith(elementParts: v)),
                  max: ArtianBuild.parts,
                ),
              _Stepper(
                key: const Key('artian-part-attack'),
                label: l10n.artianPartAttack,
                value: _build.attackParts,
                max: ArtianBuild.parts,
                onChanged: (v) => _set(_build.copyWith(attackParts: v)),
              ),
              _Stepper(
                key: const Key('artian-part-affinity'),
                label: l10n.artianPartAffinity,
                value: _build.affinityParts,
                max: ArtianBuild.parts,
                onChanged: (v) =>
                    _set(_build.copyWith(attackParts: ArtianBuild.parts - v)),
              ),
              const SizedBox(height: 14),
              _Heading(
                text: l10n.artianReinforcement(_type.rolls),
                note: l10n.artianRemaining(rollsLeft),
              ),
              for (final rule in _type.boosts)
                _Stepper(
                  key: Key('artian-boost-${rule.kind.name}'),
                  label: boostLabel(rule),
                  value: _build.boosts[rule.kind] ?? 0,
                  max:
                      (_build.boosts[rule.kind] ?? 0) +
                      (rollsLeft < rule.max - (_build.boosts[rule.kind] ?? 0)
                          ? rollsLeft
                          : rule.max - (_build.boosts[rule.kind] ?? 0)),
                  onChanged: (v) =>
                      _boost(rule.kind, v - (_build.boosts[rule.kind] ?? 0)),
                ),
            ],
          ),
        ),
        NotebookSection(
          number: 2,
          title: l10n.artianResult,
          child: _Result(result: result),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(gutter, Space.card, gutter, 0),
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              if (mine == null)
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: Text(l10n.saveMyArtian),
                )
              else ...[
                FilledButton.icon(
                  onPressed: () => widget.artians.update(mine.id, _build),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.save),
                ),
                OutlinedButton(
                  onPressed: () => _rename(mine),
                  child: Text(l10n.renameBuild),
                ),
                OutlinedButton(
                  onPressed: () => _delete(mine),
                  child: Text(l10n.deleteBuild),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.text, required this.note});

  final String text;
  final String note;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(text, style: notebookTitle(size: 16)),
          Text(note, style: muted),
        ],
      ),
    );
  }
}

/// A label with − value + ; both buttons read "Diminuir/Aumentar <label>".
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    super.key,
  });

  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HunterPalette.borderSubtle)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(label),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: l10n.decreaseLabel(label),
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove),
              ),
              Semantics(
                label: '$label $value',
                excludeSemantics: true,
                child: SizedBox(
                  width: 28,
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: notebookNumber(size: 18, bold: true),
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.increaseLabel(label),
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.result});

  final ArtianResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    final kind = switch (result.element) {
      final e? => SpecialKind.values.byName(e),
      null => null,
    };
    Widget cell(String label, Widget value) => MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: muted),
          value,
        ],
      ),
    );
    final sharpness = result.sharpness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          key: const Key('artian-result'),
          spacing: 24,
          runSpacing: 8,
          children: [
            cell(
              l10n.attack,
              Text(
                '${result.attack}',
                style: notebookNumber(size: 26, bold: true),
              ),
            ),
            cell(
              l10n.affinity,
              Text(
                l10n.signedPercent(result.affinity),
                style: notebookNumber(size: 26),
              ),
            ),
            if (kind != null)
              cell(
                l10n.specialName(kind),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (kind.element case final element?) ...[
                      ElementIcon(element: element, size: 20),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      '${result.elementValue}',
                      style: notebookNumber(
                        size: 26,
                        color: kind.element == null
                            ? statusColor(kind)
                            : HunterPalette.text,
                      ),
                    ),
                    if (result.infusion) ...[
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(l10n.artianInfusion, style: muted),
                      ),
                    ],
                  ],
                ),
              ),
            if (result.ammo > 0)
              cell(
                l10n.artianBoostAmmo(result.ammo),
                Text('+${result.ammo}', style: notebookNumber(size: 26)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SlotBadges(slots: result.slots, rampageSlot: 0, game: Game.wilds),
        if (sharpness != null) ...[
          const SizedBox(height: 12),
          SharpnessBar(label: l10n.sharpnessBase, units: sharpness.base),
          const SizedBox(height: 10),
          SharpnessBar(
            label: l10n.sharpnessHandicraft,
            units: sharpness.handicraft,
          ),
        ],
      ],
    );
  }
}

/// Asks for an Artian's name; owns its text controller, so it lives as long
/// as the dialog's exit animation.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
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
      title: Text(l10n.artianName),
      content: TextField(
        controller: _text,
        autofocus: true,
        maxLength: 40,
        decoration: InputDecoration(hintText: l10n.artianName),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _text.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
