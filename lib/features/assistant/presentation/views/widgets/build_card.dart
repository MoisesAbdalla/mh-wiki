import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/assistant_labels.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// A build in a list (008 ui-contract): name, stage seal, weapon, the top
/// skills and, for a next build, when it becomes available.
class BuildCard extends StatelessWidget {
  const BuildCard({
    required this.curated,
    required this.language,
    required this.onTap,
    this.title,
    this.subtitle,
    this.availableFrom,
    this.selected = false,
    super.key,
  });

  final CuratedBuild curated;
  final NameLanguage language;
  final VoidCallback onTap;

  /// Replaces the build's name (a saved build's own name).
  final String? title;

  /// Replaces the weapon line ("baseada em: …").
  final String? subtitle;

  /// Set on a next build: dims the card and says from when it fits.
  final String? availableFrom;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final next = availableFrom;
    final skills = curated.skills.take(4).toList();
    final skillStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted);
    final card = Material(
      color: selected ? HunterPalette.panelHighlight : HunterPalette.panel,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? HunterPalette.gold : HunterPalette.borderSubtle,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title ?? curated.name, style: notebookTitle(size: 17)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StageSeal(curated.stageLabel, active: next == null),
                  Text(
                    subtitle ?? curated.weapon.ref.name.resolve(language),
                    style: skillStyle,
                  ),
                ],
              ),
              if (skills.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      for (final (i, s) in skills.indexed) ...[
                        if (i > 0) const TextSpan(text: ' · '),
                        TextSpan(
                          text: '${s.skill.name.resolve(language)} ${s.level}',
                          style: i < 2
                              ? const TextStyle(color: HunterPalette.text)
                              : null,
                        ),
                      ],
                    ],
                  ),
                  style: skillStyle,
                ),
              ],
              if (next != null) ...[
                const SizedBox(height: 6),
                Text(
                  next,
                  style: skillStyle?.copyWith(
                    color: HunterPalette.textDisabled,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, Space.row, gutter, 0),
      child: Semantics(
        container: true,
        button: true,
        selected: selected,
        hint: next == null ? null : l10n.stageSemantics(next),
        child: next == null ? card : Opacity(opacity: 0.6, child: card),
      ),
    );
  }
}

/// A caption with a rule after it: "Para agora ————".
class ListCaption extends StatelessWidget {
  const ListCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter + 4, 16, gutter, 2),
      child: Row(
        children: [
          Flexible(
            child: Semantics(
              header: true,
              child: Text(
                text,
                style: notebookTitle(size: 15, color: HunterPalette.textMuted),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: HunterPalette.border)),
        ],
      ),
    );
  }
}
