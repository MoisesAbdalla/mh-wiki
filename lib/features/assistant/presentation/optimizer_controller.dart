import 'package:flutter/foundation.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/core/domain/search_normalizer.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_search.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_mapping.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_repositories.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';

/// What Montar build shows below the request (009 ui-contract).
sealed class OptimizerPhase {
  const OptimizerPhase();
}

/// Nothing searched yet, or the request changed since.
final class OptimizerIdle extends OptimizerPhase {
  const OptimizerIdle();
}

final class OptimizerSearching extends OptimizerPhase {
  const OptimizerSearching(this.checked);

  final int checked;
}

final class OptimizerResults extends OptimizerPhase {
  const OptimizerResults(this.sets);

  /// Ranked; empty when nothing came close.
  final List<BuildSet> sets;
}

/// Orchestrates Montar build: the catalog, the request, the talismans, the
/// search and its results. The progress, weapon type and saved builds are the
/// Assistente's ([assistant]).
final class OptimizerController extends ChangeNotifier {
  OptimizerController({
    required this.assistant,
    required this._loadCatalog,
    required this._talismanRepository,
    required this._requestRepository,
    required this._searcher,
    this.game = Game.riseSunbreak,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    assistant.addListener(_onAssistant);
  }

  final AssistantController assistant;
  final LoadOptimizerCatalog _loadCatalog;
  final TalismanRepository _talismanRepository;
  final RequestRepository _requestRepository;
  final BuildSearcher _searcher;
  final DateTime Function() _clock;
  final Game game;

  OptimizerCatalog? _catalog;
  Failure? _failure;
  bool _started = false;
  bool _loading = false;

  Map<String, int> _skills = {};
  String? _fixedWeaponId;
  bool _useTalismans = true;
  bool _onlyMyProgress = true;
  Map<String, WeaponFilter> _filters = {};
  List<UserTalisman> _talismans = const [];

  OptimizerPhase _phase = const OptimizerIdle();
  int? _selected;
  (Object, String)? _searchedFor;

  OptimizerCatalog? get catalog => _catalog;

  Failure? get failure => _failure;

  bool get loading => _loading;

  /// Skill id → wanted level, in the order chosen.
  Map<String, int> get skills => Map.unmodifiable(_skills);

  String? get fixedWeaponId => _fixedWeaponId;

  OptimizerWeapon? get fixedWeapon =>
      _fixedWeaponId == null ? null : _catalog?.weapons[_fixedWeaponId];

  bool get useTalismans => _useTalismans;

  bool get onlyMyProgress => _onlyMyProgress;

  List<UserTalisman> get talismans => _talismans;

  OptimizerPhase get phase => _phase;

  /// The result open in the detail, as an index into the results.
  int? get selected => _selected;

  BuildRequest get request => BuildRequest(
    skills: _skills,
    weaponType: assistant.weaponType,
    progress: assistant.progress,
    fixedWeaponId: _fixedWeaponId,
    useTalismans: _useTalismans,
    onlyMyProgress: _onlyMyProgress,
    // A fixed weapon decides for itself.
    weaponTrait: _fixedWeaponId == null ? weaponTrait : null,
    weaponElement: _fixedWeaponId == null ? weaponElement : null,
  );

  /// The phial or shelling kind required for the current weapon type.
  String? get weaponTrait => _filters[assistant.weaponType]?.trait;

  /// The element or status required for the current weapon type, or
  /// [BuildRequest.noElement].
  String? get weaponElement => _filters[assistant.weaponType]?.element;

  /// The phial or shelling kinds of the current type, most common first;
  /// empty for types without them.
  List<({String key, LocalizedText name})> get traitOptions {
    final counts = <String, ({String key, LocalizedText name})>{};
    final n = <String, int>{};
    for (final w
        in _catalog?.weaponsByType[assistant.weaponType] ??
            const <OptimizerWeapon>[]) {
      final t = w.trait;
      if (t == null) continue;
      counts[t.key] = t;
      n[t.key] = (n[t.key] ?? 0) + 1;
    }
    return counts.values.toList()..sort((a, b) => n[b.key]! - n[a.key]!);
  }

  /// The element and status kinds the current type has, in game order, plus
  /// [BuildRequest.noElement] when raw weapons exist.
  List<String> get elementOptions {
    final seen = <String>{};
    var raw = false;
    for (final w
        in _catalog?.weaponsByType[assistant.weaponType] ??
            const <OptimizerWeapon>[]) {
      if (w.elements.isEmpty) raw = true;
      seen.addAll(w.elements);
    }
    return [
      if (raw) BuildRequest.noElement,
      for (final k in elementOrder)
        if (seen.contains(k)) k,
    ];
  }

  static const elementOrder = [
    'fire', 'water', 'thunder', 'ice', 'dragon', //
    'poison', 'sleep', 'paralysis', 'blast',
  ];

  void setWeaponTrait(String? key) =>
      _setFilter((trait: key, element: weaponElement));

  void setWeaponElement(String? kind) =>
      _setFilter((trait: weaponTrait, element: kind));

  void _setFilter(WeaponFilter f) {
    final current = _filters[assistant.weaponType];
    if (current?.trait == f.trait && current?.element == f.element) return;
    _filters = {..._filters, assistant.weaponType: f};
    _changed();
  }

  /// How many weapons of the type pass the filters within the rarity limit;
  /// zero means the search cannot run.
  int get matchingWeaponCount {
    if (_fixedWeaponId != null) return 1;
    final r = request;
    return [
      for (final w
          in _catalog?.weaponsByType[assistant.weaponType] ??
              const <OptimizerWeapon>[])
        if (w.rarity <= r.maxRarity && r.allows(w)) w,
    ].length;
  }

  int get maxRarity => request.maxRarity;

  @override
  void dispose() {
    assistant.removeListener(_onAssistant);
    _searcher.cancel();
    super.dispose();
  }

  /// A new progress or weapon type makes old results stale (spec edge case).
  void _onAssistant() {
    final key = (assistant.progress, assistant.weaponType);
    if (_searchedFor != null && _searchedFor != key) {
      _searchedFor = null;
      final weapon = fixedWeapon;
      if (weapon != null && weapon.type != assistant.weaponType) {
        _fixedWeaponId = null;
        _store();
      }
      _reset();
    }
  }

  /// Loads on the first visit only.
  Future<void> ensureLoaded() async {
    if (_started) return;
    await load();
  }

  Future<void> load() async {
    _started = true;
    _loading = true;
    _failure = null;
    notifyListeners();
    final stored = await _requestRepository.load();
    _skills = {...stored.skills};
    _fixedWeaponId = stored.fixedWeaponId;
    _useTalismans = stored.useTalismans;
    _onlyMyProgress = stored.onlyMyProgress;
    _filters = {...stored.weaponFilters};
    _talismans = await _talismanRepository.load();
    switch (await _loadCatalog(game)) {
      case Success(:final value):
        _catalog = value;
        _skills.removeWhere((id, _) => !value.skills.containsKey(id));
      case Err(:final failure):
        _failure = failure;
    }
    _loading = false;
    notifyListeners();
  }

  // ------------------------------------------------------------ request

  /// Skills whose name (pt-BR or English, without accents) contains [text].
  List<OptimizerSkill> matchingSkills(String text) {
    final q = normalizeForSearch(text);
    final all = _catalog?.skills.values ?? const <OptimizerSkill>[];
    if (q.isEmpty) return const [];
    return [
      for (final s in all)
        if (!_skills.containsKey(s.id) &&
            (normalizeForSearch(s.name.en).contains(q) ||
                normalizeForSearch(s.name.ptBr ?? '').contains(q)))
          s,
    ]..sort(
      (a, b) => a.name
          .resolve(assistant.language)
          .compareTo(b.name.resolve(assistant.language)),
    );
  }

  /// The skills most used by curated builds of the type (research R5).
  List<OptimizerSkill> get suggestions {
    final c = _catalog;
    if (c == null) return const [];
    return [
      for (final id in suggestSkills(
        assistant.curatedBuilds,
        assistant.weaponType,
        assistant.progress,
        chosen: _skills.keys,
      ))
        ?c.skills[id],
    ];
  }

  /// The most skills one request can hold (research R8).
  static const maxSkills = 10;

  bool get canAddSkill => _skills.length < maxSkills;

  void addSkill(String id) {
    final skill = _catalog?.skills[id];
    if (skill == null || _skills.containsKey(id) || !canAddSkill) return;
    _skills = {..._skills, id: skill.max};
    _changed();
  }

  void setLevel(String id, int level) {
    final skill = _catalog?.skills[id];
    if (skill == null || !_skills.containsKey(id)) return;
    final clamped = level.clamp(1, skill.max);
    if (clamped == _skills[id]) return;
    _skills = {..._skills, id: clamped};
    _changed();
  }

  void removeSkill(String id) {
    if (!_skills.containsKey(id)) return;
    _skills = {..._skills}..remove(id);
    _changed();
  }

  void setUseTalismans(bool value) {
    if (value == _useTalismans) return;
    _useTalismans = value;
    _changed();
  }

  void setOnlyMyProgress(bool value) {
    if (value == _onlyMyProgress) return;
    _onlyMyProgress = value;
    _changed();
  }

  /// Weapons of the chosen type within the rarity limit whose name contains
  /// [text], strongest first.
  List<OptimizerWeapon> weaponsMatching(String text) {
    final q = normalizeForSearch(text);
    final all = _catalog?.weaponsByType[assistant.weaponType] ?? const [];
    return [
      for (final w in all)
        if (w.rarity <= maxRarity &&
            (q.isEmpty ||
                normalizeForSearch(w.name.en).contains(q) ||
                normalizeForSearch(w.name.ptBr ?? '').contains(q)))
          w,
    ]..sort(
      (a, b) =>
          b.rarity != a.rarity ? b.rarity - a.rarity : b.attack - a.attack,
    );
  }

  void setFixedWeapon(String? id) {
    if (id == _fixedWeaponId) return;
    _fixedWeaponId = id;
    _changed();
  }

  void _changed() {
    _store();
    _reset();
  }

  void _store() => _requestRepository.store((
    skills: _skills,
    fixedWeaponId: _fixedWeaponId,
    useTalismans: _useTalismans,
    onlyMyProgress: _onlyMyProgress,
    weaponFilters: _filters,
  ));

  void _reset() {
    if (_phase is OptimizerSearching) _searcher.cancel();
    _phase = const OptimizerIdle();
    _selected = null;
    notifyListeners();
  }

  // ------------------------------------------------------------- search

  Future<void> build() async {
    final c = _catalog;
    if (c == null ||
        _skills.isEmpty ||
        _phase is OptimizerSearching ||
        matchingWeaponCount == 0) {
      return;
    }
    final key = (assistant.progress, assistant.weaponType);
    _phase = const OptimizerSearching(0);
    _selected = null;
    notifyListeners();
    final sets = await _searcher.search(
      c,
      request,
      _talismans,
      onProgress: (n) {
        if (_phase is OptimizerSearching) {
          _phase = OptimizerSearching(n);
          notifyListeners();
        }
      },
    );
    if (_phase is! OptimizerSearching) return;
    if (sets == null) {
      _phase = const OptimizerIdle();
    } else {
      _phase = OptimizerResults(sets);
      _searchedFor = key;
    }
    notifyListeners();
  }

  void cancel() {
    if (_phase is! OptimizerSearching) return;
    _searcher.cancel();
    _phase = const OptimizerIdle();
    notifyListeners();
  }

  /// Back to the request, keeping it (the results go).
  void editRequest() => _reset();

  void select(int? index) {
    final phase = _phase;
    if (phase is! OptimizerResults) return;
    if (index != null && (index < 0 || index >= phase.sets.length)) return;
    _selected = index;
    notifyListeners();
  }

  /// The result [index] as a build for the detail and Minhas builds.
  CuratedBuild? curatedOf(
    int index, {
    required String name,
    required String stageLabel,
    required String sourceName,
  }) {
    final phase = _phase;
    final c = _catalog;
    if (phase is! OptimizerResults || c == null || index >= phase.sets.length) {
      return null;
    }
    return buildSetToCurated(
      phase.sets[index],
      c,
      id: 'optimizer-${_clock().microsecondsSinceEpoch}-$index',
      name: name,
      weaponType: assistant.weaponType,
      stage: assistant.progress,
      stageLabel: stageLabel,
      sourceName: sourceName,
      wanted: _skills,
    );
  }

  // ---------------------------------------------------------- talismans

  /// Adds [talisman], or replaces the one with its id.
  Future<bool> saveTalisman(UserTalisman talisman) {
    final exists = _talismans.any((t) => t.id == talisman.id);
    return _writeTalismans([
      if (exists)
        for (final t in _talismans) t.id == talisman.id ? talisman : t
      else ...[..._talismans, talisman],
    ]);
  }

  Future<bool> deleteTalisman(String id) => _writeTalismans([
    for (final t in _talismans)
      if (t.id != id) t,
  ]);

  /// An id for a new talisman.
  String newTalismanId() => 't${_clock().microsecondsSinceEpoch}';

  Future<bool> _writeTalismans(List<UserTalisman> list) async {
    final ok = await _talismanRepository.store(list);
    if (ok) {
      _talismans = list;
      _reset();
    }
    return ok;
  }
}
