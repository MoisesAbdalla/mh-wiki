import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/widgets/slot_icon.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Decoration slots with the game's slot icons (a gem with one to four
/// pips), and the Rampage slot as the same gem in gold (006 ui-contract
/// "Atributos").
class SlotBadges extends StatelessWidget {
  const SlotBadges({
    required this.slots,
    required this.rampageSlot,
    this.game = Game.riseSunbreak,
    super.key,
  });

  final List<int> slots;
  final int rampageSlot;
  final Game game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: HunterPalette.textMuted);
    String levels(List<int> values) => values.isEmpty
        ? l10n.none
        : values.map((v) => l10n.slotLevel(v)).join(', ');

    return Semantics(
      label: l10n.slotsSemantics(
        levels(slots),
        levels([if (rampageSlot > 0) rampageSlot]),
      ),
      excludeSemantics: true,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(l10n.slots, style: muted),
          if (slots.isEmpty)
            Text(l10n.noSlots, style: muted)
          else
            for (final (i, level) in slots.indexed)
              SlotIcon(
                key: ValueKey('slot-$i-$level'),
                level: level,
                game: game,
              ),
          if (rampageSlot > 0) ...[
            const SizedBox(width: 10),
            Text(l10n.rampageSlot, style: muted),
            SlotIcon(
              key: const ValueKey('rampage-slot'),
              level: rampageSlot,
              rampage: true,
            ),
          ],
        ],
      ),
    );
  }
}
