import 'package:flutter/foundation.dart';
import 'package:mh_wiki/features/weapons/domain/entities/artian.dart';

/// The Artian opened in the simulator: a base, or one of the user's.
typedef ArtianSelection = ({String type, int rarity, String? myId});

/// The user's saved Artian and the one open in the simulator (010 US3).
final class ArtianController extends ChangeNotifier {
  ArtianController({required this._repository, this._clock = DateTime.now});

  final MyArtianRepository _repository;
  final DateTime Function() _clock;

  List<MyArtian> _mine = const [];
  bool _started = false;
  ArtianSelection? _selection;

  List<MyArtian> get mine => _mine;

  List<MyArtian> mineOf(String type) => [
    for (final a in _mine)
      if (a.build.type == type) a,
  ];

  ArtianSelection? get selection => _selection;

  MyArtian? get selectedMine {
    final id = _selection?.myId;
    return id == null ? null : _mine.where((a) => a.id == id).firstOrNull;
  }

  Future<void> ensureLoaded() async {
    if (_started) return;
    _started = true;
    _mine = await _repository.load();
    notifyListeners();
  }

  void open(String type, int rarity) {
    _selection = (type: type, rarity: rarity, myId: null);
    notifyListeners();
  }

  void openMine(MyArtian artian) {
    _selection = (
      type: artian.build.type,
      rarity: artian.build.rarity,
      myId: artian.id,
    );
    notifyListeners();
  }

  void close() {
    if (_selection == null) return;
    _selection = null;
    notifyListeners();
  }

  /// Saves [build] as a new Artian and opens it; `null` when the device
  /// refused.
  Future<MyArtian?> save(String name, ArtianBuild build) async {
    final artian = MyArtian(
      id: 'a${_clock().microsecondsSinceEpoch}',
      name: name,
      build: build,
    );
    if (!await _store([..._mine, artian])) return null;
    openMine(artian);
    return artian;
  }

  /// Replaces the build of a saved Artian.
  Future<bool> update(String id, ArtianBuild build) => _store([
    for (final a in _mine)
      a.id == id ? MyArtian(id: id, name: a.name, build: build) : a,
  ]);

  Future<bool> rename(String id, String name) =>
      _store([for (final a in _mine) a.id == id ? a.renamed(name) : a]);

  /// Deletes a saved Artian; the simulator goes back to its base.
  Future<bool> delete(String id) async {
    final ok = await _store([
      for (final a in _mine)
        if (a.id != id) a,
    ]);
    final s = _selection;
    if (ok && s != null && s.myId == id) {
      _selection = (type: s.type, rarity: s.rarity, myId: null);
      notifyListeners();
    }
    return ok;
  }

  Future<bool> _store(List<MyArtian> next) async {
    final ok = await _repository.store(next);
    if (ok) {
      _mine = List.unmodifiable(next);
      notifyListeners();
    }
    return ok;
  }
}
