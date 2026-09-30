import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';

/// Color of each element, used consistently in list and detail (002 FR-007).
Color elementColor(ElementType element) => switch (element) {
  ElementType.fire => HunterPalette.fire,
  ElementType.water => HunterPalette.water,
  ElementType.thunder => HunterPalette.thunder,
  ElementType.ice => HunterPalette.ice,
  ElementType.dragon => HunterPalette.dragon,
};

/// Stroke icon of an element (flame, drop, bolt, snowflake, four-point star),
/// drawn on a 24x24 grid like the prototype; decorative for screen readers.
class ElementIcon extends StatelessWidget {
  const ElementIcon({required this.element, this.size = 22, super.key});

  final ElementType element;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _ElementPainter(element, elementColor(element)),
    ),
  );
}

class _ElementPainter extends CustomPainter {
  _ElementPainter(this.element, this.color);

  final ElementType element;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_path(element), paint);
  }

  static Path _path(ElementType element) => switch (element) {
    ElementType.fire =>
      Path()
        ..moveTo(12, 3)
        ..cubicTo(13, 7, 17, 8, 17, 13)
        ..arcToPoint(const Offset(7, 13), radius: const Radius.circular(5))
        ..cubicTo(7, 10, 9, 9, 9, 7)
        ..cubicTo(10, 8, 11, 9, 11, 10)
        ..cubicTo(11, 7, 12, 5, 12, 3)
        ..close(),
    ElementType.water =>
      Path()
        ..moveTo(12, 3)
        ..cubicTo(12, 3, 18, 10, 18, 14)
        ..arcToPoint(const Offset(6, 14), radius: const Radius.circular(6))
        ..cubicTo(6, 10, 12, 3, 12, 3)
        ..close(),
    ElementType.thunder =>
      Path()
        ..moveTo(13, 2)
        ..lineTo(5, 14)
        ..lineTo(11, 14)
        ..lineTo(10, 22)
        ..lineTo(18, 10)
        ..lineTo(12, 10)
        ..close(),
    ElementType.ice =>
      Path()
        ..moveTo(12, 2)
        ..lineTo(12, 22)
        ..moveTo(3.3, 7)
        ..lineTo(20.7, 17)
        ..moveTo(3.3, 17)
        ..lineTo(20.7, 7),
    ElementType.dragon =>
      Path()
        ..moveTo(12, 2)
        ..lineTo(15, 9)
        ..lineTo(22, 12)
        ..lineTo(15, 15)
        ..lineTo(12, 22)
        ..lineTo(9, 15)
        ..lineTo(2, 12)
        ..lineTo(9, 9)
        ..close(),
  };

  @override
  bool shouldRepaint(_ElementPainter old) =>
      old.element != element || old.color != color;
}
