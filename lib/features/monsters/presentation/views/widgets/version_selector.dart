import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/widgets/underline_tabs.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Tabs "Base · Temperado · Guardião…" under the detail header; the chosen
/// version drives every section (004 contract, FR-006a).
class VersionSelector extends StatelessWidget {
  const VersionSelector({
    required this.versions,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// The base monster first, then its versions in kind order.
  final List<Monster> versions;
  final MonsterId selected;
  final ValueChanged<MonsterId> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return UnderlineTabs<MonsterId>(
      options: [
        for (final m in versions)
          TabOption(
            value: m.id,
            text: l10n.versionLabel(m.versionKind),
            semanticsLabel: l10n.versionTabLabel(
              l10n.versionLabel(m.versionKind),
            ),
          ),
      ],
      selected: selected,
      onChanged: onSelect,
      textSize: 16,
    );
  }
}
