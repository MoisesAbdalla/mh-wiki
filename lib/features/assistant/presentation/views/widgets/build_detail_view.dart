import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/features/armor/presentation/views/widgets/armor_widgets.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/assistant_labels.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The whole build (008 US2): 1 Equipamento, 2 Habilidades, 3 Joias, then
/// the save (or rename and delete) actions and the source.
class BuildDetailView extends StatelessWidget {
  const BuildDetailView({
    required this.curated,
    required this.language,
    this.typeName,
    this.savedName,
    this.onOpen,
    this.onSave,
    this.onRename,
    this.onDelete,
    super.key,
  });

  final CuratedBuild curated;
  final NameLanguage language;

  /// The weapon type's name ("Espadão"); its id when not given.
  final String Function(String typeId)? typeName;

  /// Set for a saved build: its own name heads the page.
  final String? savedName;

  /// Opens a known item in Armas or Armaduras.
  final ValueChanged<CatalogRef>? onOpen;
  final VoidCallback? onSave;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    final type = typeName?.call(curated.weaponType) ?? curated.weaponType;
    final name = savedName;
    final rows = <Widget>[
      _EquipmentRow(
        part: l10n.partWeapon,
        item: curated.weapon,
        language: language,
        onOpen: onOpen,
      ),
      for (final p in curated.pieces)
        _EquipmentRow(
          part: p.part == null ? '—' : partText(l10n, p.part!),
          item: p.item,
          alternatives: p.alternatives,
          language: language,
          onOpen: onOpen,
        ),
      if (curated.talisman case final t?)
        _EquipmentRow(
          part: l10n.partTalisman,
          item: BuildItem(ref: t.skill, decorations: t.decorations),
          label:
              '${t.skill.name.resolve(language)} '
              '${l10n.skillLevelShort(t.level)}',
          language: language,
          onOpen: onOpen,
        ),
    ];
    final decorations = [...curated.decorations]
      ..sort((a, b) => _slot(b.decoration).compareTo(_slot(a.decoration)));

    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 32),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(gutter + 4, 4, gutter, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  name ?? curated.name,
                  style: notebookTitle(size: 26, height: 1.05),
                ),
              ),
              if (name != null && name != curated.name)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(l10n.savedFrom(curated.name), style: muted),
                ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StageSeal(curated.stageLabel),
                  Text('$type · ${curated.sourceName}', style: muted),
                ],
              ),
            ],
          ),
        ),
        NotebookSection(
          number: 1,
          title: l10n.buildSectionEquipment,
          child: Column(children: rows),
        ),
        if (curated.skills.isNotEmpty)
          NotebookSection(
            number: 2,
            title: l10n.buildSectionSkills,
            child: Column(
              children: [
                for (final (i, s) in curated.skills.indexed)
                  _Tappable(
                    ref: s.skill,
                    onOpen: onOpen,
                    semanticsLabel: l10n.skillLevelOf(
                      s.skill.name.resolve(language),
                      s.level,
                      s.maxLevel,
                    ),
                    child: RuledRow(
                      ruled: i < curated.skills.length - 1,
                      label: Text(s.skill.name.resolve(language)),
                      trailing: SkillPips(level: s.level, max: s.maxLevel),
                    ),
                  ),
              ],
            ),
          ),
        if (decorations.isNotEmpty)
          NotebookSection(
            number: 3,
            title: l10n.buildSectionDecorations,
            child: Column(
              children: [
                for (final (i, d) in decorations.indexed)
                  _Tappable(
                    ref: d.decoration,
                    onOpen: onOpen,
                    child: RuledRow(
                      ruled: i < decorations.length - 1,
                      label: Text(d.decoration.name.resolve(language)),
                      trailing: Text(
                        '×${d.count}',
                        style: notebookNumber(size: 15, bold: true),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (onSave case final save?)
                _GoldButton(label: l10n.saveBuild, onPressed: save),
              if (onRename != null || onDelete != null)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (onRename case final rename?)
                      _GoldButton(label: l10n.renameBuild, onPressed: rename),
                    if (onDelete case final delete?)
                      _GoldButton(
                        label: l10n.deleteBuild,
                        onPressed: delete,
                        color: HunterPalette.negative,
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              Text(l10n.buildSourceNote(curated.sourceName), style: muted),
              SelectableText(curated.sourceUrl, style: muted),
            ],
          ),
        ),
      ],
    );
  }

  /// The slot level of a decoration, from the digit its name ends with.
  static int _slot(CatalogRef d) =>
      int.tryParse(RegExp(r'(\d)$').firstMatch(d.name.en)?.group(1) ?? '') ?? 0;
}

/// One equipment row: part caption, the name (with "ou …"), decorations.
class _EquipmentRow extends StatelessWidget {
  const _EquipmentRow({
    required this.part,
    required this.item,
    required this.language,
    required this.onOpen,
    this.alternatives = const [],
    this.label,
  });

  final String part;
  final BuildItem item;
  final List<CatalogRef> alternatives;
  final NameLanguage language;
  final ValueChanged<CatalogRef>? onOpen;

  /// Replaces the item's name (the talisman's "Olho Crítico Nv 3").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final small = Theme.of(context).textTheme.bodySmall;
    final ref = item.ref;
    return _Tappable(
      ref: ref,
      onOpen: onOpen,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: HunterPalette.borderSubtle)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                part.toUpperCase(),
                style: small?.copyWith(
                  color: HunterPalette.textDisabled,
                  letterSpacing: .5,
                  fontSize: 11,
                ),
              ),
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Text(
                    label ?? ref.name.resolve(language),
                    style: notebookTitle(size: 16),
                  ),
                  for (final a in alternatives)
                    Text(
                      l10n.alternativePiece(a.name.resolve(language)),
                      style: small?.copyWith(color: HunterPalette.textMuted),
                    ),
                ],
              ),
              if (!ref.known)
                Text(
                  l10n.notInCatalog,
                  style: small?.copyWith(
                    color: HunterPalette.textDisabled,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              if (item.decorations.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final d in item.decorations)
                        _DecorationSeal(d.name.resolve(language)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorationSeal extends StatelessWidget {
  const _DecorationSeal(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: HunterPalette.border),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: HunterPalette.textMuted, fontSize: 12),
      ),
    ),
  );
}

/// Makes [child] open [ref] when the app knows it.
class _Tappable extends StatelessWidget {
  const _Tappable({
    required this.ref,
    required this.onOpen,
    required this.child,
    this.semanticsLabel,
  });

  final CatalogRef ref;
  final ValueChanged<CatalogRef>? onOpen;
  final String? semanticsLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final open = onOpen;
    final label = semanticsLabel;
    final content = label == null
        ? child
        : Semantics(
            label: label,
            excludeSemantics: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: child,
            ),
          );
    if (open == null || !ref.known) return content;
    return Semantics(
      container: true,
      button: true,
      child: InkWell(
        onTap: () => open(ref),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: content,
        ),
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  const _GoldButton({
    required this.label,
    required this.onPressed,
    this.color = HunterPalette.gold,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    onPressed: onPressed,
    child: Text(label, style: notebookTitle(size: 16, color: color)),
  );
}
