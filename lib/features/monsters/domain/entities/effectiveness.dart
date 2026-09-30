/// Effectiveness of an element against a monster, ordered from least to most
/// effective. [immune] is distinct from [none] (0 stars).
enum Effectiveness {
  immune,
  none,
  low,
  medium,
  high;

  /// Star count shown in the UI (0–3). Immune also has 0 stars but is
  /// rendered with its own badge.
  int get stars => switch (this) {
    immune || none => 0,
    low => 1,
    medium => 2,
    high => 3,
  };
}
