import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';

/// Monster thumbnail (hunter's-notes icon) on a dark plate. Without an image,
/// or when it fails to load, shows a marker in the same place (002 FR-003,
/// FR-004). The detail plate has a thin rule and a slight tilt (005).
class MonsterImage extends StatelessWidget {
  const MonsterImage({
    required this.asset,
    this.size = 48,
    this.emphasized = false,
    super.key,
  });

  final String? asset;
  final double size;

  /// Detail header: thin rule and a +3° tilt, like a pinned specimen plate.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final path = asset;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final inner = size - (emphasized ? 12 : 4);
    final marker = _Marker(size: inner);

    final frame = Container(
      key: const ValueKey('monster-image-frame'),
      width: size,
      height: size,
      padding: EdgeInsets.all(emphasized ? 6 : 2),
      decoration: BoxDecoration(
        color: HunterPalette.panel,
        borderRadius: emphasized ? null : BorderRadius.circular(3),
        border: emphasized ? Border.all(color: HunterPalette.border) : null,
      ),
      child: path == null
          ? marker
          : Image.asset(
              path,
              width: inner,
              height: inner,
              fit: BoxFit.contain,
              cacheWidth: (inner * dpr).round(),
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => marker,
            ),
    );

    if (!emphasized) return frame;
    return Transform.rotate(angle: 3 * math.pi / 180, child: frame);
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('monster-image-marker'),
    width: size,
    height: size,
    child: Icon(
      Icons.pets,
      size: size * 0.55,
      color: HunterPalette.textDisabled,
    ),
  );
}
