import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/features/weapons/domain/entities/artian.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/sharpness_bar.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_attributes_section.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_detail_view.dart';
import 'package:mh_wiki/features/weapons/presentation/weapon_labels.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The Gogmazios icon, shown where the Gogma Artian come from.
const gogmaziosImage = 'assets/images/monsters/wilds/gogmazios.webp';

/// "Ataque", "Afinidade" or "Elemento".
String focusName(AppLocalizations l10n, ArtianFocus focus) => switch (focus) {
  ArtianFocus.attack => l10n.focusAttack,
  ArtianFocus.affinity => l10n.focusAffinity,
  ArtianFocus.element => l10n.focusElement,
};

/// A Gogma Artian (010, mockup gogma.html): its attributes, the three foci
/// side by side, and how to get it from Gogmazios. Read only.
class GogmaArtianView extends StatelessWidget {
  const GogmaArtianView({
    required this.weapon,
    required this.foci,
    required this.base,
    required this.onFocus,
    this.onOpenGogmazios,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final Weapon weapon;

  /// The three Gogma Artian of the type, one per focus.
  final List<Weapon> foci;

  /// The rarity 8 Artian it is upgraded from.
  final ArtianBase? base;
  final ValueChanged<ArtianFocus> onFocus;

  /// Opens Gogmazios in Monstros; `null` hides the link.
  final VoidCallback? onOpenGogmazios;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    final sharpness = weapon.sharpness;
    String? trait(Weapon w) => switch (w.traits) {
      final t when t.phial != null => t.phial!.resolve(language),
      final t when t.shelling != null => t.shelling!.resolve(language),
      _ => null,
    };
    final withTrait = foci.any((w) => trait(w) != null);
    final numberStyle = notebookNumber(size: 15, bold: true);

    return ListView(
      key: PageStorageKey(('gogma', weapon.id)),
      padding: const EdgeInsets.only(bottom: Space.section),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(gutter, 18, gutter, Space.card),
          child: WeaponHeader(weapon: weapon, language: language),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(gutter, 0, gutter, Space.card),
          child: Text(
            [
              l10n.gogmaSubtitle(weapon.type.name.resolve(language)),
              l10n.gogmaFocus(focusName(l10n, weapon.gogma!)),
            ].join(' · '),
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: HunterPalette.gold),
          ),
        ),
        WeaponAttributesSection(weapon: weapon, language: language),
        if (sharpness != null)
          NotebookSection(
            number: 2,
            title: l10n.weaponSectionSharpness,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SharpnessBar(label: l10n.sharpnessBase, units: sharpness.base),
                const SizedBox(height: 10),
                SharpnessBar(
                  label: l10n.sharpnessHandicraft,
                  units: sharpness.handicraft,
                ),
              ],
            ),
          ),
        NotebookSection(
          number: sharpness != null ? 3 : 2,
          title: l10n.gogmaFoci,
          child: Column(
            key: const Key('gogma-foci'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FocusRow(
                cells: [
                  Text(l10n.gogmaFocusColumn, style: muted),
                  Text(l10n.attack, style: muted),
                  Text(l10n.affinity, style: muted),
                  if (withTrait) const SizedBox.shrink(),
                ],
              ),
              for (final w in foci)
                Semantics(
                  button: true,
                  selected: w.gogma == weapon.gogma,
                  label: [
                    l10n.gogmaFocus(focusName(l10n, w.gogma!)),
                    '${l10n.attack} ${w.attack}',
                    '${l10n.affinity} ${l10n.signedPercent(w.affinity)}',
                    ?trait(w),
                  ].join(', '),
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => onFocus(w.gogma!),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: _FocusRow(
                        selected: w.gogma == weapon.gogma,
                        cells: [
                          Text(
                            focusName(l10n, w.gogma!),
                            style: TextStyle(
                              color: w.gogma == weapon.gogma
                                  ? HunterPalette.gold
                                  : null,
                            ),
                          ),
                          Text('${w.attack}', style: numberStyle),
                          Text(
                            l10n.signedPercent(w.affinity),
                            style: numberStyle.copyWith(
                              color: w.affinity < 0
                                  ? HunterPalette.negative
                                  : null,
                            ),
                          ),
                          if (withTrait) Text(trait(w) ?? ''),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              Text(l10n.gogmaFocusHint, style: muted),
            ],
          ),
        ),
        NotebookSection(
          number: sharpness != null ? 4 : 3,
          title: l10n.gogmaHowTo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.gogmaUpgrade(
                  base?.name.resolve(language) ?? l10n.artianGroup,
                ),
              ),
              Text(l10n.gogmaDevice),
              const SizedBox(height: 6),
              Text(l10n.gogmaSource, style: muted),
              if (onOpenGogmazios case final open?) ...[
                const SizedBox(height: 10),
                Semantics(
                  button: true,
                  label: 'Gogmazios, ${l10n.openInMonsters}',
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: open,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: HunterPalette.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            const MonsterImage(asset: gogmaziosImage, size: 40),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gogmazios',
                                    style: notebookTitle(size: 16),
                                  ),
                                  Text(l10n.openInMonsters, style: muted),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: HunterPalette.gold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(l10n.gogmaExtras, style: muted),
            ],
          ),
        ),
      ],
    );
  }
}

class _FocusRow extends StatelessWidget {
  const _FocusRow({required this.cells, this.selected = false});

  final List<Widget> cells;
  final bool selected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: selected ? HunterPalette.panelHighlight : null,
      border: const Border(
        bottom: BorderSide(color: HunterPalette.borderSubtle),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          for (final (i, c) in cells.indexed)
            Expanded(flex: i == 0 ? 4 : 3, child: c),
        ],
      ),
    ),
  );
}
