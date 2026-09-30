import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';

import '../../../helpers/pump_app.dart';

void main() {
  BoxDecoration frameOf(WidgetTester tester) {
    final box = tester.widget<Container>(
      find.byKey(const ValueKey('monster-image-frame')),
    );
    return box.decoration! as BoxDecoration;
  }

  testWidgets('shows the thumbnail inside a gold frame', (tester) async {
    await pumpApp(
      tester,
      const Scaffold(
        body: MonsterImage(asset: 'assets/images/monsters/wilds/rathalos.webp'),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(
      (frameOf(tester).border! as Border).top.color,
      HunterPalette.goldFrame,
    );
  });

  testWidgets('without an image shows the styled marker (FR-004)', (
    tester,
  ) async {
    await pumpApp(tester, const Scaffold(body: MonsterImage(asset: null)));

    expect(find.byType(Image), findsNothing);
    expect(find.byKey(const ValueKey('monster-image-marker')), findsOneWidget);
    expect(
      (frameOf(tester).border! as Border).top.color,
      HunterPalette.goldFrame,
    );
  });

  testWidgets('an image that fails to load falls back to the marker', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const Scaffold(body: MonsterImage(asset: 'assets/does-not-exist.webp')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('monster-image-marker')), findsOneWidget);
  });
}
