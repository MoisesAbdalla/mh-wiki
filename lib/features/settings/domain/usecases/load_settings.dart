import 'package:mh_wiki/features/settings/domain/app_settings.dart';
import 'package:mh_wiki/features/settings/domain/settings_repository.dart';

final class LoadSettings {
  const LoadSettings(this._repository);

  final SettingsRepository _repository;

  Future<AppSettings> call() => _repository.load();
}
