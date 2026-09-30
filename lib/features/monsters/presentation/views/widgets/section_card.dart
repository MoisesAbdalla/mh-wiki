import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/widgets/hunter_panel.dart';

/// Titled block used by every detail section, drawn as a hunter's-notes panel.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.title,
    required this.child,
    this.trailing,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) => HunterPanel(
    title: title,
    trailing: trailing,
    margin: margin,
    child: child,
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
