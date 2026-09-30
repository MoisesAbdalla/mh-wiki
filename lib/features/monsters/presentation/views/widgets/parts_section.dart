import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/features/monsters/domain/entities/breakable_part.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/section_card.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

class PartsSection extends StatelessWidget {
  const PartsSection({
    required this.parts,
    required this.language,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.inherited = false,
    super.key,
  });

  final List<BreakablePart> parts;
  final NameLanguage language;
  final EdgeInsetsGeometry margin;
  final bool inherited;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      title: l10n.sectionParts,
      margin: margin,
      inherited: inherited,
      child: parts.isEmpty
          ? EmptySectionText(l10n.noParts)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final part in parts)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    // Wrap lets the tag drop below long names or large text.
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          part.name.resolve(language),
                          style: const TextStyle(fontSize: 15),
                        ),
                        if (part.severable) _SeverableTag(l10n.severable),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Small gold "Cortável" tag (002 FR-008).
class _SeverableTag extends StatelessWidget {
  const _SeverableTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    color: HunterPalette.gold,
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: HunterPalette.textOnGold,
      ),
    ),
  );
}
