import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';

/// A numbered section of the notebook: "2 Vida" and its content, in its own
/// card. Inside, content is drawn with ruled rows, never nested cards
/// (005 FR-003/004, revised after the US1 review).
class NotebookSection extends StatelessWidget {
  const NotebookSection({
    required this.title,
    required this.child,
    this.number,
    this.note,
    this.trailing,
    super.key,
  });

  /// Position in the detail (1 Fraquezas, 2 Vida…); `null` for unnumbered
  /// sections such as settings.
  final int? number;
  final String title;

  /// Discreet remark next to the title, e.g. "Igual à forma base" or a rank.
  final String? note;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = Space.gutter(width);
    final remark = note;
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, 0, gutter, Space.card),
      // A Material (not a decorated box) so ink effects of tabs inside stay
      // visible on the card.
      child: Material(
        color: HunterPalette.panel,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: HunterPalette.borderSubtle),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 10,
                runSpacing: 4,
                children: [
                  if (number case final n?)
                    ExcludeSemantics(
                      child: Text(
                        '$n',
                        style: notebookNumber(
                          size: 18,
                          color: HunterPalette.gold,
                          bold: true,
                        ),
                      ),
                    ),
                  Semantics(
                    container: true,
                    header: true,
                    child: Text(title, style: notebookTitle(size: 22)),
                  ),
                  if (remark != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        remark,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: Space.title),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Explicit "no data" message (001 FR-016).
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
