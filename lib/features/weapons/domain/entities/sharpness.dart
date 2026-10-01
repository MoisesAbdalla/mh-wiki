/// Sharpness of a melee weapon in game units (hits × 10), seven segments
/// from red to purple, without and with max Handicraft (006 research R5).
final class Sharpness {
  const Sharpness({required this.base, required this.handicraft});

  /// Scale used to draw every bar, so weapons compare visually.
  static const maxUnits = 400;

  final List<int> base;
  final List<int> handicraft;
}
