/// The ranks of the progress picker, in order (008 research R3).
enum ProgressRank { low, high, master, post }

/// Where the hunter is in the game: a rank and a step in it (a quest star,
/// or a post-game Master Rank band). Ordered: Baixo 1–3★ < Alto 4–7★ <
/// Mestre M1–M6★ < Pós-jogo MR 10+ … 180+.
final class Progress implements Comparable<Progress> {
  const Progress(this.rank, this.step);

  /// Reads a dataset or saved value ("master", "M2").
  factory Progress.parse(String rank, String step) {
    final r = ProgressRank.values.byName(rank);
    if (!stepsOf(r).contains(step)) {
      throw FormatException('step "$step" does not fit rank "$rank"');
    }
    return Progress(r, step);
  }

  static const first = Progress(ProgressRank.low, '1');

  final ProgressRank rank;
  final String step;

  /// The steps the picker offers for [rank].
  static List<String> stepsOf(ProgressRank rank) => switch (rank) {
    ProgressRank.low => const ['1', '2', '3'],
    ProgressRank.high => const ['4', '5', '6', '7'],
    ProgressRank.master => const ['M1', 'M2', 'M3', 'M4', 'M5', 'M6'],
    ProgressRank.post => const ['10', '50', '100', '140', '180'],
  };

  int get _index {
    var offset = 0;
    for (final r in ProgressRank.values) {
      if (r == rank) return offset + stepsOf(r).indexOf(step);
      offset += stepsOf(r).length;
    }
    return offset;
  }

  @override
  int compareTo(Progress other) => _index.compareTo(other._index);

  bool operator <=(Progress other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      other is Progress && other.rank == rank && other.step == step;

  @override
  int get hashCode => Object.hash(rank, step);

  @override
  String toString() => 'Progress(${rank.name} $step)';
}
