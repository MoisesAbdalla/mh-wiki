import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_traits.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Weapon enums as localized UI strings (constitution Principle VII).
extension WeaponLabels on AppLocalizations {
  String specialName(SpecialKind kind) => switch (kind) {
    SpecialKind.poison => statusPoison,
    SpecialKind.sleep => statusSleep,
    SpecialKind.paralysis => statusParalysis,
    SpecialKind.blast => statusBlast,
    _ => elementName(kind.element!),
  };

  /// "−20%" with a real minus sign, "+10%", or "0%".
  String signedPercent(int value) => value > 0
      ? '+$value%'
      : value < 0
      ? '−${-value}%'
      : '0%';

  String ammoName(AmmoKind kind) => switch (kind) {
    AmmoKind.normal => ammoNormal,
    AmmoKind.pierce => ammoPierce,
    AmmoKind.spread => ammoSpread,
    AmmoKind.shrapnel => ammoShrapnel,
    AmmoKind.sticky => ammoSticky,
    AmmoKind.cluster => ammoCluster,
    AmmoKind.flaming => ammoFlaming,
    AmmoKind.water => ammoWater,
    AmmoKind.thunder => ammoThunder,
    AmmoKind.freeze => ammoFreeze,
    AmmoKind.dragon => ammoDragon,
    AmmoKind.poison => ammoPoison,
    AmmoKind.paralysis => ammoParalysis,
    AmmoKind.sleep => ammoSleep,
    AmmoKind.exhaust => ammoExhaust,
    AmmoKind.recover => ammoRecover,
    AmmoKind.demon => ammoDemon,
    AmmoKind.armor => ammoArmor,
    AmmoKind.slicing => ammoSlicing,
    AmmoKind.wyvern => ammoWyvern,
    AmmoKind.tranq => ammoTranq,
  };
}
