import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/settings/domain/app_settings.dart';

abstract interface class SettingsRepository {
  /// Returns defaults when nothing is stored.
  Future<AppSettings> load();

  Future<Result<void>> saveNameLanguage(NameLanguage language);
}
