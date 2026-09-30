import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Game filter as tabs: Todos, World, Rise, Wilds (FR-009). `null` = Todos.
class GameTabs extends StatelessWidget {
  const GameTabs({required this.selected, required this.onChanged, super.key});

  final Game? selected;
  final ValueChanged<Game?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HunterTabs<Game?>(
      options: [
        (null, l10n.filterAll),
        (Game.worldIceborne, l10n.filterWorldIceborne),
        (Game.riseSunbreak, l10n.filterRiseSunbreak),
        (Game.wilds, l10n.filterWilds),
      ],
      selected: selected,
      onChanged: onChanged,
    );
  }
}

/// Equal-width tabs in the hunter style. Wraps to two per row when the text
/// is enlarged or space is tight, so labels never overflow (FR-011).
class HunterTabs<T> extends StatelessWidget {
  const HunterTabs({
    required this.options,
    required this.selected,
    required this.onChanged,
    this.dense = false,
    this.semanticsLabel,
    super.key,
  });

  final List<(T, String)> options;

  /// Spoken label of a tab, when it should say more than its text.
  final String Function(String label)? semanticsLabel;
  final T selected;
  final ValueChanged<T> onChanged;

  /// Smaller labels, for tabs inside a panel (e.g. ranks).
  final bool dense;

  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow =
            textScale > 1.4 || constraints.maxWidth < options.length * 72
            ? (options.length / 2).ceil()
            : options.length;
        // Clamped: during route transitions the width can be ~0.
        final width = math.max(
          0.0,
          (constraints.maxWidth - _gap * (perRow - 1)) / perRow - 0.01,
        );
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final (value, label) in options)
              SizedBox(
                width: width,
                child: _Tab(
                  label: label,
                  semanticsLabel: semanticsLabel?.call(label),
                  selected: value == selected,
                  dense: dense,
                  onTap: () => onChanged(value),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.dense,
    required this.onTap,
    this.semanticsLabel,
  });

  final String label;
  final String? semanticsLabel;
  final bool selected;
  final bool dense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? HunterPalette.textOnGold : HunterPalette.gold;
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: Material(
        color: selected ? HunterPalette.gold : Colors.transparent,
        shape: Border.all(
          color: selected ? HunterPalette.gold : HunterPalette.border,
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: hunterDisplay(
                    size: dense ? 11 : 12,
                    color: fg,
                    letterSpacing: 1,
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
