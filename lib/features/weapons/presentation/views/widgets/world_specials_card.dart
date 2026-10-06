import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_row.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// "Kulve Taroth · sorteada", "Kjárr · sorteada", "Safi'jiiva · despertar".
String worldSpecialLabel(AppLocalizations l10n, WorldSpecial special) =>
    switch (special) {
      WorldSpecial.kulve => l10n.specialKulve,
      WorldSpecial.kjarr => l10n.specialKjarr,
      WorldSpecial.safi => l10n.specialSafi,
    };

/// How a World special is obtained (011 FR-004).
String worldSpecialHowTo(AppLocalizations l10n, WorldSpecial special) =>
    switch (special) {
      WorldSpecial.kulve => l10n.specialHowToKulve,
      WorldSpecial.kjarr => l10n.specialHowToKjarr,
      WorldSpecial.safi => l10n.specialHowToSafi,
    };

/// The "Especiais" card after a World type's trees: Kulve Taroth, Kjárr and
/// Safi'jiiva weapons, read only (011 ui-contract).
class WorldSpecialsCard extends StatelessWidget {
  const WorldSpecialsCard({
    required this.weapons,
    required this.onSelect,
    this.selectedId,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final List<Weapon> weapons;
  final ValueChanged<Weapon> onSelect;
  final WeaponId? selectedId;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter - 10, 5, gutter - 10, 5),
      child: Material(
        key: const Key('world-specials'),
        color: HunterPalette.panel,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: HunterPalette.borderSubtle),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: HunterPalette.borderSubtle),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 10,
                    children: [
                      Text(l10n.worldSpecials, style: notebookTitle(size: 18)),
                      Text(
                        l10n.worldSpecialsNote,
                        style: notebookNumber(
                          size: 13,
                          color: HunterPalette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            for (final (i, w) in weapons.indexed)
              WeaponRow(
                key: ValueKey(w.id),
                weapon: w,
                depth: 0,
                subtitle: worldSpecialLabel(l10n, w.worldSpecial!),
                selected: w.id == selectedId,
                ruled: i < weapons.length - 1,
                language: language,
                onTap: () => onSelect(w),
              ),
          ],
        ),
      ),
    );
  }
}
