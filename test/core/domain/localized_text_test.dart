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
}
