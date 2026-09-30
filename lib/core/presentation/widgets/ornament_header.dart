import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';

/// Section title between two gold lines: ——— WORLD : ICEBORNE ——— (FR-010).
class OrnamentHeader extends StatelessWidget {
  const OrnamentHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Container(
    color: HunterPalette.background,
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
    child: Row(
      children: [
        const Expanded(child: _Line()),
        const SizedBox(width: 10),
        Flexible(
          flex: 4,
          child: Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: hunterDisplay(size: 13),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: _Line()),
      ],
    ),
  );
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: HunterPalette.border);
}
