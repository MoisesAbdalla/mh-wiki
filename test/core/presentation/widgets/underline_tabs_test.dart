import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/core/presentation/widgets/underline_tabs.dart';

/// 005 FR-006/FR-007/FR-008, research R4: underlined tabs, text or image.
void main() {
  late int? tapped;

  Future<void> pump(
    WidgetTester tester, {
    required List<TabOption<int>> options,
    int selected = 0,
    double width = 400,
    double textScale = 1,
  }) async {
    tapped = null;
    tester.view.physicalSize = Size(width, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildHunterTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 600),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: UnderlineTabs<int>(
              options: options,
              selected: selected,
              onChanged: (v) => tapped = v,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const texts = [
    TabOption(value: 0, text: 'Base'),
    TabOption(value: 1, text: 'Temperado'),
    TabOption(value: 2, text: 'Arquitemperado'),
  ];

  testWidgets('tapping a tab reports its value', (tester) async {
    await pump(tester, options: texts);

    await tester.tap(find.text('Temperado'));
    expect(tapped, 1);
  });

  testWidgets('only the selected tab has the gold underline', (tester) async {
    await pump(tester, options: texts, selected: 1);

    Color? underline(String text) {
      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(of: find.text(text), matching: find.byType(DecoratedBox))
            .first,
      );
      final border = (box.decoration as BoxDecoration).border as Border?;
      return border?.bottom.color;
    }

    expect(underline('Temperado'), HunterPalette.gold);
    expect(underline('Base'), isNot(HunterPalette.gold));
  });

  testWidgets('tabs are selectable buttons with a label', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      options: const [
        TabOption(value: 0, text: 'Todos'),
        TabOption(value: 1, text: 'World', semanticsLabel: 'World: Iceborne'),
      ],
      selected: 1,
    );

    expect(find.bySemanticsLabel('World: Iceborne'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('World: Iceborne')),
      matchesSemantics(
        label: 'World: Iceborne',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('tabs are at least 48 dp tall', (tester) async {
    await pump(tester, options: texts);

    for (final label in ['Base', 'Temperado']) {
      final tab = find
          .ancestor(of: find.text(label), matching: find.byType(InkWell))
          .first;
      expect(tester.getSize(tab).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(tab).width, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('an image that fails shows the text instead', (tester) async {
    await pump(
      tester,
      options: const [
        TabOption(value: 0, text: 'Wilds', image: 'assets/missing.webp'),
      ],
    );

    expect(find.text('Wilds'), findsOneWidget);
  });

  testWidgets('an unselected image tab is dimmed', (tester) async {
    await pump(
      tester,
      options: const [
        TabOption(value: 0, text: 'World', image: 'assets/missing.webp'),
        TabOption(value: 1, text: 'Rise', image: 'assets/missing.webp'),
      ],
    );

    double opacityOf(String text) => tester
        .widget<Opacity>(
          find.ancestor(of: find.text(text), matching: find.byType(Opacity)),
        )
        .opacity;
    expect(opacityOf('World'), 1);
    expect(opacityOf('Rise'), lessThan(1));
  });

  testWidgets('scrolls in one row instead of wrapping at 320 dp / 200 %', (
    tester,
  ) async {
    await pump(tester, options: texts, width: 320, textScale: 2);

    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(UnderlineTabs<int>),
        matching: find.byType(Scrollable),
      ),
      findsOneWidget,
    );
    final tops = {
      for (final t in ['Base', 'Temperado', 'Arquitemperado'])
        tester.getTopLeft(find.text(t)).dy,
    };
    expect(tops, hasLength(1));
  });
}
