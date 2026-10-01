/// Quest stars from which a weapon is available; estimated from its materials
/// (006 research R3) and shown as such.
final class EstimatedStars {
  const EstimatedStars({required this.value, this.estimated = true});

  final int value;
  final bool estimated;
}
