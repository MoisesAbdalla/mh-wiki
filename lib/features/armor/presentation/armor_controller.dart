import 'package:flutter/foundation.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/core/domain/search_normalizer.dart';
import 'package:mh_wiki/features/armor/domain/entities/armor_catalog.dart';
import 'package:mh_wiki/features/armor/domain/entities/skill.dart';
import 'package:mh_wiki/features/armor/domain/usecases/armor_queries.dart';
import 'package:mh_wiki/features/armor/domain/usecases/load_armor_catalog.dart';

/// The three tabs of the Armaduras area (007 FR-001).
enum ArmorTab { sets, skills, decorations }

/// What is open in the detail: a set, a skill or a decoration.
typedef ArmorSelection = ({ArmorTab kind, String id});

/// Screen state of the Armaduras area (the "Model" in MVC).
sealed class ArmorState {
  const ArmorState();
}

final class ArmorLoading extends ArmorState {
  const ArmorLoading();
}

final class ArmorFailed extends ArmorState {
  const ArmorFailed(this.failure);

  final Failure failure;
}

final class ArmorLoaded extends ArmorState {
  const ArmorLoaded({
    required this.catalog,
    required this.tab,
    required this.setQuery,
    required this.sets,
    required this.skillText,
    required this.skills,
    required this.decorationText,
    required this.decorationSlot,
    required this.decorations,
    this.selection,
  });

  final ArmorCatalog catalog;
  final ArmorTab tab;
  final SetQuery setQuery;
  final List<ArmorSet> sets;
  final String skillText;
  final List<Skill> skills;
  final String decorationText;

  /// `null` = every slot level.
  final int? decorationSlot;
  final List<ArmorDecoration> decorations;
  final ArmorSelection? selection;
}

/// Orchestrates the Armaduras area: tabs, per-tab filters and selection,
/// kept across area switches (007 FR-012).
final class ArmorController extends ChangeNotifier {
  ArmorController({
    required this._loadCatalog,
    this.game = Game.riseSunbreak,
    this._language = NameLanguage.ptBr,
  });

  final LoadArmorCatalog _loadCatalog;
  final Game game;
  NameLanguage _language;

  ArmorState _state = const ArmorLoading();
  ArmorCatalog? _catalog;
  FilterSets? _filter;
  bool _started = false;

  ArmorTab _tab = ArmorTab.sets;
  SetQuery _setQuery = const SetQuery();
  String _skillText = '';
  String _decorationText = '';
  int? _decorationSlot;
  ArmorSelection? _selection;

  ArmorState get state => _state;

  ArmorCatalog? get catalog => _catalog;

  NameLanguage get language => _language;

  ArmorSelection? get selection => _selection;

  /// Skills matching the set search, offered as filter seals.
  List<Skill> get skillSuggestions => _setQuery.skillId != null
      ? const []
      : _filter?.matchingSkills(_setQuery.text) ?? const [];

  void onLanguageChanged(NameLanguage language) {
    if (language == _language) return;
    _language = language;
    notifyListeners();
  }

  /// Loads on the first visit only.
  Future<void> ensureLoaded() async {
    if (_started) return;
    await load();
  }

  Future<void> load() async {
    _started = true;
    _state = const ArmorLoading();
    notifyListeners();
    switch (await _loadCatalog(game)) {
      case Success(:final value):
        _catalog = value;
        _filter = FilterSets(value);
        _emit();
      case Err(:final failure):
        _state = ArmorFailed(failure);
        notifyListeners();
    }
  }

  void setTab(ArmorTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    _emit();
  }

  void setRank(Rank? rank) =>
      _update(() => _setQuery = _setQuery.copyWith(rank: () => rank));

  void setSetText(String text) {
    if (text == _setQuery.text) return;
    _update(() => _setQuery = _setQuery.copyWith(text: text));
  }

  /// Filters the sets by a skill and turns it into a removable seal.
  void chooseSkill(String skillId) => _update(
    () => _setQuery = _setQuery.copyWith(text: '', skillId: () => skillId),
  );

  void clearSkill() =>
      _update(() => _setQuery = _setQuery.copyWith(skillId: () => null));

  void clearSetFilters() => _update(() => _setQuery = const SetQuery());

  void setSkillText(String text) {
    if (text == _skillText) return;
    _update(() => _skillText = text);
  }

  void setDecorationText(String text) {
    if (text == _decorationText) return;
    _update(() => _decorationText = text);
  }

  void setDecorationSlot(int? slot) => _update(() => _decorationSlot = slot);

  /// Opens a set, skill or decoration, switching to its tab.
  Future<void> select(ArmorTab kind, String id) async {
    await ensureLoaded();
    _selection = (kind: kind, id: id);
    _tab = kind;
    _emit();
  }

  void clearSelection() {
    if (_selection == null) return;
    _selection = null;
    _emit();
  }

  ArmorSet? get selectedSet => switch (_selection) {
    (kind: ArmorTab.sets, :final id) => _catalog?.set(id),
    _ => null,
  };

  Skill? get selectedSkill => switch (_selection) {
    (kind: ArmorTab.skills, :final id) => _catalog?.skill(id),
    _ => null,
  };

  ArmorDecoration? get selectedDecoration => switch (_selection) {
    (kind: ArmorTab.decorations, :final id) =>
      _catalog?.decorations.where((d) => d.id == id).firstOrNull,
    _ => null,
  };

  void _update(void Function() change) {
    change();
    _emit();
  }

  void _emit() {
    final catalog = _catalog;
    final filter = _filter;
    if (catalog == null || filter == null) return;
    final skillNeedle = normalizeForSearch(_skillText);
    final decoNeedle = normalizeForSearch(_decorationText);
    bool matches(String needle, String en, String? pt) =>
        needle.isEmpty ||
        normalizeForSearch(en).contains(needle) ||
        normalizeForSearch(pt ?? '').contains(needle);
    _state = ArmorLoaded(
      catalog: catalog,
      tab: _tab,
      setQuery: _setQuery,
      sets: filter(_setQuery),
      skillText: _skillText,
      skills:
          [
            for (final s in catalog.skills)
              if (matches(skillNeedle, s.name.en, s.name.ptBr)) s,
          ]..sort(
            (a, b) =>
                a.name.resolve(_language).compareTo(b.name.resolve(_language)),
          ),
      decorationText: _decorationText,
      decorationSlot: _decorationSlot,
      decorations: [
        for (final d in catalog.decorations)
          if ((_decorationSlot == null || d.slotLevel == _decorationSlot) &&
              (matches(decoNeedle, d.name.en, d.name.ptBr) ||
                  d.skills.any((s) {
                    final skill = catalog.skill(s.skillId);
                    return skill != null &&
                        matches(decoNeedle, skill.name.en, skill.name.ptBr);
                  })))
            d,
      ],
      selection: _selection,
    );
    notifyListeners();
  }
}
