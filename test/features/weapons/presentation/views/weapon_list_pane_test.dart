import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_list_pane.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_row.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_tree_card.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_type_picker.dart';

import '../../../../fakes/controllers.dart';
import '../../../../fakes/fake_weapon_repository.dart';
import '../../../../helpers/pump_app.dart';

/// 006 ui-contract "Armas: list".
void main() {
  late FakeWeaponRepository repository;
  late WeaponListController controller;

  setUp(() {
    repository = FakeWeaponRepository();
    controller = buildWeaponController(repository);
  });

  Future<void> pumpPane(WidgetTester tester) async {
    await controller.ensureLoaded();
    await pumpApp(
      tester,
      Scaffold(
        body: WeaponListPane(controller: controller, onSelect: (_) {}),
      ),
    );
  }

  Finder label(String text) => find.bySemanticsLabel(text);

  List<String> rowNames(WidgetTester tester) => [
    for (final row in tester.widgetList<WeaponRow>(find.byType(WeaponRow)))
      row.weapon.name.en,
  ];

  testWidgets('only Rise can be chosen; World and Wilds are "em breve"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpPane(tester);

    expect(label('Monster Hunter Rise: Sunbreak'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('em breve')), findsNWidgets(2));
    final world = find.bySemanticsLabel(RegExp('World.*em breve'));
    expect(
      tester.getSemantics(world).flagsCollection.isEnabled,
      Tristate.isFalse,
    );
    handle.dispose();
  });

  testWidgets('the type picker marks the type and switches it', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPane(tester);

    expect(find.byType(WeaponTypePicker), findsOneWidget);
    expect(
      tester
          .getSemantics(label('Tipo de arma: Espadão'))
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );

    await tester.tap(find.text('Arco'));
    await tester.pumpAndSettle();
    expect(rowNames(tester), ["Hunter's Bow"]);
    handle.dispose();
  });

  testWidgets('the type picker scrolls at 320 dp without overflow', (
    tester,
  ) async {
    setWindowSize(tester, const Size(320, 640));
    await pumpPane(tester);
    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(WeaponTypePicker),
        matching: find.byType(Scrollable),
      ),
      findsOneWidget,
    );
  });

  testWidgets('tree cards: count, tree order, indent by depth', (tester) async {
    setWindowSize(tester, const Size(400, 2000));
    await pumpPane(tester);

    expect(find.byType(WeaponTreeCard), findsNWidgets(2));
    expect(find.text('6 armas'), findsOneWidget);
    expect(rowNames(tester), [
      'Bone Blade',
      'Flammenzahn I',
      'Flammenzahn II',
      'Gnashing Flammenzahn',
      'Gnashing Flammenzahn+',
      'Aardzahn',
      'Lohenzahn',
    ]);

    double left(String name) => tester.getTopLeft(find.text(name)).dx;
    expect(left('Flammenzahn II'), greaterThan(left('Flammenzahn I')));
    expect(WeaponRow.indent(1) - WeaponRow.indent(0), 16);
    expect(WeaponRow.indent(7), WeaponRow.indent(3));
  });

  testWidgets('rank tabs and search filter the rows', (tester) async {
    setWindowSize(tester, const Size(400, 2000));
    await pumpPane(tester);

    await tester.tap(find.text('Mestre'));
    await tester.pumpAndSettle();
    expect(rowNames(tester), [
      'Gnashing Flammenzahn+',
      'Aardzahn',
      'Lohenzahn',
    ]);

    await tester.enterText(find.byType(TextField), 'aard');
    await tester.pumpAndSettle();
    expect(rowNames(tester), ['Aardzahn']);
  });

  testWidgets('a row shows attack, special and affinity', (tester) async {
    setWindowSize(tester, const Size(400, 2000));
    await pumpPane(tester);

    final plus = find.ancestor(
      // Names show in pt-BR when there is one.
      of: find.text('Presardente Rangedora+'),
      matching: find.byType(WeaponRow),
    );
    expect(
      find.descendant(of: plus, matching: find.text('280')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: plus, matching: find.text('28')),
      findsOneWidget,
    );
    final affinity = tester.widget<Text>(
      find.descendant(of: plus, matching: find.text('−20%')),
    );
    expect(affinity.style?.color, HunterPalette.negative);

    // Bone Blade has no special and no affinity.
    final bone = find.ancestor(
      of: find.text('Bone Blade'),
      matching: find.byType(WeaponRow),
    );
    expect(
      find.descendant(of: bone, matching: find.textContaining('%')),
      findsNothing,
    );
  });

  testWidgets('empty result offers "Limpar filtros"', (tester) async {
    await pumpPane(tester);
    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma arma encontrada'), findsOneWidget);
    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();
    expect(find.byType(WeaponTreeCard), findsWidgets);
  });

  testWidgets('a failure shows retry inside the area', (tester) async {
    repository.failure = const DatasetUnavailable(Game.riseSunbreak);
    await pumpPane(tester);
    expect(find.text('Não foi possível carregar as armas.'), findsOneWidget);

    repository.failure = null;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.byType(WeaponTreeCard), findsWidgets);
  });
}
