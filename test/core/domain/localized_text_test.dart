import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/name_language.dart';

void main() {
  group('LocalizedText.resolve', () {
    test('returns ptBr when present and language is ptBr', () {
      const text = LocalizedText(en: 'Flying Wyvern', ptBr: 'Wyvern Voadora');
      expect(text.resolve(NameLanguage.ptBr), 'Wyvern Voadora');
    });

    test('falls back to en when ptBr is missing', () {
      const text = LocalizedText(en: 'Ancient Forest');
      expect(text.resolve(NameLanguage.ptBr), 'Ancient Forest');
    });

    test('returns en when language is en', () {
      const text = LocalizedText(en: 'Flying Wyvern', ptBr: 'Wyvern Voadora');
      expect(text.resolve(NameLanguage.en), 'Flying Wyvern');
    });
  });

  test('has value equality', () {
    expect(
      const LocalizedText(en: 'A', ptBr: 'B'),
      const LocalizedText(en: 'A', ptBr: 'B'),
    );
    expect(
      const LocalizedText(en: 'A', ptBr: 'B'),
      isNot(const LocalizedText(en: 'A')),
    );
  });

  group('LocalizedText.matches (US3)', () {
    test('matches the English or the pt-BR name', () {
      const text = LocalizedText(en: 'Flying Wyvern', ptBr: 'Wyvern Voadora');
      expect(text.matches('flying'), isTrue);
      expect(text.matches('voadora'), isTrue);
      expect(text.matches('temnoceran'), isFalse);
    });

    test('matches accents and case regardless of the query form', () {
      const text = LocalizedText(en: 'Dragon', ptBr: 'Dragão');
      expect(text.matches('dragao'), isTrue);
    });

    test('without pt-BR only English is searched', () {
      const text = LocalizedText(en: 'Arkveld');
      expect(text.matches('arkv'), isTrue);
    });

    test('an empty query matches everything', () {
      expect(const LocalizedText(en: 'Arkveld').matches(''), isTrue);
    });
  });
}
