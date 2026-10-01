import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/core/presentation/widgets/slot_icon.dart';
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
    // The talisman takes the colour of the build's rarest piece.
    int? rarest;
    for (final p in curated.pieces) {
      final r = p.item.ref.rarity;
      if (r != null && (rarest == null || r > rarest)) rarest = r;
    }
    final weaponImage =
        curated.weapon.ref.image ??
        'assets/images/weapons/types/${curated.weaponType}.webp';
    final entries = <Widget Function(bool last)>[
      (last) => _EquipmentRow(
        part: l10n.partWeapon,
        icon: weaponImage,
        item: curated.weapon,
        language: language,
        onOpen: onOpen,
        last: last,
      ),
      for (final p in curated.pieces)
        (last) => _EquipmentRow(
          part: p.part == null ? '—' : partText(l10n, p.part!),
          icon: p.part == null
              ? null
              : partIcon(p.part!.name, p.item.ref.rarity),
          item: p.item,
          alternatives: p.alternatives,
          language: language,
          onOpen: onOpen,
          last: last,
        ),
      if (curated.talisman case final t?)
        (last) => _EquipmentRow(
          part: l10n.partTalisman,
          icon: partIcon('talisman', rarest),
          item: BuildItem(ref: t.skill, decorations: t.decorations),
          label:
              '${t.skill.name.resolve(language)} '
              '${l10n.skillLevelShort(t.level)}',
          language: language,
          onOpen: onOpen,
          last: last,
        ),
    ];
    final rows = [
      for (final (i, row) in entries.indexed) row(i == entries.length - 1),
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

/// The game's icon of an equipment part in its rarity colour (feature 008,
/// approved mockup B). [part] is a [BuildPart] name or `talisman`.
String partIcon(String part, int? rarity) =>
    'assets/images/armor/parts/$part-${(rarity ?? 1).clamp(1, 10)}.webp';

/// One equipment row: the icon, part caption and name (with "ou …"), then
/// the decorations as tiles with their slot icon.
class _EquipmentRow extends StatelessWidget {
  const _EquipmentRow({
    required this.part,
    required this.icon,
    required this.item,
    required this.language,
    required this.onOpen,
    required this.last,
    this.alternatives = const [],
    this.label,
  });

  final String part;

  /// Asset of the icon; `null` for a piece outside the catalog.
  final String? icon;
  final BuildItem item;
  final List<CatalogRef> alternatives;
  final NameLanguage language;
  final ValueChanged<CatalogRef>? onOpen;
  final bool last;

  /// Replaces the item's name (the talisman's "Olho Crítico Nv 3").
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final small = Theme.of(context).textTheme.bodySmall;
    final ref = item.ref;
    final asset = icon;
    final header = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: HunterPalette.panelHighlight,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(3),
          child: asset == null
              ? null
              : Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                part,
                style: small?.copyWith(
                  color: HunterPalette.textMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                label ?? ref.name.resolve(language),
                style: notebookTitle(size: 17),
              ),
              for (final a in alternatives)
                Text(
                  l10n.alternativePiece(a.name.resolve(language)),
                  style: small?.copyWith(color: HunterPalette.textMuted),
                ),
              if (!ref.known)
                Text(
                  l10n.notInCatalog,
                  style: small?.copyWith(
                    color: HunterPalette.textDisabled,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(
                bottom: BorderSide(color: HunterPalette.borderSubtle),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Tappable(ref: ref, onOpen: onOpen, child: header),
            if (item.decorations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _DecorationTiles(
                  decorations: item.decorations,
                  language: language,
                  onOpen: onOpen,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Decorations as tiles with their slot icon: three per line, two on narrow
/// cards or large text.
class _DecorationTiles extends StatelessWidget {
  const _DecorationTiles({
    required this.decorations,
    required this.language,
    required this.onOpen,
  });

  final List<CatalogRef> decorations;
  final NameLanguage language;
  final ValueChanged<CatalogRef>? onOpen;

  static const _gap = 6.0;
  static const _minTile = 124.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      // Three per line when a tile still fits a whole word such as
      // "Atenuadora"; two otherwise, so names never break mid-word.
      final three = (constraints.maxWidth - _gap * 2) / 3 / scale;
      final columns = three >= _minTile ? 3 : 2;
      final width = (constraints.maxWidth - _gap * (columns - 1)) / columns;
      return Wrap(
        spacing: _gap,
        runSpacing: _gap,
        children: [
          for (final d in decorations)
            SizedBox(
              width: width,
              child: _DecorationTile(
                decoration: d,
                language: language,
                onOpen: onOpen,
              ),
            ),
        ],
      );
    },
  );
}

class _DecorationTile extends StatelessWidget {
  const _DecorationTile({
    required this.decoration,
    required this.language,
    required this.onOpen,
  });

  final CatalogRef decoration;
  final NameLanguage language;
  final ValueChanged<CatalogRef>? onOpen;

  @override
  Widget build(BuildContext context) {
    final open = onOpen;
    final level = BuildDetailView._slot(decoration);
    final name = decoration.name.resolve(language);
    return Semantics(
      container: true,
      button: open != null && decoration.known,
      label: name,
      excludeSemantics: true,
      child: Material(
        color: HunterPalette.panelHighlight,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: HunterPalette.border),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: open == null || !decoration.known
              ? null
              : () => open(decoration),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  if (level > 0) ...[
                    SlotIcon(level: level.clamp(1, 4), size: 18),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HunterPalette.text,
                        fontSize: 12.5,
                        height: 1.15,
                      ),
                    ),
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
