// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'MH Wiki';

  @override
  String get gameWorldIceborne => 'Monster Hunter World: Iceborne';

  @override
  String get gameRiseSunbreak => 'Monster Hunter Rise: Sunbreak';

  @override
  String get gameWilds => 'Monster Hunter Wilds';

  @override
  String get loadFailed => 'Não foi possível carregar os dados dos monstros.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String failedGamesBanner(String games) {
    return 'Não foi possível carregar os dados de: $games';
  }

  @override
  String get selectMonster => 'Selecione um monstro';

  @override
  String monsterSubtitle(String game, String classification) {
    return '$game · $classification';
  }

  @override
  String get sectionWeaknesses => 'Fraquezas elementais';

  @override
  String get sectionHabitat => 'Habitat';

  @override
  String get sectionParts => 'Partes quebráveis';

  @override
  String get sectionMaterials => 'Materiais';

  @override
  String get weaknessByState => 'Variações por estado';

  @override
  String get elementFire => 'Fogo';

  @override
  String get elementWater => 'Água';

  @override
  String get elementThunder => 'Raio';

  @override
  String get elementIce => 'Gelo';

  @override
  String get elementDragon => 'Dragão';

  @override
  String get immune => 'Imune';

  @override
  String starsSemantics(String element, int stars) {
    return '$element: $stars de 3';
  }

  @override
  String immuneSemantics(String element) {
    return '$element: imune';
  }

  @override
  String get noHabitat => 'Nenhum habitat fixo';

  @override
  String get noParts => 'Nenhuma parte quebrável';

  @override
  String get severable => 'Cortável';

  @override
  String get noMaterials => 'Nenhum material registrado';

  @override
  String get rankLow => 'Baixo';

  @override
  String get rankHigh => 'Alto';

  @override
  String get rankMaster => 'Mestre';

  @override
  String rarity(int value) {
    return 'Raridade $value';
  }

  @override
  String get methodCarve => 'Entalhe';

  @override
  String get methodTailCarve => 'Entalhe da cauda';

  @override
  String get methodCapture => 'Captura';

  @override
  String methodBreakPart(String part) {
    return 'Quebrar: $part';
  }

  @override
  String get methodQuestReward => 'Recompensa de missão';

  @override
  String get methodDroppedMaterial => 'Material caído';

  @override
  String get rateUnknown => 'Taxa desconhecida';
}
