/// A monster that drops a material, as the app layer knows it. The weapons
/// feature never imports monsters (006 research R7): [id] is opaque here and
/// only handed back through `onOpenMonster`.
final class MaterialDropper {
  const MaterialDropper({required this.id, required this.name});

  final Object id;
  final String name;

  @override
  bool operator ==(Object other) => other is MaterialDropper && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Material id → the monsters that drop it ("Dropado por", 006 FR-009).
class MaterialSourceLookup {
  const MaterialSourceLookup(this._droppersOf);

  /// No known sources: materials show without a link.
  static const empty = MaterialSourceLookup(_none);

  final List<MaterialDropper> Function(String materialId) _droppersOf;

  List<MaterialDropper> droppersOf(String materialId) =>
      _droppersOf(materialId);

  static List<MaterialDropper> _none(String _) => const [];
}
