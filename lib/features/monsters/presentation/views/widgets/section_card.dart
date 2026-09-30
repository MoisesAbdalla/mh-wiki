import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/widgets/hunter_panel.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Titled block used by every detail section, drawn as a hunter's-notes panel.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.title,
    required this.child,
    this.trailing,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    this.inherited = false,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry margin;

  /// The section's data comes from the base monster (004 FR-006c).
  final bool inherited;

  @override
  Widget build(BuildContext context) => HunterPanel(
    title: title,
    trailing: trailing,
    margin: margin,
    child: inherited
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [const InheritedNote(), const SizedBox(height: 8), child],
          )
        : child,
  );
}

/// "Igual à forma base", under the title of an inherited section.
class InheritedNote extends StatelessWidget {
  const InheritedNote({super.key});

  @override
  Widget build(BuildContext context) => Text(
    AppLocalizations.of(context).inheritedFromBase,
    style: Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: HunterPalette.textMuted, fontStyle: FontStyle.italic),
  );
}

/// Explicit "no data" message (FR-016).
class EmptySectionText extends StatelessWidget {
  const EmptySectionText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: HunterPalette.textMuted, fontStyle: FontStyle.italic),
  );
}
