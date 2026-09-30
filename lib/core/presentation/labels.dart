import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/rank.dart';
import 'package:mh_wiki/features/monsters/domain/entities/element_type.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Maps domain enums to localized UI strings (constitution Principle VII).
extension DomainLabels on AppLocalizations {
  String gameName(Game game) => switch (game) {
    Game.worldIceborne => gameWorldIceborne,
    Game.riseSunbreak => gameRiseSunbreak,
    Game.wilds => gameWilds,
  };

  /// Short title for the ornamental section headers ("World : Iceborne").
  String gameSectionTitle(Game game) => switch (game) {
    Game.worldIceborne => sectionTitleWorldIceborne,
    Game.riseSunbreak => sectionTitleRiseSunbreak,
    Game.wilds => sectionTitleWilds,
  };

  String elementName(ElementType element) => switch (element) {
    ElementType.fire => elementFire,
    ElementType.water => elementWater,
    ElementType.thunder => elementThunder,
    ElementType.ice => elementIce,
    ElementType.dragon => elementDragon,
  };

  String rankName(Rank rank) => switch (rank) {
    Rank.low => rankLow,
    Rank.high => rankHigh,
    Rank.master => rankMaster,
  };

  /// "32%" or "1,5%" (pt-BR decimal comma); unknown rates are handled by callers.
  String percent(double value) {
    final text = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1).replaceAll('.', ',');
    return '$text%';
  }
}
