import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_type.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The weapon types as blocks that scroll sideways (006 ui-contract): icon
/// and pt-BR name, the selected one with a gold edge.
class WeaponTypePicker extends StatelessWidget {
  const WeaponTypePicker({
    required this.types,
    required this.selectedId,
    required this.onChanged,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final NameLanguage language;
  final List<WeaponType> types;

  /// `null` when no type is selected (the "only these weapons" filter).
  final String? selectedId;
  final ValueChanged<String> onChanged;

  static String iconAsset(String typeId) =>
      'assets/images/weapons/types/$typeId.webp';

  @override
  Widget build(BuildContext context) {
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return SingleChildScrollView(
      key: const PageStorageKey('weapon-types'),
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(gutter, 10, gutter, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, type) in types.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            _TypeBlock(
              type: type,
              selected: type.id == selectedId,
              language: language,
              onTap: () => onChanged(type.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypeBlock extends StatelessWidget {
  const _TypeBlock({
    required this.type,
    required this.selected,
    required this.language,
    required this.onTap,
  });

  final NameLanguage language;
  final WeaponType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = type.name.resolve(language);
    return Semantics(
      button: true,
      selected: selected,
      label: l10n.weaponTypeLabel(name),
      excludeSemantics: true,
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
          onTap: selected ? null : onTap,
          child: SizedBox(
            width: 68,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 6, 3, 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 26,
                      child: Opacity(
                        opacity: selected ? 1 : 0.7,
                        child: Image.asset(
                          WeaponTypePicker.iconAsset(type.id),
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                          errorBuilder: (_, _, _) => Center(
                            child: Text(
                              _initials(type.name),
                              style: notebookTitle(
                                size: 17,
                                color: selected
                                    ? HunterPalette.gold
                                    : HunterPalette.textDisabled,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.15,
                        color: selected
                            ? HunterPalette.text
                            : HunterPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _initials(LocalizedText name) => (name.ptBr ?? name.en)
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 2)
      .map((w) => w[0].toUpperCase())
      .take(2)
      .join();
}
