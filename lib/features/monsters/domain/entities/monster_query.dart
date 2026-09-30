import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';

/// List filter: [game] `null` means "Todos".
final class MonsterQuery {
  const MonsterQuery({
    this.game,
    this.text = '',
    this.language = NameLanguage.ptBr,
  });

  final Game? game;
  final String text;
  final NameLanguage language;

  bool get hasActiveFilters => game != null || text.trim().isNotEmpty;

  /// [game] is wrapped in a function so it can be reset to `null` ("Todos").
  MonsterQuery copyWith({
    Game? Function()? game,
    String? text,
    NameLanguage? language,
  }) => MonsterQuery(
    game: game != null ? game() : this.game,
    text: text ?? this.text,
    language: language ?? this.language,
  );
}
