import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/settings/domain/settings_repository.dart';

final class SetNameLanguage {
  const SetNameLanguage(this._repository);

  final SettingsRepository _repository;

  Future<Result<void>> call(NameLanguage language) =>
      _repository.saveNameLanguage(language);
}
