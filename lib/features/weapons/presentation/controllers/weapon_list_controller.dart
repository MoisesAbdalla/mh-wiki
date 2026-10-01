import 'package:flutter/foundation.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_query.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/filter_weapons.dart';
import 'package:mh_wiki/features/weapons/domain/usecases/load_weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/presentation/models/weapon_list_state.dart';

/// Orchestrates the weapon list use cases and exposes [WeaponListState].
///
/// Holds the query and selection, so they survive area switches and reloads.
final class WeaponListController extends ChangeNotifier {
  WeaponListController({
    required this._loadCatalog,
    this._filterFor = FilterWeapons.new,
    this.game = Game.riseSunbreak,
    this._language = NameLanguage.ptBr,
  });

  final LoadWeaponCatalog _loadCatalog;
  final FilterWeapons Function(WeaponCatalog) _filterFor;

  /// Only Rise: Sunbreak has weapons in 006.
  final Game game;

  WeaponListState _state = const WeaponListLoading();
  FilterWeapons? _filter;
  WeaponQuery? _query;
  WeaponId? _selectedId;
  bool _started = false;
  NameLanguage _language;

  WeaponListState get state => _state;

  /// Names shown in the chosen language, as in Monstros (FR-004).
  NameLanguage get language => _language;

  void onLanguageChanged(NameLanguage language) {
    if (language == _language) return;
    _language = language;
    notifyListeners();
  }

  WeaponCatalog? get catalog => _filter?.catalog;

  Weapon? get selectedWeapon {
    final id = _selectedId;
    return id == null ? null : catalog?.byId(id);
  }

  /// Loads on the first visit only (the Armas area is opened lazily).
  Future<void> ensureLoaded() async {
    if (_started) return;
    await load();
  }

  Future<void> load() async {
    _started = true;
    _state = const WeaponListLoading();
    notifyListeners();

    switch (await _loadCatalog(game)) {
      case Success(:final value):
        _filter = _filterFor(value);
        // The first type is selected on first open; a kept query survives.
        _query ??= WeaponQuery(typeId: value.types.first.id);
        _emit();
      case Err(:final failure):
        _state = WeaponListFailed(failure);
        notifyListeners();
    }
  }

  void setType(String typeId) => _update(
    (q) =>
        q.copyWith(typeId: typeId, onlyIds: () => null, onlyLabel: () => null),
  );

  /// `null` means "Todos".
  void setRank(Rank? rank) => _update((q) => q.copyWith(rank: () => rank));

  void setSearchText(String text) {
    if (text == _query?.text) return;
    _update((q) => q.copyWith(text: text));
  }

  /// Keeps the type; drops rank, search and the "only these" filter.
  void clearFilters() => _update((q) => WeaponQuery(typeId: q.typeId));

  /// Shows only [ids] ("Ver todas" from a monster, FR-010) under a chip.
  Future<void> showOnly(Set<WeaponId> ids, String label) async {
    await ensureLoaded();
    _update(
      (q) => q.copyWith(
        rank: () => null,
        text: '',
        onlyIds: () => ids,
        onlyLabel: () => label,
      ),
    );
  }

  void clearOnly() =>
      _update((q) => q.copyWith(onlyIds: () => null, onlyLabel: () => null));

  /// Opens [id], switching to its type when needed so the row is visible.
  Future<void> select(WeaponId id) async {
    await ensureLoaded();
    final weapon = catalog?.byId(id);
    if (weapon == null) return;
    _selectedId = id;
    final q = _query;
    if (q != null && q.onlyIds == null && q.typeId != weapon.type.id) {
      _query = WeaponQuery(typeId: weapon.type.id);
    }
    _emit();
  }

  void clearSelection() {
    if (_selectedId == null) return;
    _selectedId = null;
    _emit();
  }

  void _update(WeaponQuery Function(WeaponQuery) change) {
    final q = _query;
    if (q == null) return;
    _query = change(q);
    _emit();
  }

  void _emit() {
    final filter = _filter;
    final query = _query;
    if (filter == null || query == null) return;
    _state = WeaponListLoaded(
      catalog: filter.catalog,
      query: query,
      trees: filter(query),
      selectedId: _selectedId,
    );
    notifyListeners();
  }
}
