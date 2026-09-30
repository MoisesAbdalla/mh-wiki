import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/domain/entities/breakable_part.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/section_card.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

class PartsSection extends StatelessWidget {
  const PartsSection({required this.parts, required this.language, super.key});

  final List<BreakablePart> parts;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      title: l10n.sectionParts,
      child: parts.isEmpty
          ? EmptySectionText(l10n.noParts)
          : Column(
              children: [
                for (final part in parts)
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Row(
                      children: [
                        const Icon(Icons.broken_image_outlined, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(part.name.resolve(language))),
                        if (part.severable)
                          Chip(
                            label: Text(l10n.severable),
                            avatar: const Icon(Icons.content_cut, size: 16),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
