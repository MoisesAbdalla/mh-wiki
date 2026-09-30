import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';

/// One line of a notebook table: leading mark, label, value at the right,
/// separated from the next line by a hairline (005 FR-003). Both sides wrap
/// instead of overflowing at large text.
class RuledRow extends StatelessWidget {
  const RuledRow({
    required this.label,
    this.leading,
    this.trailing,
    this.ruled = true,
    super.key,
  });

  final Widget? leading;
  final Widget label;
  final Widget? trailing;

  /// Draws the hairline under the row.
  final bool ruled;

  @override
  Widget build(BuildContext context) {
    final lead = leading;
    final value = trailing;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: ruled
            ? const Border(
                bottom: BorderSide(color: HunterPalette.borderSubtle),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.row),
        child: Row(
          children: [
            if (lead != null) ...[lead, const SizedBox(width: 10)],
            Expanded(child: label),
            if (value != null) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Align(alignment: Alignment.centerRight, child: value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small caption that opens a group of [RuledRow]s, e.g. the method of a
/// group of materials ("Entalhe").
class RuledCaption extends StatelessWidget {
  const RuledCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: HunterPalette.border)),
    ),
    child: Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.4),
      ),
    ),
  );
}
