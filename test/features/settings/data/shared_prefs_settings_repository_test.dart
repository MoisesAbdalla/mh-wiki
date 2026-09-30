import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/settings/data/shared_prefs_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SharedPrefsSettingsRepository> repositoryWith(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPrefsSettingsRepository(await SharedPreferences.getInstance());
  }

  test('defaults to pt-BR when nothing is stored', () async {
    final repository = await repositoryWith({});
    expect((await repository.load()).nameLanguage, NameLanguage.ptBr);
  });

  test('persists the chosen language (FR-022)', () async {
    final repository = await repositoryWith({});

    final result = await repository.saveNameLanguage(NameLanguage.en);

    expect(result, isA<Success<void>>());
    expect((await repository.load()).nameLanguage, NameLanguage.en);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(SharedPrefsSettingsRepository.nameLanguageKey),
      'en',
    );
  });

  test('unknown stored value falls back to pt-BR', () async {
    final repository = await repositoryWith({
      SharedPrefsSettingsRepository.nameLanguageKey: 'klingon',
    });
    expect((await repository.load()).nameLanguage, NameLanguage.ptBr);
  });
}
