import 'package:flutter/foundation.dart';
import 'package:mh_wiki/core/domain/failure.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/result.dart';
import 'package:mh_wiki/features/assistant/domain/assistant_domain.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';

/// The tabs of the Assistente (008 FR-001); [build] stays disabled until 009.
enum AssistantTab { recommended, saved, build }

/// Screen state of the Assistente (the "Model" in MVC).
sealed class AssistantState {
  const AssistantState();
}

final class AssistantLoading extends AssistantState {
  const AssistantLoading();
}

final class AssistantFailed extends AssistantState {
  const AssistantFailed(this.failure);

  final Failure failure;
}

final class AssistantLoaded extends AssistantState {
  const AssistantLoaded({required this.now, required this.next});

  /// Builds for the chosen progress and earlier, latest first.
  final List<CuratedBuild> now;

  /// Builds of later stages, nearest first.
  final List<CuratedBuild> next;
}

/// What the detail shows: a curated build, or a saved copy of one.
typedef AssistantSelection = ({CuratedBuild build, SavedBuild? saved});

/// Orchestrates the Assistente: progress, weapon type, lists, selection and
/// the saved builds, kept across area switches.
final class AssistantController extends ChangeNotifier {
  AssistantController({
    required this._loadCatalog,
    required this._saved,
    required this._prefs,
    this.game = Game.riseSunbreak,
    this._language = NameLanguage.ptBr,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const defaultWeaponType = 'great-sword';

  final LoadBuildCatalog _loadCatalog;
  final SavedBuildsRepository _saved;
  final AssistantPrefsRepository _prefs;
  final DateTime Function() _clock;
  final Game game;
  NameLanguage _language;

  AssistantState _state = const AssistantLoading();
  BuildCatalog? _catalog;
  bool _started = false;

  AssistantTab _tab = AssistantTab.recommended;
  Progress _progress = Progress.first;
  String _weaponType = defaultWeaponType;
  List<SavedBuild> _savedBuilds = const [];
  AssistantSelection? _selection;

  AssistantState get state => _state;

  /// Every curated build, once loaded (Montar build's suggestions).
  List<CuratedBuild> get curatedBuilds => _catalog?.builds ?? const [];

  AssistantTab get tab => _tab;

  Progress get progress => _progress;

  String get weaponType => _weaponType;

  NameLanguage get language => _language;

  /// Newest first.
  List<SavedBuild> get savedBuilds => _savedBuilds;

  AssistantSelection? get selection => _selection;

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
    _state = const AssistantLoading();
    notifyListeners();
    final prefs = await _prefs.load();
    _progress = prefs.progress;
    _weaponType = prefs.weaponType ?? defaultWeaponType;
    _savedBuilds = await _saved.load();
    switch (await _loadCatalog(game)) {
      case Success(:final value):
        _catalog = value;
        _emit();
      case Err(:final failure):
        _state = AssistantFailed(failure);
        notifyListeners();
    }
  }

  void _emit() {
    final catalog = _catalog;
    if (catalog == null) return;
    final split = splitBuilds(catalog.builds, _progress, _weaponType);
    _state = AssistantLoaded(now: split.now, next: split.next);
    notifyListeners();
  }

  void selectTab(AssistantTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    _selection = null;
    notifyListeners();
  }

  void setProgress(Progress progress) {
    if (progress == _progress) return;
    _progress = progress;
    _store();
    _emit();
  }

  void setWeaponType(String type) {
    if (type == _weaponType) return;
    _weaponType = type;
    _selection = null;
    _store();
    _emit();
  }

  void _store() => _prefs.store((progress: _progress, weaponType: _weaponType));

  void select(CuratedBuild build) {
    _selection = (build: build, saved: null);
    notifyListeners();
  }

  void selectSaved(SavedBuild saved) {
    _selection = (build: saved.build, saved: saved);
    notifyListeners();
  }

  void clearSelection() {
    if (_selection == null) return;
    _selection = null;
    notifyListeners();
  }

  /// Keeps a copy of [build] in Minhas builds; `false` when the device
  /// refused it.
  Future<bool> save(CuratedBuild build) async {
    final now = _clock();
    final saved = SavedBuild(
      id: '${now.microsecondsSinceEpoch}',
      name: build.name,
      savedAt: now,
      build: build,
    );
    return _write([saved, ..._savedBuilds]);
  }

  Future<bool> rename(SavedBuild saved, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return Future.value(false);
    final renamed = saved.renamed(trimmed);
    if (_selection?.saved?.id == saved.id) {
      _selection = (build: renamed.build, saved: renamed);
    }
    return _write([
      for (final s in _savedBuilds) s.id == saved.id ? renamed : s,
    ]);
  }

  Future<bool> delete(SavedBuild saved) {
    if (_selection?.saved?.id == saved.id) _selection = null;
    return _write([
      for (final s in _savedBuilds)
        if (s.id != saved.id) s,
    ]);
  }

  Future<bool> _write(List<SavedBuild> builds) async {
    final ok = await _saved.store(builds);
    if (ok) _savedBuilds = builds;
    notifyListeners();
    return ok;
  }
}
