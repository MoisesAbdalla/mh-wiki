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

  @override
  String get filterAll => 'Todos';

  @override
  String get filterWorldIceborne => 'World';

  @override
  String get filterRiseSunbreak => 'Rise';

  @override
  String get filterWilds => 'Wilds';

  @override
  String get gameFilterLabel => 'Filtrar por jogo';

  @override
  String get noResults => 'Nenhum monstro encontrado';

  @override
  String get activeFiltersHint => 'Há filtros ativos.';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get searchHint => 'Buscar monstro';

  @override
  String get clearSearch => 'Limpar busca';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get nameLanguageTitle => 'Idioma dos nomes do jogo';

  @override
  String get nameLanguageDescription =>
      'Nomes de monstros, materiais, habitats e partes. O restante do app continua em português.';

  @override
  String get nameLanguagePtBr => 'Português (Brasil)';

  @override
  String get nameLanguageEn => 'English';

  @override
  String get saveFailed => 'Não foi possível salvar a preferência';

  @override
  String get appSubtitle => 'Caderno do Caçador';

  @override
  String get sectionTitleWorldIceborne => 'World : Iceborne';

  @override
  String get sectionTitleRiseSunbreak => 'Rise : Sunbreak';

  @override
  String get sectionTitleWilds => 'Wilds';

  @override
  String get sectionHp => 'HP';

  @override
  String get sectionHuntingItems => 'Itens de caça';

  @override
  String get hpSolo => 'Solo';

  @override
  String get hpParty => 'Grupo (aprox.)';

  @override
  String hpFrom(String value) {
    return 'a partir de $value';
  }

  @override
  String hpHunters(int count) {
    return '$count caçadores';
  }

  @override
  String sourceLabel(String name) {
    return 'Fonte: $name';
  }

  @override
  String get hpUnknown => 'HP desconhecido';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get visionLabel => 'Visão';

  @override
  String get visionSees => 'Enxerga';

  @override
  String get effectAffects => 'Afeta';

  @override
  String get effectNoEffect => 'Não afeta';

  @override
  String get effectConditional => 'Afeta com condição';

  @override
  String get versionBase => 'Base';

  @override
  String get versionTempered => 'Temperado';

  @override
  String get versionArchTempered => 'Arquitemperado';

  @override
  String get versionAfflicted => 'Aflito';

  @override
  String get versionFrenzied => 'Frenesi';

  @override
  String get versionApex => 'Apex';

  @override
  String get versionRisen => 'Ressurgido';

  @override
  String get versionGuardian => 'Guardião';

  @override
  String versionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versões',
      one: '1 versão',
    );
    return '$_temp0';
  }

  @override
  String versionTabLabel(String label) {
    return 'Versão: $label';
  }

  @override
  String get inheritedFromBase => 'Igual à forma base';
}
