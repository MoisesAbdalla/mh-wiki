import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/element_icon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_special.dart';
import 'package:mh_wiki/features/weapons/presentation/weapon_labels.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Colour of a status; elements use [ElementIcon]'s own colours.
Color statusColor(SpecialKind kind) => switch (kind) {
  SpecialKind.poison => HunterPalette.poison,
  SpecialKind.sleep => HunterPalette.sleep,
  SpecialKind.paralysis => HunterPalette.paralysis,
  SpecialKind.blast => HunterPalette.blast,
  _ => HunterPalette.text,
};

/// Element symbol (or status name) and value, e.g. the fire symbol and 28,
/// or "Veneno 18".
class WeaponSpecialLabel extends StatelessWidget {
  const WeaponSpecialLabel({
    required this.special,
    this.size = 13,
    this.showName = false,
    super.key,
  });

  final WeaponSpecial special;
  final double size;

  /// Also writes the element's name next to its symbol (detail).
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final element = special.kind.element;
    final name = l10n.specialName(special.kind);
    return Semantics(
      label: special.hidden
          ? l10n.hiddenSpecialSemantics(name, special.value)
          : '$name ${special.value}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (element != null) ...[
            ElementIcon(element: element, size: size + 2),
            const SizedBox(width: 3),
            if (showName) ...[
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: size),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ] else ...[
            // A long status name gives way in a narrow row.
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: size,
                  color: statusColor(special.kind),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          // Scales down rather than overflow a narrow row at large text.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                special.hidden ? '(${special.value})' : '${special.value}',
                style: notebookNumber(
                  size: size + 1,
                  color: special.hidden
                      ? HunterPalette.textMuted
                      : HunterPalette.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
