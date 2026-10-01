import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Decoration slots as round level badges and the Rampage slot as a square
/// gold one (006 ui-contract "Atributos").
class SlotBadges extends StatelessWidget {
  const SlotBadges({required this.slots, required this.rampageSlot, super.key});

  final List<int> slots;
  final int rampageSlot;

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
            for (final level in slots) _Badge(level: level, rampage: false),
          if (rampageSlot > 0) ...[
            const SizedBox(width: 8),
            Text(l10n.rampageSlot, style: muted),
            _Badge(level: rampageSlot, rampage: true),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.level, required this.rampage});

  final int level;
  final bool rampage;

  @override
  Widget build(BuildContext context) {
    final color = rampage ? HunterPalette.gold : HunterPalette.text;
    return Container(
      key: ValueKey(rampage ? 'rampage-slot' : 'slot-$level'),
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: rampage ? HunterPalette.gold : HunterPalette.textMuted,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(rampage ? 3 : 11),
      ),
      child: Text('$level', style: notebookNumber(size: 12, color: color)),
    );
  }
}
