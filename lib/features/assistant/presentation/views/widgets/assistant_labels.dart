import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// "M2★", "4★" or "MR 100+".
String progressText(AppLocalizations l10n, Progress p) =>
    p.rank == ProgressRank.post
    ? l10n.progressBand(p.step)
    : l10n.progressStar(p.step);

/// Where a next build becomes available: "A partir de M3★", or "Depois da
/// história" for the end of the Master Rank story.
String availableFrom(AppLocalizations l10n, Progress p) =>
    p == const Progress(ProgressRank.master, 'M6')
    ? l10n.afterStory
    : l10n.stageFrom(progressText(l10n, p));

String rankText(AppLocalizations l10n, ProgressRank rank) => switch (rank) {
  ProgressRank.low => l10n.rankLow,
  ProgressRank.high => l10n.rankHigh,
  ProgressRank.master => l10n.rankMaster,
  ProgressRank.post => l10n.rankPost,
};

String partText(AppLocalizations l10n, BuildPart part) => switch (part) {
  BuildPart.head => l10n.partHead,
  BuildPart.chest => l10n.partChest,
  BuildPart.arms => l10n.partArms,
  BuildPart.waist => l10n.partWaist,
  BuildPart.legs => l10n.partLegs,
};

/// The guide's stage label as a seal: gold when it is for now, muted for
/// the next ones.
class StageSeal extends StatelessWidget {
  const StageSeal(this.label, {this.active = true, super.key});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? HunterPalette.gold : HunterPalette.textDisabled;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: active ? HunterPalette.gold : HunterPalette.border,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          label,
          style: notebookNumber(size: 12, color: color, bold: true),
        ),
      ),
    );
  }
}
