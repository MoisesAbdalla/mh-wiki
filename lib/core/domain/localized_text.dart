import 'package:mh_wiki/core/domain/name_language.dart';

/// Game content text with its official English and (optional) pt-BR names.
final class LocalizedText {
  const LocalizedText({required this.en, this.ptBr});

  final String en;

  /// `null` when the game has no official pt-BR translation.
  final String? ptBr;

  /// Falls back to English when there is no pt-BR name (FR-024).
  String resolve(NameLanguage language) => switch (language) {
    NameLanguage.ptBr => ptBr ?? en,
    NameLanguage.en => en,
  };

  @override
  bool operator ==(Object other) =>
      other is LocalizedText && other.en == en && other.ptBr == ptBr;

  @override
  int get hashCode => Object.hash(en, ptBr);

  @override
  String toString() => 'LocalizedText($en, $ptBr)';
}
