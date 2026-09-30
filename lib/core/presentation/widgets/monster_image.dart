import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';

/// Monster thumbnail (hunter's-notes icon) in a gold frame. Without an image,
/// or when it fails to load, shows a marker in the same frame (FR-003, FR-004).
class MonsterImage extends StatelessWidget {
  const MonsterImage({
    required this.asset,
    this.size = 48,
    this.emphasized = false,
    super.key,
  });

  final String? asset;
  final double size;

  /// Detail header: thicker frame with an outer ring.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final path = asset;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final inner = size - (emphasized ? 16 : 8);
    final marker = _Marker(size: inner);

    final frame = Container(
      key: const ValueKey('monster-image-frame'),
      width: size,
      height: size,
      padding: EdgeInsets.all(emphasized ? 7 : 3),
      decoration: BoxDecoration(
        color: HunterPalette.panelRaised,
        border: Border.all(
          color: HunterPalette.goldFrame,
          width: emphasized ? 2 : 1,
        ),
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
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: HunterPalette.border),
      ),
      child: frame,
    );
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
    child: Icon(Icons.pets, size: size * 0.55, color: HunterPalette.goldFrame),
  );
}
