import 'package:flutter_test/flutter_test.dart';
import 'package:mh_wiki/core/domain/search_normalizer.dart';

void main() {
  test('lowercases', () {
    expect(normalizeForSearch('RATHALOS'), 'rathalos');
  });

  test('folds Portuguese and common Latin diacritics', () {
    expect(
      normalizeForSearch('áàâãä éèêë íìîï óòôõö úùûü çñ'),
      'aaaaa eeee iiii ooooo uuuu cn',
    );
    expect(normalizeForSearch('ÁÀÂÃÄ ÉÊ Í ÓÔÕ ÚÜ ÇÑ'), 'aaaaa ee i ooo uu cn');
    expect(normalizeForSearch('Dragão Água'), 'dragao agua');
  });

  test('trims surrounding whitespace', () {
    expect(normalizeForSearch('  rath  '), 'rath');
  });

  test('empty stays empty', () {
    expect(normalizeForSearch(''), '');
    expect(normalizeForSearch('   '), '');
  });
}
