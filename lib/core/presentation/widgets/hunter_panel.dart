import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';

/// Framed panel of the hunter's-notes look, with an optional heading.
class HunterPanel extends StatelessWidget {
  const HunterPanel({
    required this.child,
    this.title,
    this.trailing,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    super.key,
  });

  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final heading = title;
    // A Material (not a decorated box) so ink effects of tiles inside
    // (e.g. radio options) stay visible.
    return Padding(
      padding: margin,
      child: Material(
        color: HunterPalette.panel,
        shape: Border.all(color: HunterPalette.border),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (heading != null) ...[
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(heading, style: hunterDisplay(size: 14)),
                    ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 12),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
