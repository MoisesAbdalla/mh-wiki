import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/features/monsters/domain/entities/rank_hp.dart';

/// Horizontal HP ruler: the solo value (gold tick), 2 hunters (tick) and 3–4
/// hunters (a band) on one axis from 0 to the largest estimate, with their
/// values (005 FR-013, research R7). When the values would collide (narrow
/// width or large text) they are listed under the axis instead. Decorative
/// for screen readers: the section reads the values as one sentence.
class HpRuler extends StatelessWidget {
  const HpRuler({
    required this.solo,
    required this.two,
    required this.more,
    required this.format,
    super.key,
  });

  final int solo;
  final HpRange two;

  /// 3 and 4 hunters together (3's minimum to 4's maximum).
  final HpRange more;
  final String Function(int value) format;

  String _range(HpRange r) =>
      r.isExact ? format(r.min) : '${format(r.min)}–${format(r.max)}';

  @override
  Widget build(BuildContext context) {
    final labels = [
      ('1', format(solo)),
      ('2', _range(two)),
      ('3–4', _range(more)),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final scaler = MediaQuery.textScalerOf(context);
        final valueStyle = notebookNumber(size: 13, bold: true);
        double measure(String text) => (TextPainter(
          text: TextSpan(text: text, style: valueStyle),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
        )..layout()).width;

        final top = math.max(more.max, 1).toDouble();
        double x(num v) => (v / top).clamp(0, 1) * width;
        final twoX = x(two.min);
        final widths = [for (final (_, v) in labels) measure(v)];
        // Label 1 sits at the left, 2 centred on its tick, 3–4 at the right.
        final fits =
            scaler.scale(1) <= 1.3 &&
            width >= 300 &&
            widths[0] + 12 <= twoX - widths[1] / 2 &&
            twoX + widths[1] / 2 + 12 <= width - widths[2];

        final axis = SizedBox(
          height: 26,
          width: width,
          child: CustomPaint(
            painter: _RulerPainter(
              soloX: x(solo),
              twoX: twoX,
              moreFrom: x(more.min),
              moreTo: x(more.max),
            ),
          ),
        );

        return ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              axis,
              if (fits)
                SizedBox(
                  height: scaler.scale(34),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: _Label(labels[0], CrossAxisAlignment.start),
                      ),
                      Positioned(
                        left: twoX - widths[1] / 2,
                        child: _Label(labels[1], CrossAxisAlignment.center),
                      ),
                      Positioned(
                        right: 0,
                        child: _Label(labels[2], CrossAxisAlignment.end),
                      ),
                    ],
                  ),
                )
              else
                for (final (players, value) in labels)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 12,
                      children: [
                        Text(
                          players,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(value, style: valueStyle),
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.label, this.align);

  final (String, String) label;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: align,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label.$1, style: Theme.of(context).textTheme.bodySmall),
      Text(label.$2, style: notebookNumber(size: 13, bold: true)),
    ],
  );
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({
    required this.soloX,
    required this.twoX,
    required this.moreFrom,
    required this.moreTo,
  });

  final double soloX;
  final double twoX;
  final double moreFrom;
  final double moreTo;

  @override
  void paint(Canvas canvas, Size size) {
    const axisY = 14.0;
    final axis = Paint()
      ..color = HunterPalette.border
      ..strokeWidth = 2;
    canvas
      ..drawLine(const Offset(0, axisY), Offset(size.width, axisY), axis)
      ..drawRect(
        Rect.fromLTRB(
          moreFrom,
          axisY - 3,
          math.max(moreTo, moreFrom + 2),
          axisY + 3,
        ),
        Paint()..color = HunterPalette.border,
      );
    void tick(double x, double half, Color color) => canvas.drawLine(
      Offset(x.clamp(1, size.width - 1), axisY - half),
      Offset(x.clamp(1, size.width - 1), axisY + half),
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );
    tick(twoX, 7, HunterPalette.textMuted);
    tick(moreTo, 7, HunterPalette.textMuted);
    tick(soloX, 11, HunterPalette.gold);
  }

  @override
  bool shouldRepaint(_RulerPainter old) =>
      old.soloX != soloX ||
      old.twoX != twoX ||
      old.moreFrom != moreFrom ||
      old.moreTo != moreTo;
}
