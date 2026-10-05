import 'package:mh_wiki/features/assistant/domain/entities/progress.dart';

/// A talisman the user owns (009 US3): up to two skills and three slots.
final class UserTalisman {
  UserTalisman({
    required this.id,
    required this.skills,
    required List<int> slots,
  }) : assert(skills.length <= 2),
       slots = ([...slots]..sort((a, b) => b - a));

  final String id;

  /// Skill id → level, in the order the user entered them.
  final Map<String, int> skills;

  /// Three slot levels 0–4, highest first.
  final List<int> slots;

  UserTalisman copyWith({Map<String, int>? skills, List<int>? slots}) =>
      UserTalisman(
        id: id,
        skills: skills ?? this.skills,
        slots: slots ?? this.slots,
      );
}

/// What the hunter asks Montar build for (009 data-model).
final class BuildRequest {
  const BuildRequest({
    required this.skills,
    required this.weaponType,
    required this.progress,
    this.fixedWeaponId,
    this.useTalismans = true,
    this.onlyMyProgress = true,
  });

  /// Skill id → wanted level, in the order chosen.
  final Map<String, int> skills;
  final String weaponType;
  final Progress progress;
  final String? fixedWeaponId;
  final bool useTalismans;
  final bool onlyMyProgress;

  /// The highest rarity of the pieces and weapons searched.
  int get maxRarity => onlyMyProgress ? maxRarityFor(progress) : 10;
}

/// The highest piece and weapon rarity available at [p] (009 research R3).
int maxRarityFor(Progress p) => switch (p.rank) {
  ProgressRank.low => 3,
  ProgressRank.high => switch (p.step) {
    '4' => 5,
    '5' => 6,
    _ => 7,
  },
  ProgressRank.master => switch (p.step) {
    'M1' || 'M2' => 8,
    'M3' || 'M4' => 9,
    _ => 10,
  },
  ProgressRank.post => 10,
};
