import 'package:flutter/material.dart';

/// Monster picture, or a generic placeholder when there is none (FR-001).
class MonsterImage extends StatelessWidget {
  const MonsterImage({required this.asset, this.size = 48, super.key});

  final String? asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(size: size);
    final path = asset;
    if (path == null) return placeholder;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 4),
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * dpr).round(),
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(
        Icons.pets,
        size: size * 0.55,
        color: scheme.onSecondaryContainer,
      ),
    );
  }
}
