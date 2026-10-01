import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_theme.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapons_page.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

import '../../../../fakes/controllers.dart';
import '../../../../helpers/pump_app.dart';

/// 006 ui-contract "Accessibility": 320 dp at 200 % text, contrast and tap
/// targets on the weapon list.
void main() {
  testWidgets('list at 320 dp and 200 % text: no overflow, tap targets', (
    tester,
  ) async {
    final controller = buildWeaponController();
    setWindowSize(tester, const Size(320, 640));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildHunterTheme(),
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: WeaponsPage(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Scroll through the trees; any overflow fails the test.
    await tester.scrollUntilVisible(
      find.text('Aardzahn'),
      300,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  testWidgets('list meets text contrast and label guidelines', (tester) async {
    final controller = buildWeaponController();
    setWindowSize(tester, const Size(400, 1600));
    await pumpApp(tester, WeaponsPage(controller: controller));

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  });
}
