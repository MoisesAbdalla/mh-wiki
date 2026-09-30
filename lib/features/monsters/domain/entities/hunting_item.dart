import 'package:mh_wiki/core/domain/localized_text.dart';

/// A hunting item of a game (Flash Pod, Sonic Bomb, Pitfall Trap…).
/// Ids are shared across games: flash, sonic, dung, pitfallTrap, shockTrap.
final class HuntingItem {
  const HuntingItem({required this.id, required this.name});

  static const knownIds = {
    'flash',
    'sonic',
    'dung',
    'pitfallTrap',
    'shockTrap',
  };

  final String id;
  final LocalizedText name;
}
