import 'package:flutter/foundation.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_query.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/filter_monsters.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/get_monster_by_id.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/get_monster_versions.dart';
import 'package:mh_wiki/features/monsters/domain/usecases/load_monster_catalog.dart';
import 'package:mh_wiki/features/monsters/presentation/models/monster_list_state.dart';

/// Orchestrates the monster list use cases and exposes [MonsterListState].
///
/// Holds the selection too, so layouts can switch without losing it (FR-020).
/// Receives use cases only — never repositories (constitution Principle II).
final class MonsterListController extends ChangeNotifier {
  MonsterListController({
    required this._loadCatalog,
    required this._filterMonsters,
    required this._getMonsterById,
    required this._getMonsterVersions,
    NameLanguage language = NameLanguage.ptBr,
  }) : _query = MonsterQuery(language: language);

  final LoadMonsterCatalog _loadCatalog;
  final FilterMonsters _filterMonsters;
  final GetMonsterById _getMonsterById;
  final GetMonsterVersions _getMonsterVersions;

  MonsterListState _state = const MonsterListLoading();
  List<Monster> _monsters = const [];
  Map<Game, Failure> _failedGames = const {};
  MonsterQuery _query;
  MonsterId? _selectedId;

  MonsterListState get state => _state;

  MonsterQuery get query => _query;

  NameLanguage get language => _query.language;

  Monster? get selectedMonster {
    final id = _selectedId;
    if (id == null) return null;
    return switch (_getMonsterById(_monsters, id)) {
      Success(:final value) => value,
      Err() => null,
    };
  }

  /// The selected monster's base followed by its versions, for the detail's
  /// version selector (004 FR-006a); empty when nothing is selected.
  List<Monster> get selectedVersions {
    final id = _selectedId;
    if (id == null) return const [];
    return switch (_getMonsterVersions(_monsters, id)) {
      Success(:final value) => value,
      Err() => const [],
    };
  }

  Future<void> load() async {
    _state = const MonsterListLoading();
    notifyListeners();

    final catalog = await _loadCatalog();
    _monsters = catalog.monsters;
    _failedGames = catalog.failedGames;

    if (_monsters.isEmpty && _failedGames.isNotEmpty) {
      _state = MonsterListLoadFailed(_failedGames.values.first);
      notifyListeners();
      return;
    }
    _emit();
  }

  /// `null` means "Todos" (FR-003).
  void setGame(Game? game) {
    _query = _query.copyWith(game: () => game);
    _emit();
  }

  /// Called on every keystroke (FR-005).
  void setSearchText(String text) {
    if (text == _query.text) return;
    _query = _query.copyWith(text: text);
    _emit();
  }

  void clearFilters() {
    _query = MonsterQuery(language: _query.language);
    _emit();
  }

  /// Re-sorts names in the new language keeping filters and selection
  /// (FR-022, FR-025).
  void onLanguageChanged(NameLanguage language) {
    if (language == _query.language) return;
    _query = _query.copyWith(language: language);
    _emit();
  }

  void select(MonsterId id) {
    _selectedId = id;
    _emit();
  }

  void clearSelection() {
    if (_selectedId == null) return;
    _selectedId = null;
    _emit();
  }

  void _emit() {
    if (_state is MonsterListLoadFailed) return;
    _state = MonsterListLoaded(
      sections: _filterMonsters(_monsters, _query),
      query: _query,
      failedGames: _failedGames,
      selectedId: _selectedId,
    );
    notifyListeners();
  }
}
