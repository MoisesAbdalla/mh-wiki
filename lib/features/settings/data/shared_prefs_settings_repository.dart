import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/settings/domain/app_settings.dart';
import 'package:mh_wiki/features/settings/domain/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists settings with shared_preferences (Android, web and Windows;
/// research R7).
class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._prefs);

  static const nameLanguageKey = 'name_language';

  final SharedPreferences _prefs;

  @override
  Future<AppSettings> load() async {
    final stored = _prefs.getString(nameLanguageKey);
    final language = NameLanguage.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => NameLanguage.ptBr,
    );
    return AppSettings(nameLanguage: language);
  }

  @override
  Future<Result<void>> saveNameLanguage(NameLanguage language) async {
    try {
      final saved = await _prefs.setString(nameLanguageKey, language.name);
      if (!saved) {
        return const Err(PreferenceStorageFailure('write rejected'));
      }
      return const Success(null);
    } on Object catch (error) {
      return Err(PreferenceStorageFailure('$error'));
    }
  }
}
