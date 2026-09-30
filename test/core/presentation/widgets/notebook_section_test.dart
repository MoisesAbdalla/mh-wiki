import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';

/// 005 FR-003/FR-004: a numbered section in one card, never nested cards.
void main() {
  Future<void> pump(
    WidgetTester tester, {
    String? note,
    double width = 400,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildHunterTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 800),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: ListView(
              children: [
                NotebookSection(
                  number: 2,
                  title: 'Fraquezas elementais',
                  note: note,
                  child: const Text('conteúdo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the number and the title as a header', (tester) async {
    await pump(tester);

    expect(find.text('2'), findsOneWidget);
    expect(find.text('Fraquezas elementais'), findsOneWidget);
    expect(find.text('conteúdo'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Fraquezas elementais')),
      matchesSemantics(isHeader: true, label: 'Fraquezas elementais'),
    );
  });

  testWidgets('number in Averia, title in IM Fell', (tester) async {
    await pump(tester);

    TextStyle? style(String text) => tester.widget<Text>(find.text(text)).style;
    expect(style('2')?.fontFamily, 'AveriaSerifLibre');
    expect(style('Fraquezas elementais')?.fontFamily, 'IMFellEnglishSC');
  });

  testWidgets('shows the optional note once', (tester) async {
    await pump(tester, note: 'Igual à forma base');

    expect(find.text('Igual à forma base'), findsOneWidget);
  });

  testWidgets('is one card with no frame inside it', (tester) async {
    await pump(tester);

    final shaped = tester
        .widgetList<Material>(
          find.descendant(
            of: find.byType(NotebookSection),
            matching: find.byType(Material),
          ),
        )
        .where((m) => m.shape != null)
        .toList();
    expect(shaped, hasLength(1), reason: 'the section card itself');
    expect(find.byType(Card), findsNothing);
    final boxes = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(NotebookSection),
            matching: find.byType(DecoratedBox),
          ),
        )
        .where((b) {
          final d = b.decoration;
          return d is BoxDecoration && d.border is Border && _isBox(d.border!);
        });
    expect(boxes, isEmpty);
  });

  testWidgets('no overflow at 320 dp and 200 % text', (tester) async {
    await pump(tester, note: 'Igual à forma base', width: 320, textScale: 2);

    expect(tester.takeException(), isNull);
  });
}

/// A border on every side frames the content; a single rule does not.
bool _isBox(BoxBorder border) =>
    border is Border &&
    border.top != BorderSide.none &&
    border.bottom != BorderSide.none &&
    border.left != BorderSide.none &&
    border.right != BorderSide.none;
