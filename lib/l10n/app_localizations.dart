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
  /// **'MH Wiki'**
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

  /// No description provided for @monsterSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'{game} · {classification}'**
  String monsterSubtitle(String game, String classification);

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
  /// **'World: Iceborne'**
  String get filterWorldIceborne;

  /// No description provided for @filterRiseSunbreak.
  ///
  /// In pt, this message translates to:
  /// **'Rise: Sunbreak'**
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
