import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/domain/entities/breakable_part.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

class PartsSection extends StatelessWidget {
  const PartsSection({
    required this.parts,
    required this.language,
    this.number,
    this.inherited = false,
    super.key,
  });

  final List<BreakablePart> parts;
  final NameLanguage language;

  /// Position in the detail (005 FR-004).
  final int? number;
  final bool inherited;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NotebookSection(
      number: number,
      title: l10n.sectionParts,
      note: inherited ? l10n.inheritedFromBase : null,
      child: parts.isEmpty
          ? EmptySectionText(l10n.noParts)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final part in parts)
                  RuledRow(
                    label: Text(part.name.resolve(language)),
                    trailing: part.severable
                        ? Text(
                            l10n.severable,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                  ),
              ],
            ),
    );
  }
}
