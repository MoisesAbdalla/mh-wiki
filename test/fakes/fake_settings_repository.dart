import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/settings/domain/app_settings.dart';
import 'package:mh_wiki/features/settings/domain/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({this.stored = NameLanguage.ptBr});

  NameLanguage stored;
  bool failSaves = false;

  @override
  Future<AppSettings> load() async => AppSettings(nameLanguage: stored);

  @override
  Future<Result<void>> saveNameLanguage(NameLanguage language) async {
    if (failSaves) return const Err(PreferenceStorageFailure('disk full'));
    stored = language;
    return const Success(null);
  }
}
