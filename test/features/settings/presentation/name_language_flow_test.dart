import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/app/app.dart';
import 'package:mh_wiki/app/di/app_dependencies.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/settings/domain/usecases/load_settings.dart';
import 'package:mh_wiki/features/settings/domain/usecases/set_name_language.dart';
import 'package:mh_wiki/features/settings/presentation/settings_controller.dart';

import '../../../fakes/controllers.dart';
import '../../../fakes/fake_monster_repository.dart';
import '../../../fakes/fake_settings_repository.dart';
import '../../../fakes/monster_fixtures.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeSettingsRepository settingsRepository;
  late SettingsController settings;
  late MonsterListController monsters;

  setUp(() async {
    settingsRepository = FakeSettingsRepository();
    settings = SettingsController(
      loadSettings: LoadSettings(settingsRepository),
      setNameLanguage: SetNameLanguage(settingsRepository),
    );
    monsters = buildController(
      FakeMonsterRepository(
        monsters: [
          buildMonster(
            slug: 'pink-rathian',
            en: 'Pink Rathian',
            ptBr: 'Rathian Rosa',
          ),
          buildMonster(slug: 'arkveld', en: 'Arkveld'),
        ],
      ),
    );
    linkNameLanguage(settings: settings, monsters: monsters);
    await settings.load();
    await monsters.load();
  });

  tearDown(() {
    settings.dispose();
    monsters.dispose();
  });

  Future<void> pumpFullApp(WidgetTester tester) async {
    setWindowSize(tester, const Size(400, 800));
    await tester.pumpWidget(
      MhWikiApp(monsterListController: monsters, settingsController: settings),
    );
    await tester.pumpAndSettle();
  }

  Future<void> chooseEnglish(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    expect(find.text('Idioma dos nomes do jogo'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  testWidgets('switching to English renames list and detail instantly', (
    tester,
  ) async {
    await pumpFullApp(tester);
    expect(find.text('Rathian Rosa'), findsOneWidget);

    await chooseEnglish(tester);

    expect(find.text('Rathian Rosa'), findsNothing);
    expect(find.text('Pink Rathian'), findsOneWidget);
    expect(settingsRepository.stored, NameLanguage.en);

    await tester.tap(find.text('Pink Rathian'));
    await tester.pumpAndSettle();
    expect(find.text('Pink Rathian'), findsWidgets);
    expect(find.text('Rathian Rosa'), findsNothing);
  });

  testWidgets('missing pt-BR names fall back to English (FR-024)', (
    tester,
  ) async {
    await pumpFullApp(tester);
    expect(find.text('Arkveld'), findsOneWidget);
  });

  testWidgets('search finds both names regardless of setting (FR-023)', (
    tester,
  ) async {
    await pumpFullApp(tester);
    await chooseEnglish(tester);

    await tester.enterText(find.byType(TextField), 'rosa');
    await tester.pumpAndSettle();

    expect(find.text('Pink Rathian'), findsOneWidget);
    expect(find.text('Arkveld'), findsNothing);
  });

  testWidgets('a failed save shows a message but keeps the choice', (
    tester,
  ) async {
    settingsRepository.failSaves = true;
    await pumpFullApp(tester);
    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível salvar a preferência'), findsOneWidget);
    expect(settings.settings.nameLanguage, NameLanguage.en);
  });
}
