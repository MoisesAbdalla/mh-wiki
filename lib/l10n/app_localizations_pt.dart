// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Caderninho';

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
  String get bestWeakness => 'Melhor';

  @override
  String bestWeaknessSemantics(String element, int stars) {
    return '$element: $stars de 3, melhor fraqueza';
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
  String hpRulerSemantics(String solo, String two, String more) {
    return 'HP solo $solo; 2 caçadores $two; 3 a 4 caçadores $more';
  }

  @override
  String get hpFromLabel => 'a partir de';

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

  @override
  String get areaMonsters => 'Monstros';

  @override
  String get areaWeapons => 'Armas';

  @override
  String get areaArmor => 'Armaduras';

  @override
  String get areaAssistant => 'Assistente';

  @override
  String areaComingSoon(String area) {
    return '$area, em breve';
  }

  @override
  String gameComingSoon(String game) {
    return '$game, em breve';
  }

  @override
  String get comingSoon => 'em breve';

  @override
  String weaponTypeLabel(String type) {
    return 'Tipo de arma: $type';
  }

  @override
  String get rankAll => 'Todos';

  @override
  String get searchWeaponHint => 'Buscar arma';

  @override
  String weaponCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count armas',
      one: '1 arma',
    );
    return '$_temp0';
  }

  @override
  String get weaponSectionAttributes => 'Atributos';

  @override
  String get weaponSectionSharpness => 'Afiação';

  @override
  String get weaponSectionMaterials => 'Materiais';

  @override
  String get weaponSectionTree => 'Árvore';

  @override
  String get attack => 'Ataque';

  @override
  String get affinity => 'Afinidade';

  @override
  String get slots => 'Slots';

  @override
  String get rampageSlot => 'Rampage';

  @override
  String get noSlots => 'Sem slots';

  @override
  String slotsSemantics(String slots, String rampage) {
    return 'Slots: $slots; Rampage: $rampage';
  }

  @override
  String slotLevel(int level) {
    return 'nível $level';
  }

  @override
  String get none => 'nenhum';

  @override
  String get sharpnessBase => 'Normal';

  @override
  String get sharpnessHandicraft => 'Com Artesanato (máximo)';

  @override
  String sharpnessSemantics(String label, String segments) {
    return 'Afiação $label: $segments';
  }

  @override
  String get sharpnessRed => 'vermelho';

  @override
  String get sharpnessOrange => 'laranja';

  @override
  String get sharpnessYellow => 'amarelo';

  @override
  String get sharpnessGreen => 'verde';

  @override
  String get sharpnessBlue => 'azul';

  @override
  String get sharpnessWhite => 'branco';

  @override
  String get sharpnessPurple => 'roxo';

  @override
  String get forgeMaterials => 'Criar';

  @override
  String get upgradeMaterials => 'Melhorar';

  @override
  String materialPoints(int points) {
    return '$points pts.';
  }

  @override
  String droppedBy(String monsters) {
    return 'Dropado por: $monsters';
  }

  @override
  String get treePrevious => 'anterior';

  @override
  String get treeCurrent => 'esta';

  @override
  String get treeNext => 'próxima';

  @override
  String starsEstimated(int stars) {
    return '$stars★ (estimado)';
  }

  @override
  String get weaponsMadeFrom => 'Armas feitas com ele';

  @override
  String seeAllWeapons(int count) {
    return 'Ver todas ($count)';
  }

  @override
  String weaponsOfMonster(String monster) {
    return 'Armas de $monster';
  }

  @override
  String get weaponsLoadFailed => 'Não foi possível carregar as armas.';

  @override
  String get noWeaponsFound => 'Nenhuma arma encontrada';

  @override
  String get statusPoison => 'Veneno';

  @override
  String get statusSleep => 'Sono';

  @override
  String get statusParalysis => 'Paralisia';

  @override
  String get statusBlast => 'Explosão';

  @override
  String rankLabel(String rank) {
    return 'Rank $rank';
  }

  @override
  String get selectWeapon => 'Escolha uma arma na lista';

  @override
  String weaponTreeSemantics(String tree, String count) {
    return '$tree, $count';
  }

  @override
  String get traitPhial => 'Frasco';

  @override
  String get traitShelling => 'Projéteis';

  @override
  String get traitKinsect => 'Inseto';

  @override
  String kinsectLevel(int level) {
    return 'Nível $level';
  }

  @override
  String get traitSongs => 'Músicas';

  @override
  String get weaponSectionAmmo => 'Munição';

  @override
  String get arcShot => 'Tiro de arco';

  @override
  String get chargeShots => 'Disparos por carga';

  @override
  String chargeLevel(int level) {
    return 'Carga $level';
  }

  @override
  String get needsSkill => 'precisa de habilidade';

  @override
  String get coatings => 'Revestimentos';

  @override
  String get ammoLevels => 'nível 1 · 2 · 3';

  @override
  String get ammoElementalLevels => 'normal · perfurante';

  @override
  String ammoCapacitySemantics(String ammo, String capacity) {
    return '$ammo: $capacity';
  }

  @override
  String get ammoNormal => 'Normal';

  @override
  String get ammoPierce => 'Perfurante';

  @override
  String get ammoSpread => 'Dispersão';

  @override
  String get ammoShrapnel => 'Estilhaço';

  @override
  String get ammoSticky => 'Adesiva';

  @override
  String get ammoCluster => 'Grupo';

  @override
  String get ammoFlaming => 'Fogo';

  @override
  String get ammoWater => 'Água';

  @override
  String get ammoThunder => 'Trovão';

  @override
  String get ammoFreeze => 'Gelo';

  @override
  String get ammoDragon => 'Dragão';

  @override
  String get ammoPoison => 'Veneno';

  @override
  String get ammoParalysis => 'Paralisia';

  @override
  String get ammoSleep => 'Sono';

  @override
  String get ammoExhaust => 'Exaustão';

  @override
  String get ammoRecover => 'Recuperação';

  @override
  String get ammoDemon => 'Demoníaca';

  @override
  String get ammoArmor => 'Blindagem';

  @override
  String get ammoSlicing => 'Cortante';

  @override
  String get ammoWyvern => 'Serpe';

  @override
  String get ammoTranq => 'Tranquilizante';

  @override
  String gatheringMaps(String kind, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mapas',
      one: '1 mapa',
    );
    return '$kind · $_temp0';
  }

  @override
  String gatheringAt(String kind, String map) {
    return '$kind · $map';
  }

  @override
  String smallMonster(String monster) {
    return '$monster · pequeno';
  }

  @override
  String questChip(String stars) {
    return 'Missão · $stars★';
  }

  @override
  String questsChip(int count) {
    return '$count missões';
  }

  @override
  String get unknownOrigin => 'Origem desconhecida';

  @override
  String sourcesGathering(String kind, String rank) {
    return '$kind · Rank $rank';
  }

  @override
  String sourcesMonsters(String rank) {
    return 'Monstros · Rank $rank';
  }

  @override
  String get sourcesQuests => 'Missões';

  @override
  String get showSources => 'Mostrar de onde vem';

  @override
  String get hideSources => 'Esconder de onde vem';

  @override
  String get armorTabSets => 'Conjuntos';

  @override
  String get armorTabSkills => 'Habilidades';

  @override
  String get armorTabDecorations => 'Joias';

  @override
  String get partHead => 'Cabeça';

  @override
  String get partChest => 'Tronco';

  @override
  String get partArms => 'Braços';

  @override
  String get partWaist => 'Cintura';

  @override
  String get partLegs => 'Pernas';

  @override
  String get armorSectionDefense => 'Defesa';

  @override
  String get armorSectionSkills => 'Habilidades';

  @override
  String get armorSectionPieces => 'Peças';

  @override
  String get skillSectionLevels => 'Níveis';

  @override
  String get skillSectionDecorations => 'Joias';

  @override
  String get skillSectionArmor => 'Armaduras';

  @override
  String get decorationSectionSkill => 'Habilidade';

  @override
  String get defenseBase => 'Defesa';

  @override
  String defenseRange(int base, int max) {
    return '$base → $max';
  }

  @override
  String resistancesSemantics(String values) {
    return 'Resistências: $values';
  }

  @override
  String skillLevelShort(int level) {
    return 'Nv $level';
  }

  @override
  String skillMaxLevel(int level) {
    return 'máx. $level';
  }

  @override
  String skillLevelOf(String skill, int level, int max) {
    return '$skill, nível $level de $max';
  }

  @override
  String skillOverflow(int extra) {
    return '+$extra';
  }

  @override
  String piecesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças',
      one: '1 peça',
    );
    return '$_temp0';
  }

  @override
  String setSkillsFooter(String skills) {
    return 'Conjunto: $skills';
  }

  @override
  String slotLevelTitle(int level) {
    return 'Slot nível $level';
  }

  @override
  String get allSlots => 'Todas';

  @override
  String get searchArmorHint => 'Buscar conjunto ou habilidade';

  @override
  String get searchSkillHint => 'Buscar habilidade';

  @override
  String get searchDecorationHint => 'Buscar joia';

  @override
  String get armorLoadFailed => 'Não foi possível carregar as armaduras.';

  @override
  String get noSetsFound => 'Nenhum conjunto encontrado';

  @override
  String get noSkillsFound => 'Nenhuma habilidade encontrada';

  @override
  String get noDecorationsFound => 'Nenhuma joia encontrada';

  @override
  String seeAllPieces(int count) {
    return 'Ver todas ($count)';
  }

  @override
  String get selectArmorItem => 'Escolha um item na lista';

  @override
  String get weaponSectionRampage => 'Habilidades Rampage';

  @override
  String get rampageChooseOne => 'escolha uma';

  @override
  String get rampageTitle => 'Rampage';

  @override
  String get rampageSlotRow => 'Slot Rampage';

  @override
  String get rampageDecorationsFit => 'Joias Rampage que cabem';

  @override
  String get gatherAny => 'Coleta';

  @override
  String get gatherOre => 'Mineração';

  @override
  String get gatherBone => 'Pilha de ossos';

  @override
  String get gatherBug => 'Inseto';

  @override
  String get gatherPlant => 'Planta';

  @override
  String get gatherFish => 'Pesca';

  @override
  String gatherNoMap(String kind) {
    return '$kind · mapa não informado';
  }

  @override
  String get assistantTabRecommended => 'Recomendadas';

  @override
  String get assistantTabSaved => 'Minhas builds';

  @override
  String get assistantTabBuild => 'Montar build';

  @override
  String get whereAreYou => 'Onde você está?';

  @override
  String get rankPost => 'Pós-jogo';

  @override
  String progressStar(String step) {
    return '$step★';
  }

  @override
  String progressBand(String band) {
    return 'MR $band+';
  }

  @override
  String stageFrom(String stage) {
    return 'A partir de $stage';
  }

  @override
  String stageSemantics(String stage) {
    return 'Disponível a partir de $stage';
  }

  @override
  String get buildsNow => 'Para agora';

  @override
  String get buildsNext => 'Próximas';

  @override
  String get noBuildsNow =>
      'Nenhuma build pronta para este ponto; veja as próximas.';

  @override
  String get noBuildsAtAll => 'Nenhuma build pronta para esta arma.';

  @override
  String get buildSectionEquipment => 'Equipamento';

  @override
  String get buildSectionSkills => 'Habilidades';

  @override
  String get buildSectionDecorations => 'Joias';

  @override
  String get partWeapon => 'Arma';

  @override
  String get partTalisman => 'Talismã';

  @override
  String alternativePiece(String name) {
    return 'ou $name';
  }

  @override
  String get notInCatalog => 'não encontrado no catálogo';

  @override
  String get saveBuild => 'Salvar em Minhas builds';

  @override
  String get buildSaved => 'Build salva em Minhas builds';

  @override
  String savedFrom(String name) {
    return 'baseada em: $name';
  }

  @override
  String get renameBuild => 'Renomear';

  @override
  String get deleteBuild => 'Excluir';

  @override
  String deleteBuildConfirm(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get buildName => 'Nome da build';

  @override
  String get noSavedBuilds =>
      'Nenhuma build salva. Abra uma build em Recomendadas e toque em \"Salvar em Minhas builds\".';

  @override
  String get buildsLoadFailed => 'Não foi possível carregar as builds.';

  @override
  String buildSourceNote(String source) {
    return 'Fonte: $source. Os aprimoramentos (Qurious) da guia não entram.';
  }

  @override
  String get openSource => 'Abrir a fonte';

  @override
  String get selectBuild => 'Escolha uma build na lista';

  @override
  String get afterStory => 'Depois da história';

  @override
  String get skillsWanted => 'Habilidades que você quer';

  @override
  String get searchSkill => 'Buscar habilidade…';

  @override
  String commonForType(String type) {
    return 'Comuns para $type';
  }

  @override
  String addSkill(String skill) {
    return 'Adicionar $skill';
  }

  @override
  String increaseSkill(String skill) {
    return 'Aumentar $skill';
  }

  @override
  String decreaseSkill(String skill) {
    return 'Diminuir $skill';
  }

  @override
  String removeSkill(String skill) {
    return 'Remover $skill';
  }

  @override
  String get weaponAndTalismans => 'Arma e talismãs';

  @override
  String get weaponLabel => 'Arma';

  @override
  String anyWeaponUpTo(String type, String progress) {
    return 'Qualquer $type até $progress';
  }

  @override
  String get anyWeapon => 'Qualquer';

  @override
  String get chooseWeapon => 'escolher';

  @override
  String get searchWeapon => 'Buscar arma…';

  @override
  String get myTalismans => 'Meus talismãs';

  @override
  String talismansCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cadastrados',
      one: '1 cadastrado',
      zero: 'nenhum cadastrado',
    );
    return '$_temp0';
  }

  @override
  String get useTalismans => 'usar todos';

  @override
  String get manage => 'gerenciar';

  @override
  String get onlyMyProgress => 'Só peças do meu progresso';

  @override
  String upToRarity(String progress, int rarity) {
    return 'até $progress (raridade $rarity)';
  }

  @override
  String get buildIt => 'Montar build';

  @override
  String get alter => 'alterar';

  @override
  String get edit => 'editar';

  @override
  String get searching => 'procurando…';

  @override
  String searchingChecked(int count) {
    return '$count combinações';
  }

  @override
  String skillsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habilidades',
      one: '1 habilidade',
    );
    return '$_temp0';
  }

  @override
  String setsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conjuntos encontrados',
      one: '1 conjunto encontrado',
    );
    return '$_temp0';
  }

  @override
  String optionN(int n) {
    return 'Opção $n';
  }

  @override
  String get setComplete => 'completa';

  @override
  String get setAlmost => 'quase';

  @override
  String missingN(int n) {
    return 'falta $n';
  }

  @override
  String skillGot(String skill, int got, int want) {
    return '$skill $got/$want';
  }

  @override
  String maxDefense(int defense) {
    return 'Defesa máx. $defense';
  }

  @override
  String get freeSlots => 'sobram';

  @override
  String get noTalisman => 'nenhum';

  @override
  String weaponWithTalisman(String weapon, String talisman) {
    return '$weapon · talismã $talisman';
  }

  @override
  String alsoComes(String skills) {
    return 'Também vem: $skills';
  }

  @override
  String get requestedSkills => 'Habilidades pedidas';

  @override
  String resultOf(int n, int total) {
    return '$n de $total';
  }

  @override
  String get resultsBack => 'Resultados';

  @override
  String get yourTalisman => 'Talismã (seu)';

  @override
  String get noBuildSets =>
      'Nenhum conjunto chega perto. Tente baixar níveis ou desligar \"Só peças do meu progresso\".';

  @override
  String get rankingNote =>
      'Ordenados por: atinge tudo, depois mais slots livres, depois defesa.';

  @override
  String get chooseSkills => 'Escolha ao menos uma habilidade.';

  @override
  String get optimizerLoadFailed =>
      'Não foi possível carregar os dados do Montar build.';

  @override
  String get talismansTitle => 'Meus talismãs';

  @override
  String get talismansNote => 'Usados pelo Montar build. Ficam no aparelho.';

  @override
  String get registered => 'Cadastrados';

  @override
  String get newTalisman => 'Novo talismã';

  @override
  String get editTalisman => 'Editar talismã';

  @override
  String get skillOne => 'Habilidade 1';

  @override
  String get skillTwoOptional => 'Habilidade 2 (opcional)';

  @override
  String get noneSkill => 'nenhuma';

  @override
  String slotN(int n) {
    return 'Slot $n';
  }

  @override
  String get emptySlot => 'vazio';

  @override
  String get saveTalisman => 'Salvar talismã';

  @override
  String get deleteTalisman => 'Excluir talismã';

  @override
  String deleteTalismanConfirm(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get noTalismans => 'Nenhum talismã cadastrado.';

  @override
  String skillProgressSemantics(String skill, int got, int want) {
    return '$skill, $got de $want';
  }

  @override
  String skillMissingSemantics(String skill, int got, int want, int missing) {
    return '$skill, $got de $want, faltam $missing';
  }

  @override
  String get optimizerSource => 'Caderninho · Montar build';

  @override
  String get phialLabel => 'Frasco';

  @override
  String get shellingLabel => 'Bombardeio';

  @override
  String get elementOrStatus => 'Elemento ou status';

  @override
  String get noElement => 'Sem elemento';

  @override
  String noWeaponForFilter(String progress) {
    return 'Nenhuma arma com esse filtro até $progress.';
  }

  @override
  String get weaponSkills => 'Habilidades da arma';

  @override
  String get setBonus => 'Bônus do conjunto';

  @override
  String get groupBonusLabel => 'grupo';

  @override
  String piecesN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças',
      one: '1 peça',
    );
    return '$_temp0';
  }

  @override
  String setStepSemantics(String skill, String pieces, String name) {
    return '$skill, $pieces: $name';
  }

  @override
  String get skillKindWeapon => 'arma';

  @override
  String get skillKindArmor => 'armadura';

  @override
  String get skillKindSet => 'conjunto';

  @override
  String get skillKindGroup => 'grupo';

  @override
  String get decoKindAll => 'Todas';

  @override
  String get decoKindWeapon => 'De arma';

  @override
  String get decoKindArmor => 'De armadura';

  @override
  String get talismansTab => 'Talismãs';

  @override
  String get talismanRanks => 'Níveis';

  @override
  String get artianGroup => 'Artian';

  @override
  String get artianAnyElement => 'elemento à escolha';

  @override
  String get artianBuild => 'Monte a sua';

  @override
  String get artianElement => 'Elemento';

  @override
  String get artianNoElement => 'Nenhum';

  @override
  String artianParts(int count) {
    return 'Peças ($count)';
  }

  @override
  String get artianPartElement => 'Elemento';

  @override
  String get artianPartAttack => 'Ataque';

  @override
  String get artianPartAffinity => 'Afinidade';

  @override
  String artianReinforcement(int count) {
    return 'Reforços ($count)';
  }

  @override
  String artianBoostAttack(int value) {
    return 'Ataque +$value';
  }

  @override
  String artianBoostAffinity(int value) {
    return 'Afinidade +$value%';
  }

  @override
  String artianBoostElement(int value) {
    return 'Elemento +$value';
  }

  @override
  String artianBoostSharpness(int value) {
    return 'Afiação +$value';
  }

  @override
  String artianBoostAmmo(int value) {
    return 'Munição +$value';
  }

  @override
  String artianRemaining(int count) {
    return 'restam $count';
  }

  @override
  String get artianResult => 'Resultado';

  @override
  String get artianInfusion => 'com infusão';

  @override
  String get artianElementHint =>
      'O elemento vem de 2 peças iguais; 3 iguais dão infusão.';

  @override
  String get saveMyArtian => 'Salvar minha Artian';

  @override
  String get myArtianTag => 'minha';

  @override
  String get artianName => 'Nome da Artian';

  @override
  String get artianSaved => 'Artian salva';

  @override
  String deleteArtianConfirm(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String increaseLabel(String name) {
    return 'Aumentar $name';
  }

  @override
  String decreaseLabel(String name) {
    return 'Diminuir $name';
  }

  @override
  String get wildsLoadFailed => 'Não foi possível carregar os dados da Wilds.';

  @override
  String get gogmaGroup => 'Gogma · do Gogmazios';

  @override
  String get gogmaTag => 'Gogma';

  @override
  String gogmaFocus(String focus) {
    return 'Foco $focus';
  }

  @override
  String get focusAttack => 'Ataque';

  @override
  String get focusAffinity => 'Afinidade';

  @override
  String get focusElement => 'Elemento';

  @override
  String gogmaSubtitle(String type) {
    return '$type Artian Gogma';
  }

  @override
  String get gogmaFoci => 'Os três focos';

  @override
  String get gogmaFocusColumn => 'Foco';

  @override
  String get gogmaFocusHint => 'Toque num foco para ver os atributos dele.';

  @override
  String get gogmaHowTo => 'Como obter';

  @override
  String gogmaUpgrade(String base) {
    return 'Melhore uma Artian de Raridade 8 ($base)';
  }

  @override
  String get gogmaDevice => 'com um Tarred Device do foco escolhido';

  @override
  String get gogmaSource =>
      'O Tarred Device vem do Armamento Mutado, preso no corpo do Gogmazios: quebre as massas (sobretudo na fase gasosa). Só vem se você abater o monstro.';

  @override
  String get gogmaExtras =>
      'Também ganha uma habilidade bônus, uma de grupo e reforços mais fortes, sorteados no jogo. Não são simulados aqui.';

  @override
  String get openInMonsters => 'Abrir em Monstros';
}
