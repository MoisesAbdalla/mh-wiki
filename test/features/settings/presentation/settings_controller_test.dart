import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/features/settings/domain/usecases/load_settings.dart';
import 'package:mh_wiki/features/settings/domain/usecases/set_name_language.dart';
import 'package:mh_wiki/features/settings/presentation/settings_controller.dart';

import '../../../fakes/fake_settings_repository.dart';

void main() {
  late FakeSettingsRepository repository;
  late SettingsController controller;
  late int notifications;

  setUp(() {
    repository = FakeSettingsRepository(stored: NameLanguage.en);
    // Use cases only (Principle II); the fake is wrapped by them.
    controller = SettingsController(
      loadSettings: LoadSettings(repository),
      setNameLanguage: SetNameLanguage(repository),
    );
    notifications = 0;
    controller.addListener(() => notifications++);
  });

  tearDown(() => controller.dispose());

  test('defaults to pt-BR before loading', () {
    expect(controller.settings.nameLanguage, NameLanguage.ptBr);
  });

  test('load reads the stored preference', () async {
    await controller.load();
    expect(controller.settings.nameLanguage, NameLanguage.en);
    expect(notifications, 1);
  });

  test('setNameLanguage applies immediately and persists', () async {
    final pending = controller.setNameLanguage(NameLanguage.en);
    expect(controller.settings.nameLanguage, NameLanguage.en);
    expect(notifications, 1);

    await pending;
    expect(repository.stored, NameLanguage.en);
    expect(controller.saveFailed, isFalse);
  });

  test(
    'a failed save keeps the choice and reports a transient error',
    () async {
      repository
        ..stored = NameLanguage.ptBr
        ..failSaves = true;

      await controller.setNameLanguage(NameLanguage.en);

      expect(controller.settings.nameLanguage, NameLanguage.en);
      expect(controller.saveFailed, isTrue);
      controller.acknowledgeSaveFailure();
      expect(controller.saveFailed, isFalse);
    },
  );
}
