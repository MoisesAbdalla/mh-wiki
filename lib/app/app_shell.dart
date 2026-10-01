import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/breakpoints.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Navigation between the app's areas (006 ui-contract "App shell"): a
/// bottom bar below 840 dp, a rail from 840 dp. Areas live in an
/// [IndexedStack], so each keeps its filters, search, scroll and selection.
class AppShell extends StatefulWidget {
  const AppShell({required this.monsters, required this.weapons, super.key});

  final Widget monsters;
  final Widget weapons;

  @override
  State<AppShell> createState() => _AppShellState();
}

typedef _Area = ({String glyph, String label, bool enabled});

class _AppShellState extends State<AppShell> {
  int _index = 0;

  List<_Area> _areas(AppLocalizations l10n) => [
    (glyph: '❦', label: l10n.areaMonsters, enabled: true),
    (glyph: '⚔', label: l10n.areaWeapons, enabled: true),
    // Armaduras arrives in 007, the Assistente in 008.
    (glyph: '⛨', label: l10n.areaArmor, enabled: false),
    (glyph: '✦', label: l10n.areaAssistant, enabled: false),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final areas = _areas(l10n);
    final body = IndexedStack(
      index: _index,
      children: [widget.monsters, widget.weapons],
    );

    Widget item(int i, {required bool vertical}) => _AreaButton(
      area: areas[i],
      selected: i == _index,
      comingSoon: l10n.areaComingSoon(areas[i].label),
      wide: vertical,
      onTap: () => setState(() => _index = i),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.expanded) {
          return Scaffold(
            body: Row(
              children: [
                Material(
                  key: const Key('area-rail'),
                  color: HunterPalette.background,
                  child: SafeArea(
                    right: false,
                    child: SizedBox(
                      width: 96,
                      child: Column(
                        children: [
                          const SizedBox(height: Space.card),
                          for (var i = 0; i < areas.length; i++)
                            item(i, vertical: true),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: HunterPalette.border,
                ),
                Expanded(child: body),
              ],
            ),
          );
        }
        return Scaffold(
          body: body,
          bottomNavigationBar: Material(
            key: const Key('area-bar'),
            color: HunterPalette.background,
            shape: const Border(top: BorderSide(color: HunterPalette.border)),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  for (var i = 0; i < areas.length; i++)
                    Expanded(child: item(i, vertical: false)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AreaButton extends StatelessWidget {
  const _AreaButton({
    required this.area,
    required this.selected,
    required this.comingSoon,
    required this.wide,
    required this.onTap,
  });

  final _Area area;
  final bool selected;
  final String comingSoon;
  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = !area.enabled
        ? HunterPalette.textDisabled
        : selected
        ? HunterPalette.gold
        : HunterPalette.textMuted;
    final label = area.enabled ? area.label : comingSoon;

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: wide ? 72 : 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(area.glyph, style: TextStyle(fontSize: 18, color: color)),
            const SizedBox(height: 2),
            Text(
              area.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: notebookTitle(size: 15, color: color),
            ),
          ],
        ),
      ),
    );
    if (area.enabled) {
      content = InkWell(onTap: selected ? null : onTap, child: content);
    } else {
      content = Tooltip(message: comingSoon, child: content);
    }

    return Semantics(
      button: true,
      selected: selected,
      enabled: area.enabled,
      label: label,
      excludeSemantics: true,
      onTap: area.enabled && !selected ? onTap : null,
      child: content,
    );
  }
}
