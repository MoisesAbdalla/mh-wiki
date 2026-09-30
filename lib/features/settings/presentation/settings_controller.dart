import 'package:flutter/foundation.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/settings/domain/app_settings.dart';
import 'package:mh_wiki/features/settings/domain/usecases/load_settings.dart';
import 'package:mh_wiki/features/settings/domain/usecases/set_name_language.dart';

/// Exposes [AppSettings]; changes apply immediately and are persisted in the
/// background (FR-022). Receives use cases only (Principle II).
final class SettingsController extends ChangeNotifier {
  SettingsController({
    required this._loadSettings,
    required this._setNameLanguage,
  });

  final LoadSettings _loadSettings;
  final SetNameLanguage _setNameLanguage;

  AppSettings _settings = const AppSettings();
  bool _saveFailed = false;

  AppSettings get settings => _settings;

  /// True after a save failed; the choice still applies for this session.
  bool get saveFailed => _saveFailed;

  Future<void> load() async {
    _settings = await _loadSettings();
    notifyListeners();
  }

  Future<void> setNameLanguage(NameLanguage language) async {
    if (language == _settings.nameLanguage) return;
    _settings = _settings.copyWith(nameLanguage: language);
    notifyListeners();

    final result = await _setNameLanguage(language);
    if (result is Err) {
      _saveFailed = true;
      notifyListeners();
    }
  }

  void acknowledgeSaveFailure() {
    if (!_saveFailed) return;
    _saveFailed = false;
    notifyListeners();
  }
}
