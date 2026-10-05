import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/underline_tabs.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/assistant_labels.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// "Onde você está?" (008 ui-contract): rank tabs, then the step chips of
/// the chosen rank. A rank tab alone does not change the progress; a chip
/// does.
class ProgressPicker extends StatefulWidget {
  const ProgressPicker({
    required this.progress,
    required this.onChanged,
    super.key,
  });

  final Progress progress;
  final ValueChanged<Progress> onChanged;

  @override
  State<ProgressPicker> createState() => _ProgressPickerState();
}

class _ProgressPickerState extends State<ProgressPicker> {
  late ProgressRank _rank = widget.progress.rank;

  @override
  void didUpdateWidget(ProgressPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) _rank = widget.progress.rank;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter, 10, gutter, 4),
      child: Material(
        color: HunterPalette.panel,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: HunterPalette.borderSubtle),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(l10n.whereAreYou, style: notebookTitle(size: 18)),
              ),
              UnderlineTabs<ProgressRank>(
                ruled: false,
                textSize: 15,
                options: [
                  for (final r in ProgressRank.values)
                    TabOption(value: r, text: rankText(l10n, r)),
                ],
                selected: _rank,
                onChanged: (r) => setState(() => _rank = r),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final step in Progress.stepsOf(_rank))
                    _StepChip(
                      progress: Progress(_rank, step),
                      selected: Progress(_rank, step) == widget.progress,
                      onTap: () => widget.onChanged(Progress(_rank, step)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.progress,
    required this.selected,
    required this.onTap,
  });

  final Progress progress;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = progressText(l10n, progress);
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: '${rankText(l10n, progress.rank)} $text',
      excludeSemantics: true,
      child: Material(
        color: selected ? HunterPalette.panelHighlight : Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected ? HunterPalette.gold : HunterPalette.border,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: InkWell(
          onTap: selected ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                widthFactor: 1,
                child: Text(
                  text,
                  style: notebookNumber(
                    size: 14,
                    bold: true,
                    color: selected
                        ? HunterPalette.gold
                        : HunterPalette.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
