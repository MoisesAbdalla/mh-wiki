import 'package:mh_wiki/core/domain/name_language.dart';

final class AppSettings {
  const AppSettings({this.nameLanguage = NameLanguage.ptBr});

  /// How game names are displayed (FR-021); pt-BR by default.
  final NameLanguage nameLanguage;

  AppSettings copyWith({NameLanguage? nameLanguage}) =>
      AppSettings(nameLanguage: nameLanguage ?? this.nameLanguage);
}
