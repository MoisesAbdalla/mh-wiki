import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// Application title
  ///
  /// In pt, this message translates to:
  /// **'Caderninho'**
  String get appTitle;

  /// No description provided for @gameWorldIceborne.
  ///
  /// In pt, this message translates to:
  /// **'Monster Hunter World: Iceborne'**
  String get gameWorldIceborne;

  /// No description provided for @gameRiseSunbreak.
  ///
  /// In pt, this message translates to:
  /// **'Monster Hunter Rise: Sunbreak'**
  String get gameRiseSunbreak;

  /// No description provided for @gameWilds.
  ///
  /// In pt, this message translates to:
  /// **'Monster Hunter Wilds'**
  String get gameWilds;

  /// No description provided for @loadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os dados dos monstros.'**
  String get loadFailed;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// No description provided for @failedGamesBanner.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os dados de: {games}'**
  String failedGamesBanner(String games);

  /// No description provided for @selectMonster.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um monstro'**
  String get selectMonster;

  /// No description provided for @sectionWeaknesses.
  ///
  /// In pt, this message translates to:
  /// **'Fraquezas elementais'**
  String get sectionWeaknesses;

  /// No description provided for @sectionHabitat.
  ///
  /// In pt, this message translates to:
  /// **'Habitat'**
  String get sectionHabitat;

  /// No description provided for @sectionParts.
  ///
  /// In pt, this message translates to:
  /// **'Partes quebráveis'**
  String get sectionParts;

  /// No description provided for @sectionMaterials.
  ///
  /// In pt, this message translates to:
  /// **'Materiais'**
  String get sectionMaterials;

  /// No description provided for @weaknessByState.
  ///
  /// In pt, this message translates to:
  /// **'Variações por estado'**
  String get weaknessByState;

  /// No description provided for @elementFire.
  ///
  /// In pt, this message translates to:
  /// **'Fogo'**
  String get elementFire;

  /// No description provided for @elementWater.
  ///
  /// In pt, this message translates to:
  /// **'Água'**
  String get elementWater;

  /// No description provided for @elementThunder.
  ///
  /// In pt, this message translates to:
  /// **'Raio'**
  String get elementThunder;

  /// No description provided for @elementIce.
  ///
  /// In pt, this message translates to:
  /// **'Gelo'**
  String get elementIce;

  /// No description provided for @elementDragon.
  ///
  /// In pt, this message translates to:
  /// **'Dragão'**
  String get elementDragon;

  /// No description provided for @immune.
  ///
  /// In pt, this message translates to:
  /// **'Imune'**
  String get immune;

  /// No description provided for @starsSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{element}: {stars} de 3'**
  String starsSemantics(String element, int stars);

  /// No description provided for @bestWeakness.
  ///
  /// In pt, this message translates to:
  /// **'Melhor'**
  String get bestWeakness;

  /// No description provided for @bestWeaknessSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{element}: {stars} de 3, melhor fraqueza'**
  String bestWeaknessSemantics(String element, int stars);

  /// No description provided for @immuneSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{element}: imune'**
  String immuneSemantics(String element);

  /// No description provided for @noHabitat.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum habitat fixo'**
  String get noHabitat;

  /// No description provided for @noParts.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma parte quebrável'**
  String get noParts;

  /// No description provided for @severable.
  ///
  /// In pt, this message translates to:
  /// **'Cortável'**
  String get severable;

  /// No description provided for @noMaterials.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum material registrado'**
  String get noMaterials;

  /// No description provided for @rankLow.
  ///
  /// In pt, this message translates to:
  /// **'Baixo'**
  String get rankLow;

  /// No description provided for @rankHigh.
  ///
  /// In pt, this message translates to:
  /// **'Alto'**
  String get rankHigh;

  /// No description provided for @rankMaster.
  ///
  /// In pt, this message translates to:
  /// **'Mestre'**
  String get rankMaster;

  /// No description provided for @rarity.
  ///
  /// In pt, this message translates to:
  /// **'Raridade {value}'**
  String rarity(int value);

  /// No description provided for @methodCarve.
  ///
  /// In pt, this message translates to:
  /// **'Entalhe'**
  String get methodCarve;

  /// No description provided for @methodTailCarve.
  ///
  /// In pt, this message translates to:
  /// **'Entalhe da cauda'**
  String get methodTailCarve;

  /// No description provided for @methodCapture.
  ///
  /// In pt, this message translates to:
  /// **'Captura'**
  String get methodCapture;

  /// No description provided for @methodBreakPart.
  ///
  /// In pt, this message translates to:
  /// **'Quebrar: {part}'**
  String methodBreakPart(String part);

  /// No description provided for @methodQuestReward.
  ///
  /// In pt, this message translates to:
  /// **'Recompensa de missão'**
  String get methodQuestReward;

  /// No description provided for @methodDroppedMaterial.
  ///
  /// In pt, this message translates to:
  /// **'Material caído'**
  String get methodDroppedMaterial;

  /// No description provided for @rateUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Taxa desconhecida'**
  String get rateUnknown;

  /// No description provided for @filterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @filterWorldIceborne.
  ///
  /// In pt, this message translates to:
  /// **'World'**
  String get filterWorldIceborne;

  /// No description provided for @filterRiseSunbreak.
  ///
  /// In pt, this message translates to:
  /// **'Rise'**
  String get filterRiseSunbreak;

  /// No description provided for @filterWilds.
  ///
  /// In pt, this message translates to:
  /// **'Wilds'**
  String get filterWilds;

  /// No description provided for @gameFilterLabel.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar por jogo'**
  String get gameFilterLabel;

  /// No description provided for @noResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum monstro encontrado'**
  String get noResults;

  /// No description provided for @activeFiltersHint.
  ///
  /// In pt, this message translates to:
  /// **'Há filtros ativos.'**
  String get activeFiltersHint;

  /// No description provided for @clearFilters.
  ///
  /// In pt, this message translates to:
  /// **'Limpar filtros'**
  String get clearFilters;

  /// No description provided for @searchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar monstro'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In pt, this message translates to:
  /// **'Limpar busca'**
  String get clearSearch;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @nameLanguageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Idioma dos nomes do jogo'**
  String get nameLanguageTitle;

  /// No description provided for @nameLanguageDescription.
  ///
  /// In pt, this message translates to:
  /// **'Nomes de monstros, materiais, habitats e partes. O restante do app continua em português.'**
  String get nameLanguageDescription;

  /// No description provided for @nameLanguagePtBr.
  ///
  /// In pt, this message translates to:
  /// **'Português (Brasil)'**
  String get nameLanguagePtBr;

  /// No description provided for @nameLanguageEn.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get nameLanguageEn;

  /// No description provided for @saveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar a preferência'**
  String get saveFailed;

  /// No description provided for @sectionTitleWorldIceborne.
  ///
  /// In pt, this message translates to:
  /// **'World : Iceborne'**
  String get sectionTitleWorldIceborne;

  /// No description provided for @sectionTitleRiseSunbreak.
  ///
  /// In pt, this message translates to:
  /// **'Rise : Sunbreak'**
  String get sectionTitleRiseSunbreak;

  /// No description provided for @sectionTitleWilds.
  ///
  /// In pt, this message translates to:
  /// **'Wilds'**
  String get sectionTitleWilds;

  /// No description provided for @sectionHp.
  ///
  /// In pt, this message translates to:
  /// **'HP'**
  String get sectionHp;

  /// No description provided for @sectionHuntingItems.
  ///
  /// In pt, this message translates to:
  /// **'Itens de caça'**
  String get sectionHuntingItems;

  /// No description provided for @hpSolo.
  ///
  /// In pt, this message translates to:
  /// **'Solo'**
  String get hpSolo;

  /// No description provided for @hpParty.
  ///
  /// In pt, this message translates to:
  /// **'Grupo (aprox.)'**
  String get hpParty;

  /// No description provided for @hpFrom.
  ///
  /// In pt, this message translates to:
  /// **'a partir de {value}'**
  String hpFrom(String value);

  /// No description provided for @hpHunters.
  ///
  /// In pt, this message translates to:
  /// **'{count} caçadores'**
  String hpHunters(int count);

  /// No description provided for @sourceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Fonte: {name}'**
  String sourceLabel(String name);

  /// No description provided for @hpRulerSemantics.
  ///
  /// In pt, this message translates to:
  /// **'HP solo {solo}; 2 caçadores {two}; 3 a 4 caçadores {more}'**
  String hpRulerSemantics(String solo, String two, String more);

  /// No description provided for @hpFromLabel.
  ///
  /// In pt, this message translates to:
  /// **'a partir de'**
  String get hpFromLabel;

  /// No description provided for @hpUnknown.
  ///
  /// In pt, this message translates to:
  /// **'HP desconhecido'**
  String get hpUnknown;

  /// No description provided for @unknown.
  ///
  /// In pt, this message translates to:
  /// **'Desconhecido'**
  String get unknown;

  /// No description provided for @visionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Visão'**
  String get visionLabel;

  /// No description provided for @visionSees.
  ///
  /// In pt, this message translates to:
  /// **'Enxerga'**
  String get visionSees;

  /// No description provided for @effectAffects.
  ///
  /// In pt, this message translates to:
  /// **'Afeta'**
  String get effectAffects;

  /// No description provided for @effectNoEffect.
  ///
  /// In pt, this message translates to:
  /// **'Não afeta'**
  String get effectNoEffect;

  /// No description provided for @effectConditional.
  ///
  /// In pt, this message translates to:
  /// **'Afeta com condição'**
  String get effectConditional;

  /// No description provided for @versionBase.
  ///
  /// In pt, this message translates to:
  /// **'Base'**
  String get versionBase;

  /// No description provided for @versionTempered.
  ///
  /// In pt, this message translates to:
  /// **'Temperado'**
  String get versionTempered;

  /// No description provided for @versionArchTempered.
  ///
  /// In pt, this message translates to:
  /// **'Arquitemperado'**
  String get versionArchTempered;

  /// No description provided for @versionAfflicted.
  ///
  /// In pt, this message translates to:
  /// **'Aflito'**
  String get versionAfflicted;

  /// No description provided for @versionFrenzied.
  ///
  /// In pt, this message translates to:
  /// **'Frenesi'**
  String get versionFrenzied;

  /// No description provided for @versionApex.
  ///
  /// In pt, this message translates to:
  /// **'Apex'**
  String get versionApex;

  /// No description provided for @versionRisen.
  ///
  /// In pt, this message translates to:
  /// **'Ressurgido'**
  String get versionRisen;

  /// No description provided for @versionGuardian.
  ///
  /// In pt, this message translates to:
  /// **'Guardião'**
  String get versionGuardian;

  /// No description provided for @versionCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 versão} other{{count} versões}}'**
  String versionCount(int count);

  /// No description provided for @versionTabLabel.
  ///
  /// In pt, this message translates to:
  /// **'Versão: {label}'**
  String versionTabLabel(String label);

  /// No description provided for @inheritedFromBase.
  ///
  /// In pt, this message translates to:
  /// **'Igual à forma base'**
  String get inheritedFromBase;

  /// No description provided for @areaMonsters.
  ///
  /// In pt, this message translates to:
  /// **'Monstros'**
  String get areaMonsters;

  /// No description provided for @areaWeapons.
  ///
  /// In pt, this message translates to:
  /// **'Armas'**
  String get areaWeapons;

  /// No description provided for @areaArmor.
  ///
  /// In pt, this message translates to:
  /// **'Armaduras'**
  String get areaArmor;

  /// No description provided for @areaAssistant.
  ///
  /// In pt, this message translates to:
  /// **'Assistente'**
  String get areaAssistant;

  /// No description provided for @areaComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'{area}, em breve'**
  String areaComingSoon(String area);

  /// No description provided for @gameComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'{game}, em breve'**
  String gameComingSoon(String game);

  /// No description provided for @comingSoon.
  ///
  /// In pt, this message translates to:
  /// **'em breve'**
  String get comingSoon;

  /// No description provided for @weaponTypeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de arma: {type}'**
  String weaponTypeLabel(String type);

  /// No description provided for @rankAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get rankAll;

  /// No description provided for @searchWeaponHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar arma'**
  String get searchWeaponHint;

  /// No description provided for @weaponCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 arma} other{{count} armas}}'**
  String weaponCount(int count);

  /// No description provided for @weaponSectionAttributes.
  ///
  /// In pt, this message translates to:
  /// **'Atributos'**
  String get weaponSectionAttributes;

  /// No description provided for @weaponSectionSharpness.
  ///
  /// In pt, this message translates to:
  /// **'Afiação'**
  String get weaponSectionSharpness;

  /// No description provided for @weaponSectionMaterials.
  ///
  /// In pt, this message translates to:
  /// **'Materiais'**
  String get weaponSectionMaterials;

  /// No description provided for @weaponSectionTree.
  ///
  /// In pt, this message translates to:
  /// **'Árvore'**
  String get weaponSectionTree;

  /// No description provided for @attack.
  ///
  /// In pt, this message translates to:
  /// **'Ataque'**
  String get attack;

  /// No description provided for @affinity.
  ///
  /// In pt, this message translates to:
  /// **'Afinidade'**
  String get affinity;

  /// No description provided for @slots.
  ///
  /// In pt, this message translates to:
  /// **'Slots'**
  String get slots;

  /// No description provided for @rampageSlot.
  ///
  /// In pt, this message translates to:
  /// **'Rampage'**
  String get rampageSlot;

  /// No description provided for @noSlots.
  ///
  /// In pt, this message translates to:
  /// **'Sem slots'**
  String get noSlots;

  /// No description provided for @slotsSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Slots: {slots}; Rampage: {rampage}'**
  String slotsSemantics(String slots, String rampage);

  /// No description provided for @slotLevel.
  ///
  /// In pt, this message translates to:
  /// **'nível {level}'**
  String slotLevel(int level);

  /// No description provided for @none.
  ///
  /// In pt, this message translates to:
  /// **'nenhum'**
  String get none;

  /// No description provided for @sharpnessBase.
  ///
  /// In pt, this message translates to:
  /// **'Normal'**
  String get sharpnessBase;

  /// No description provided for @sharpnessHandicraft.
  ///
  /// In pt, this message translates to:
  /// **'Com Artesanato (máximo)'**
  String get sharpnessHandicraft;

  /// No description provided for @sharpnessSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Afiação {label}: {segments}'**
  String sharpnessSemantics(String label, String segments);

  /// No description provided for @sharpnessRed.
  ///
  /// In pt, this message translates to:
  /// **'vermelho'**
  String get sharpnessRed;

  /// No description provided for @sharpnessOrange.
  ///
  /// In pt, this message translates to:
  /// **'laranja'**
  String get sharpnessOrange;

  /// No description provided for @sharpnessYellow.
  ///
  /// In pt, this message translates to:
  /// **'amarelo'**
  String get sharpnessYellow;

  /// No description provided for @sharpnessGreen.
  ///
  /// In pt, this message translates to:
  /// **'verde'**
  String get sharpnessGreen;

  /// No description provided for @sharpnessBlue.
  ///
  /// In pt, this message translates to:
  /// **'azul'**
  String get sharpnessBlue;

  /// No description provided for @sharpnessWhite.
  ///
  /// In pt, this message translates to:
  /// **'branco'**
  String get sharpnessWhite;

  /// No description provided for @sharpnessPurple.
  ///
  /// In pt, this message translates to:
  /// **'roxo'**
  String get sharpnessPurple;

  /// No description provided for @forgeMaterials.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get forgeMaterials;

  /// No description provided for @upgradeMaterials.
  ///
  /// In pt, this message translates to:
  /// **'Melhorar'**
  String get upgradeMaterials;

  /// No description provided for @materialPoints.
  ///
  /// In pt, this message translates to:
  /// **'{points} pts.'**
  String materialPoints(int points);

  /// No description provided for @droppedBy.
  ///
  /// In pt, this message translates to:
  /// **'Dropado por: {monsters}'**
  String droppedBy(String monsters);

  /// No description provided for @treePrevious.
  ///
  /// In pt, this message translates to:
  /// **'anterior'**
  String get treePrevious;

  /// No description provided for @treeCurrent.
  ///
  /// In pt, this message translates to:
  /// **'esta'**
  String get treeCurrent;

  /// No description provided for @treeNext.
  ///
  /// In pt, this message translates to:
  /// **'próxima'**
  String get treeNext;

  /// No description provided for @starsEstimated.
  ///
  /// In pt, this message translates to:
  /// **'{stars}★ (estimado)'**
  String starsEstimated(int stars);

  /// No description provided for @weaponsMadeFrom.
  ///
  /// In pt, this message translates to:
  /// **'Armas feitas com ele'**
  String get weaponsMadeFrom;

  /// No description provided for @seeAllWeapons.
  ///
  /// In pt, this message translates to:
  /// **'Ver todas ({count})'**
  String seeAllWeapons(int count);

  /// No description provided for @weaponsOfMonster.
  ///
  /// In pt, this message translates to:
  /// **'Armas de {monster}'**
  String weaponsOfMonster(String monster);

  /// No description provided for @weaponsLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as armas.'**
  String get weaponsLoadFailed;

  /// No description provided for @noWeaponsFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma arma encontrada'**
  String get noWeaponsFound;

  /// No description provided for @statusPoison.
  ///
  /// In pt, this message translates to:
  /// **'Veneno'**
  String get statusPoison;

  /// No description provided for @statusSleep.
  ///
  /// In pt, this message translates to:
  /// **'Sono'**
  String get statusSleep;

  /// No description provided for @statusParalysis.
  ///
  /// In pt, this message translates to:
  /// **'Paralisia'**
  String get statusParalysis;

  /// No description provided for @statusBlast.
  ///
  /// In pt, this message translates to:
  /// **'Explosão'**
  String get statusBlast;

  /// No description provided for @rankLabel.
  ///
  /// In pt, this message translates to:
  /// **'Rank {rank}'**
  String rankLabel(String rank);

  /// No description provided for @selectWeapon.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma arma na lista'**
  String get selectWeapon;

  /// No description provided for @weaponTreeSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{tree}, {count}'**
  String weaponTreeSemantics(String tree, String count);

  /// No description provided for @traitPhial.
  ///
  /// In pt, this message translates to:
  /// **'Frasco'**
  String get traitPhial;

  /// No description provided for @traitShelling.
  ///
  /// In pt, this message translates to:
  /// **'Projéteis'**
  String get traitShelling;

  /// No description provided for @traitKinsect.
  ///
  /// In pt, this message translates to:
  /// **'Inseto'**
  String get traitKinsect;

  /// No description provided for @kinsectLevel.
  ///
  /// In pt, this message translates to:
  /// **'Nível {level}'**
  String kinsectLevel(int level);

  /// No description provided for @traitSongs.
  ///
  /// In pt, this message translates to:
  /// **'Músicas'**
  String get traitSongs;

  /// No description provided for @weaponSectionAmmo.
  ///
  /// In pt, this message translates to:
  /// **'Munição'**
  String get weaponSectionAmmo;

  /// No description provided for @arcShot.
  ///
  /// In pt, this message translates to:
  /// **'Tiro de arco'**
  String get arcShot;

  /// No description provided for @chargeShots.
  ///
  /// In pt, this message translates to:
  /// **'Disparos por carga'**
  String get chargeShots;

  /// No description provided for @chargeLevel.
  ///
  /// In pt, this message translates to:
  /// **'Carga {level}'**
  String chargeLevel(int level);

  /// No description provided for @needsSkill.
  ///
  /// In pt, this message translates to:
  /// **'precisa de habilidade'**
  String get needsSkill;

  /// No description provided for @coatings.
  ///
  /// In pt, this message translates to:
  /// **'Revestimentos'**
  String get coatings;

  /// No description provided for @ammoLevels.
  ///
  /// In pt, this message translates to:
  /// **'nível 1 · 2 · 3'**
  String get ammoLevels;

  /// No description provided for @ammoElementalLevels.
  ///
  /// In pt, this message translates to:
  /// **'normal · perfurante'**
  String get ammoElementalLevels;

  /// No description provided for @ammoCapacitySemantics.
  ///
  /// In pt, this message translates to:
  /// **'{ammo}: {capacity}'**
  String ammoCapacitySemantics(String ammo, String capacity);

  /// No description provided for @ammoNormal.
  ///
  /// In pt, this message translates to:
  /// **'Normal'**
  String get ammoNormal;

  /// No description provided for @ammoPierce.
  ///
  /// In pt, this message translates to:
  /// **'Perfurante'**
  String get ammoPierce;

  /// No description provided for @ammoSpread.
  ///
  /// In pt, this message translates to:
  /// **'Dispersão'**
  String get ammoSpread;

  /// No description provided for @ammoShrapnel.
  ///
  /// In pt, this message translates to:
  /// **'Estilhaço'**
  String get ammoShrapnel;

  /// No description provided for @ammoSticky.
  ///
  /// In pt, this message translates to:
  /// **'Adesiva'**
  String get ammoSticky;

  /// No description provided for @ammoCluster.
  ///
  /// In pt, this message translates to:
  /// **'Grupo'**
  String get ammoCluster;

  /// No description provided for @ammoFlaming.
  ///
  /// In pt, this message translates to:
  /// **'Fogo'**
  String get ammoFlaming;

  /// No description provided for @ammoWater.
  ///
  /// In pt, this message translates to:
  /// **'Água'**
  String get ammoWater;

  /// No description provided for @ammoThunder.
  ///
  /// In pt, this message translates to:
  /// **'Trovão'**
  String get ammoThunder;

  /// No description provided for @ammoFreeze.
  ///
  /// In pt, this message translates to:
  /// **'Gelo'**
  String get ammoFreeze;

  /// No description provided for @ammoDragon.
  ///
  /// In pt, this message translates to:
  /// **'Dragão'**
  String get ammoDragon;

  /// No description provided for @ammoPoison.
  ///
  /// In pt, this message translates to:
  /// **'Veneno'**
  String get ammoPoison;

  /// No description provided for @ammoParalysis.
  ///
  /// In pt, this message translates to:
  /// **'Paralisia'**
  String get ammoParalysis;

  /// No description provided for @ammoSleep.
  ///
  /// In pt, this message translates to:
  /// **'Sono'**
  String get ammoSleep;

  /// No description provided for @ammoExhaust.
  ///
  /// In pt, this message translates to:
  /// **'Exaustão'**
  String get ammoExhaust;

  /// No description provided for @ammoRecover.
  ///
  /// In pt, this message translates to:
  /// **'Recuperação'**
  String get ammoRecover;

  /// No description provided for @ammoDemon.
  ///
  /// In pt, this message translates to:
  /// **'Demoníaca'**
  String get ammoDemon;

  /// No description provided for @ammoArmor.
  ///
  /// In pt, this message translates to:
  /// **'Blindagem'**
  String get ammoArmor;

  /// No description provided for @ammoSlicing.
  ///
  /// In pt, this message translates to:
  /// **'Cortante'**
  String get ammoSlicing;

  /// No description provided for @ammoWyvern.
  ///
  /// In pt, this message translates to:
  /// **'Serpe'**
  String get ammoWyvern;

  /// No description provided for @ammoTranq.
  ///
  /// In pt, this message translates to:
  /// **'Tranquilizante'**
  String get ammoTranq;

  /// No description provided for @gatheringMaps.
  ///
  /// In pt, this message translates to:
  /// **'{kind} · {count, plural, =1{1 mapa} other{{count} mapas}}'**
  String gatheringMaps(String kind, int count);

  /// No description provided for @gatheringAt.
  ///
  /// In pt, this message translates to:
  /// **'{kind} · {map}'**
  String gatheringAt(String kind, String map);

  /// No description provided for @smallMonster.
  ///
  /// In pt, this message translates to:
  /// **'{monster} · pequeno'**
  String smallMonster(String monster);

  /// No description provided for @questChip.
  ///
  /// In pt, this message translates to:
  /// **'Missão · {stars}★'**
  String questChip(String stars);

  /// No description provided for @questsChip.
  ///
  /// In pt, this message translates to:
  /// **'{count} missões'**
  String questsChip(int count);

  /// No description provided for @unknownOrigin.
  ///
  /// In pt, this message translates to:
  /// **'Origem desconhecida'**
  String get unknownOrigin;

  /// No description provided for @sourcesGathering.
  ///
  /// In pt, this message translates to:
  /// **'{kind} · Rank {rank}'**
  String sourcesGathering(String kind, String rank);

  /// No description provided for @sourcesMonsters.
  ///
  /// In pt, this message translates to:
  /// **'Monstros · Rank {rank}'**
  String sourcesMonsters(String rank);

  /// No description provided for @sourcesQuests.
  ///
  /// In pt, this message translates to:
  /// **'Missões'**
  String get sourcesQuests;

  /// No description provided for @showSources.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar de onde vem'**
  String get showSources;

  /// No description provided for @hideSources.
  ///
  /// In pt, this message translates to:
  /// **'Esconder de onde vem'**
  String get hideSources;

  /// No description provided for @armorTabSets.
  ///
  /// In pt, this message translates to:
  /// **'Conjuntos'**
  String get armorTabSets;

  /// No description provided for @armorTabSkills.
  ///
  /// In pt, this message translates to:
  /// **'Habilidades'**
  String get armorTabSkills;

  /// No description provided for @armorTabDecorations.
  ///
  /// In pt, this message translates to:
  /// **'Joias'**
  String get armorTabDecorations;

  /// No description provided for @partHead.
  ///
  /// In pt, this message translates to:
  /// **'Cabeça'**
  String get partHead;

  /// No description provided for @partChest.
  ///
  /// In pt, this message translates to:
  /// **'Tronco'**
  String get partChest;

  /// No description provided for @partArms.
  ///
  /// In pt, this message translates to:
  /// **'Braços'**
  String get partArms;

  /// No description provided for @partWaist.
  ///
  /// In pt, this message translates to:
  /// **'Cintura'**
  String get partWaist;

  /// No description provided for @partLegs.
  ///
  /// In pt, this message translates to:
  /// **'Pernas'**
  String get partLegs;

  /// No description provided for @armorSectionDefense.
  ///
  /// In pt, this message translates to:
  /// **'Defesa'**
  String get armorSectionDefense;

  /// No description provided for @armorSectionSkills.
  ///
  /// In pt, this message translates to:
  /// **'Habilidades'**
  String get armorSectionSkills;

  /// No description provided for @armorSectionPieces.
  ///
  /// In pt, this message translates to:
  /// **'Peças'**
  String get armorSectionPieces;

  /// No description provided for @skillSectionLevels.
  ///
  /// In pt, this message translates to:
  /// **'Níveis'**
  String get skillSectionLevels;

  /// No description provided for @skillSectionDecorations.
  ///
  /// In pt, this message translates to:
  /// **'Joias'**
  String get skillSectionDecorations;

  /// No description provided for @skillSectionArmor.
  ///
  /// In pt, this message translates to:
  /// **'Armaduras'**
  String get skillSectionArmor;

  /// No description provided for @decorationSectionSkill.
  ///
  /// In pt, this message translates to:
  /// **'Habilidade'**
  String get decorationSectionSkill;

  /// No description provided for @defenseBase.
  ///
  /// In pt, this message translates to:
  /// **'Defesa'**
  String get defenseBase;

  /// No description provided for @defenseRange.
  ///
  /// In pt, this message translates to:
  /// **'{base} → {max}'**
  String defenseRange(int base, int max);

  /// No description provided for @resistancesSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Resistências: {values}'**
  String resistancesSemantics(String values);

  /// No description provided for @skillLevelShort.
  ///
  /// In pt, this message translates to:
  /// **'Nv {level}'**
  String skillLevelShort(int level);

  /// No description provided for @skillMaxLevel.
  ///
  /// In pt, this message translates to:
  /// **'máx. {level}'**
  String skillMaxLevel(int level);

  /// No description provided for @skillLevelOf.
  ///
  /// In pt, this message translates to:
  /// **'{skill}, nível {level} de {max}'**
  String skillLevelOf(String skill, int level, int max);

  /// No description provided for @skillOverflow.
  ///
  /// In pt, this message translates to:
  /// **'+{extra}'**
  String skillOverflow(int extra);

  /// No description provided for @piecesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 peça} other{{count} peças}}'**
  String piecesCount(int count);

  /// No description provided for @setSkillsFooter.
  ///
  /// In pt, this message translates to:
  /// **'Conjunto: {skills}'**
  String setSkillsFooter(String skills);

  /// No description provided for @slotLevelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Slot nível {level}'**
  String slotLevelTitle(int level);

  /// No description provided for @allSlots.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get allSlots;

  /// No description provided for @searchArmorHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar conjunto ou habilidade'**
  String get searchArmorHint;

  /// No description provided for @searchSkillHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar habilidade'**
  String get searchSkillHint;

  /// No description provided for @searchDecorationHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar joia'**
  String get searchDecorationHint;

  /// No description provided for @armorLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as armaduras.'**
  String get armorLoadFailed;

  /// No description provided for @noSetsFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum conjunto encontrado'**
  String get noSetsFound;

  /// No description provided for @noSkillsFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma habilidade encontrada'**
  String get noSkillsFound;

  /// No description provided for @noDecorationsFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma joia encontrada'**
  String get noDecorationsFound;

  /// No description provided for @seeAllPieces.
  ///
  /// In pt, this message translates to:
  /// **'Ver todas ({count})'**
  String seeAllPieces(int count);

  /// No description provided for @selectArmorItem.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um item na lista'**
  String get selectArmorItem;

  /// No description provided for @weaponSectionRampage.
  ///
  /// In pt, this message translates to:
  /// **'Habilidades Rampage'**
  String get weaponSectionRampage;

  /// No description provided for @rampageChooseOne.
  ///
  /// In pt, this message translates to:
  /// **'escolha uma'**
  String get rampageChooseOne;

  /// No description provided for @rampageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Rampage'**
  String get rampageTitle;

  /// No description provided for @rampageSlotRow.
  ///
  /// In pt, this message translates to:
  /// **'Slot Rampage'**
  String get rampageSlotRow;

  /// No description provided for @rampageDecorationsFit.
  ///
  /// In pt, this message translates to:
  /// **'Joias Rampage que cabem'**
  String get rampageDecorationsFit;

  /// No description provided for @gatherAny.
  ///
  /// In pt, this message translates to:
  /// **'Coleta'**
  String get gatherAny;

  /// No description provided for @gatherOre.
  ///
  /// In pt, this message translates to:
  /// **'Mineração'**
  String get gatherOre;

  /// No description provided for @gatherBone.
  ///
  /// In pt, this message translates to:
  /// **'Pilha de ossos'**
  String get gatherBone;

  /// No description provided for @gatherBug.
  ///
  /// In pt, this message translates to:
  /// **'Inseto'**
  String get gatherBug;

  /// No description provided for @gatherPlant.
  ///
  /// In pt, this message translates to:
  /// **'Planta'**
  String get gatherPlant;

  /// No description provided for @gatherFish.
  ///
  /// In pt, this message translates to:
  /// **'Pesca'**
  String get gatherFish;

  /// No description provided for @gatherNoMap.
  ///
  /// In pt, this message translates to:
  /// **'{kind} · mapa não informado'**
  String gatherNoMap(String kind);

  /// No description provided for @assistantTabRecommended.
  ///
  /// In pt, this message translates to:
  /// **'Recomendadas'**
  String get assistantTabRecommended;

  /// No description provided for @assistantTabSaved.
  ///
  /// In pt, this message translates to:
  /// **'Minhas builds'**
  String get assistantTabSaved;

  /// No description provided for @assistantTabBuild.
  ///
  /// In pt, this message translates to:
  /// **'Montar build'**
  String get assistantTabBuild;

  /// No description provided for @whereAreYou.
  ///
  /// In pt, this message translates to:
  /// **'Onde você está?'**
  String get whereAreYou;

  /// No description provided for @rankPost.
  ///
  /// In pt, this message translates to:
  /// **'Pós-jogo'**
  String get rankPost;

  /// No description provided for @progressStar.
  ///
  /// In pt, this message translates to:
  /// **'{step}★'**
  String progressStar(String step);

  /// No description provided for @progressBand.
  ///
  /// In pt, this message translates to:
  /// **'MR {band}+'**
  String progressBand(String band);

  /// No description provided for @stageFrom.
  ///
  /// In pt, this message translates to:
  /// **'A partir de {stage}'**
  String stageFrom(String stage);

  /// No description provided for @stageSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Disponível a partir de {stage}'**
  String stageSemantics(String stage);

  /// No description provided for @buildsNow.
  ///
  /// In pt, this message translates to:
  /// **'Para agora'**
  String get buildsNow;

  /// No description provided for @buildsNext.
  ///
  /// In pt, this message translates to:
  /// **'Próximas'**
  String get buildsNext;

  /// No description provided for @noBuildsNow.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma build pronta para este ponto; veja as próximas.'**
  String get noBuildsNow;

  /// No description provided for @noBuildsAtAll.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma build pronta para esta arma.'**
  String get noBuildsAtAll;

  /// No description provided for @buildSectionEquipment.
  ///
  /// In pt, this message translates to:
  /// **'Equipamento'**
  String get buildSectionEquipment;

  /// No description provided for @buildSectionSkills.
  ///
  /// In pt, this message translates to:
  /// **'Habilidades'**
  String get buildSectionSkills;

  /// No description provided for @buildSectionDecorations.
  ///
  /// In pt, this message translates to:
  /// **'Joias'**
  String get buildSectionDecorations;

  /// No description provided for @partWeapon.
  ///
  /// In pt, this message translates to:
  /// **'Arma'**
  String get partWeapon;

  /// No description provided for @partTalisman.
  ///
  /// In pt, this message translates to:
  /// **'Talismã'**
  String get partTalisman;

  /// No description provided for @alternativePiece.
  ///
  /// In pt, this message translates to:
  /// **'ou {name}'**
  String alternativePiece(String name);

  /// No description provided for @notInCatalog.
  ///
  /// In pt, this message translates to:
  /// **'não encontrado no catálogo'**
  String get notInCatalog;

  /// No description provided for @saveBuild.
  ///
  /// In pt, this message translates to:
  /// **'Salvar em Minhas builds'**
  String get saveBuild;

  /// No description provided for @buildSaved.
  ///
  /// In pt, this message translates to:
  /// **'Build salva em Minhas builds'**
  String get buildSaved;

  /// No description provided for @savedFrom.
  ///
  /// In pt, this message translates to:
  /// **'baseada em: {name}'**
  String savedFrom(String name);

  /// No description provided for @renameBuild.
  ///
  /// In pt, this message translates to:
  /// **'Renomear'**
  String get renameBuild;

  /// No description provided for @deleteBuild.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get deleteBuild;

  /// No description provided for @deleteBuildConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Excluir \"{name}\"?'**
  String deleteBuildConfirm(String name);

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @buildName.
  ///
  /// In pt, this message translates to:
  /// **'Nome da build'**
  String get buildName;

  /// No description provided for @noSavedBuilds.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma build salva. Abra uma build em Recomendadas e toque em \"Salvar em Minhas builds\".'**
  String get noSavedBuilds;

  /// No description provided for @buildsLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as builds.'**
  String get buildsLoadFailed;

  /// No description provided for @buildSourceNote.
  ///
  /// In pt, this message translates to:
  /// **'Fonte: {source}. Os aprimoramentos (Qurious) da guia não entram.'**
  String buildSourceNote(String source);

  /// No description provided for @openSource.
  ///
  /// In pt, this message translates to:
  /// **'Abrir a fonte'**
  String get openSource;

  /// No description provided for @selectBuild.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma build na lista'**
  String get selectBuild;

  /// No description provided for @afterStory.
  ///
  /// In pt, this message translates to:
  /// **'Depois da história'**
  String get afterStory;

  /// No description provided for @skillsWanted.
  ///
  /// In pt, this message translates to:
  /// **'Habilidades que você quer'**
  String get skillsWanted;

  /// No description provided for @searchSkill.
  ///
  /// In pt, this message translates to:
  /// **'Buscar habilidade…'**
  String get searchSkill;

  /// No description provided for @commonForType.
  ///
  /// In pt, this message translates to:
  /// **'Comuns para {type}'**
  String commonForType(String type);

  /// No description provided for @addSkill.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar {skill}'**
  String addSkill(String skill);

  /// No description provided for @increaseSkill.
  ///
  /// In pt, this message translates to:
  /// **'Aumentar {skill}'**
  String increaseSkill(String skill);

  /// No description provided for @decreaseSkill.
  ///
  /// In pt, this message translates to:
  /// **'Diminuir {skill}'**
  String decreaseSkill(String skill);

  /// No description provided for @removeSkill.
  ///
  /// In pt, this message translates to:
  /// **'Remover {skill}'**
  String removeSkill(String skill);

  /// No description provided for @weaponAndTalismans.
  ///
  /// In pt, this message translates to:
  /// **'Arma e talismãs'**
  String get weaponAndTalismans;

  /// No description provided for @weaponLabel.
  ///
  /// In pt, this message translates to:
  /// **'Arma'**
  String get weaponLabel;

  /// No description provided for @anyWeaponUpTo.
  ///
  /// In pt, this message translates to:
  /// **'Qualquer {type} até {progress}'**
  String anyWeaponUpTo(String type, String progress);

  /// No description provided for @anyWeapon.
  ///
  /// In pt, this message translates to:
  /// **'Qualquer'**
  String get anyWeapon;

  /// No description provided for @chooseWeapon.
  ///
  /// In pt, this message translates to:
  /// **'escolher'**
  String get chooseWeapon;

  /// No description provided for @searchWeapon.
  ///
  /// In pt, this message translates to:
  /// **'Buscar arma…'**
  String get searchWeapon;

  /// No description provided for @myTalismans.
  ///
  /// In pt, this message translates to:
  /// **'Meus talismãs'**
  String get myTalismans;

  /// No description provided for @talismansCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{nenhum cadastrado} =1{1 cadastrado} other{{count} cadastrados}}'**
  String talismansCount(int count);

  /// No description provided for @useTalismans.
  ///
  /// In pt, this message translates to:
  /// **'usar todos'**
  String get useTalismans;

  /// No description provided for @manage.
  ///
  /// In pt, this message translates to:
  /// **'gerenciar'**
  String get manage;

  /// No description provided for @onlyMyProgress.
  ///
  /// In pt, this message translates to:
  /// **'Só peças do meu progresso'**
  String get onlyMyProgress;

  /// No description provided for @upToRarity.
  ///
  /// In pt, this message translates to:
  /// **'até {progress} (raridade {rarity})'**
  String upToRarity(String progress, int rarity);

  /// No description provided for @buildIt.
  ///
  /// In pt, this message translates to:
  /// **'Montar build'**
  String get buildIt;

  /// No description provided for @alter.
  ///
  /// In pt, this message translates to:
  /// **'alterar'**
  String get alter;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'editar'**
  String get edit;

  /// No description provided for @searching.
  ///
  /// In pt, this message translates to:
  /// **'procurando…'**
  String get searching;

  /// No description provided for @searchingChecked.
  ///
  /// In pt, this message translates to:
  /// **'{count} combinações'**
  String searchingChecked(int count);

  /// No description provided for @skillsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 habilidade} other{{count} habilidades}}'**
  String skillsCount(int count);

  /// No description provided for @setsFound.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 conjunto encontrado} other{{count} conjuntos encontrados}}'**
  String setsFound(int count);

  /// No description provided for @optionN.
  ///
  /// In pt, this message translates to:
  /// **'Opção {n}'**
  String optionN(int n);

  /// No description provided for @setComplete.
  ///
  /// In pt, this message translates to:
  /// **'completa'**
  String get setComplete;

  /// No description provided for @setAlmost.
  ///
  /// In pt, this message translates to:
  /// **'quase'**
  String get setAlmost;

  /// No description provided for @missingN.
  ///
  /// In pt, this message translates to:
  /// **'falta {n}'**
  String missingN(int n);

  /// No description provided for @skillGot.
  ///
  /// In pt, this message translates to:
  /// **'{skill} {got}/{want}'**
  String skillGot(String skill, int got, int want);

  /// No description provided for @maxDefense.
  ///
  /// In pt, this message translates to:
  /// **'Defesa máx. {defense}'**
  String maxDefense(int defense);

  /// No description provided for @freeSlots.
  ///
  /// In pt, this message translates to:
  /// **'sobram'**
  String get freeSlots;

  /// No description provided for @noTalisman.
  ///
  /// In pt, this message translates to:
  /// **'nenhum'**
  String get noTalisman;

  /// No description provided for @weaponWithTalisman.
  ///
  /// In pt, this message translates to:
  /// **'{weapon} · talismã {talisman}'**
  String weaponWithTalisman(String weapon, String talisman);

  /// No description provided for @alsoComes.
  ///
  /// In pt, this message translates to:
  /// **'Também vem: {skills}'**
  String alsoComes(String skills);

  /// No description provided for @requestedSkills.
  ///
  /// In pt, this message translates to:
  /// **'Habilidades pedidas'**
  String get requestedSkills;

  /// No description provided for @resultOf.
  ///
  /// In pt, this message translates to:
  /// **'{n} de {total}'**
  String resultOf(int n, int total);

  /// No description provided for @resultsBack.
  ///
  /// In pt, this message translates to:
  /// **'Resultados'**
  String get resultsBack;

  /// No description provided for @yourTalisman.
  ///
  /// In pt, this message translates to:
  /// **'Talismã (seu)'**
  String get yourTalisman;

  /// No description provided for @noBuildSets.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum conjunto chega perto. Tente baixar níveis ou desligar \"Só peças do meu progresso\".'**
  String get noBuildSets;

  /// No description provided for @rankingNote.
  ///
  /// In pt, this message translates to:
  /// **'Ordenados por: atinge tudo, depois mais slots livres, depois defesa.'**
  String get rankingNote;

  /// No description provided for @chooseSkills.
  ///
  /// In pt, this message translates to:
  /// **'Escolha ao menos uma habilidade.'**
  String get chooseSkills;

  /// No description provided for @optimizerLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os dados do Montar build.'**
  String get optimizerLoadFailed;

  /// No description provided for @talismansTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meus talismãs'**
  String get talismansTitle;

  /// No description provided for @talismansNote.
  ///
  /// In pt, this message translates to:
  /// **'Usados pelo Montar build. Ficam no aparelho.'**
  String get talismansNote;

  /// No description provided for @registered.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrados'**
  String get registered;

  /// No description provided for @newTalisman.
  ///
  /// In pt, this message translates to:
  /// **'Novo talismã'**
  String get newTalisman;

  /// No description provided for @editTalisman.
  ///
  /// In pt, this message translates to:
  /// **'Editar talismã'**
  String get editTalisman;

  /// No description provided for @skillOne.
  ///
  /// In pt, this message translates to:
  /// **'Habilidade 1'**
  String get skillOne;

  /// No description provided for @skillTwoOptional.
  ///
  /// In pt, this message translates to:
  /// **'Habilidade 2 (opcional)'**
  String get skillTwoOptional;

  /// No description provided for @noneSkill.
  ///
  /// In pt, this message translates to:
  /// **'nenhuma'**
  String get noneSkill;

  /// No description provided for @slotN.
  ///
  /// In pt, this message translates to:
  /// **'Slot {n}'**
  String slotN(int n);

  /// No description provided for @emptySlot.
  ///
  /// In pt, this message translates to:
  /// **'vazio'**
  String get emptySlot;

  /// No description provided for @saveTalisman.
  ///
  /// In pt, this message translates to:
  /// **'Salvar talismã'**
  String get saveTalisman;

  /// No description provided for @deleteTalisman.
  ///
  /// In pt, this message translates to:
  /// **'Excluir talismã'**
  String get deleteTalisman;

  /// No description provided for @deleteTalismanConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Excluir \"{name}\"?'**
  String deleteTalismanConfirm(String name);

  /// No description provided for @noTalismans.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum talismã cadastrado.'**
  String get noTalismans;

  /// No description provided for @skillProgressSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{skill}, {got} de {want}'**
  String skillProgressSemantics(String skill, int got, int want);

  /// No description provided for @skillMissingSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{skill}, {got} de {want}, faltam {missing}'**
  String skillMissingSemantics(String skill, int got, int want, int missing);

  /// No description provided for @optimizerSource.
  ///
  /// In pt, this message translates to:
  /// **'Caderninho · Montar build'**
  String get optimizerSource;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
