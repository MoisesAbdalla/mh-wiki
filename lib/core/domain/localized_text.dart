import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/search_normalizer.dart';

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

  /// Whether the English or pt-BR name contains [query], ignoring case and
  /// accents, whatever language is displayed (FR-004, FR-023).
  bool matches(String query) {
    final needle = normalizeForSearch(query);
    if (needle.isEmpty) return true;
    return normalizeForSearch(en).contains(needle) ||
        (ptBr != null && normalizeForSearch(ptBr!).contains(needle));
  }

  @override
  bool operator ==(Object other) =>
      other is LocalizedText && other.en == en && other.ptBr == ptBr;

  @override
  int get hashCode => Object.hash(en, ptBr);

  @override
  String toString() => 'LocalizedText($en, $ptBr)';
}
