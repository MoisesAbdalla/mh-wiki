import 'package:flutter/material.dart';
import 'package:mh_wiki/app/app_shell.dart';
import 'package:mh_wiki/app/equipment_area.dart';
import 'package:mh_wiki/app/monster_weapons_card.dart';
import 'package:mh_wiki/app/weapons_of_monster.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';
import 'package:mh_wiki/features/armor/presentation/views/armor_page.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/optimizer_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/views/assistant_page.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_id.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_type_picker.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/core/presentation/material_droppers.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapons_page.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The app's home: the area shell plus the links between monsters, weapons
/// and armor (006 US2/US3, 010). Only this layer knows every feature.
class AppHome extends StatefulWidget {
  const AppHome({
    required this.monsters,
    required this.weapons,
    this.armor,
    this.wildsWeapons,
    this.wildsArmor,
    this.assistant,
    this.optimizer,
    this.actions,
    super.key,
  });

  final MonsterListController monsters;

  /// Rise: Sunbreak weapons and armor.
  final WeaponListController weapons;
  final ArmorController? armor;

  /// Wilds weapons and armor (010); without them the Wilds tabs are off.
  final WeaponListController? wildsWeapons;
  final ArmorController? wildsArmor;
  final AssistantController? assistant;
  final OptimizerController? optimizer;
  final List<Widget>? actions;

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  final _shell = AppShellController();
  final _weaponsGame = ValueNotifier(Game.riseSunbreak);
  final _armorGame = ValueNotifier(Game.riseSunbreak);
  final _indexes = <Game, (Object?, MonsterMaterialIndex)>{};

  /// A game's material index, rebuilt when the monsters reload.
  MonsterMaterialIndex index(Game game) {
    final monsters = widget.monsters.monsters;
    final cached = _indexes[game];
    if (cached != null && identical(cached.$1, monsters)) return cached.$2;
    final built = MonsterMaterialIndex(monsters, game: game);
    _indexes[game] = (monsters, built);
    return built;
  }

  final _sources = <Game, MaterialSourceLookup>{};

  MaterialSourceLookup sourcesOf(Game game) => _sources.putIfAbsent(
    game,
    () => MaterialSourceLookup(
      (id) => index(game).lookup(() => widget.monsters.language).droppersOf(id),
    ),
  );

  WeaponListController? weaponsOf(Game game) => switch (game) {
    Game.riseSunbreak => widget.weapons,
    Game.wilds => widget.wildsWeapons,
    Game.worldIceborne => null,
  };

  ArmorController? armorOf(Game game) => switch (game) {
    Game.riseSunbreak => widget.armor,
    Game.wilds => widget.wildsArmor,
    Game.worldIceborne => null,
  };

  @override
  void dispose() {
    _shell.dispose();
    _weaponsGame.dispose();
    _armorGame.dispose();
    super.dispose();
  }

  final _weaponsOf = <MonsterId, List<Weapon>>{};
  final _weaponsFrom = <Game, WeaponCatalog>{};

  /// The weapons made from [monster], cached per catalog.
  List<Weapon> _weaponsMadeFrom(Monster monster, WeaponCatalog catalog) {
    final game = monster.id.game;
    if (!identical(catalog, _weaponsFrom[game])) {
      _weaponsFrom[game] = catalog;
      _weaponsOf.removeWhere((id, _) => id.game == game);
    }
    return _weaponsOf.putIfAbsent(
      monster.id,
      () => index(game).weaponsUsingMaterialsOf(monster, catalog.weapons),
    );
  }

  /// "Armas feitas com ele" after a monster's own cards, for every game with
  /// weapons (006 US3, 010 FR-004).
  List<Widget> _extraSections(BuildContext context, Monster monster, int next) {
    final game = monster.id.game;
    final weapons = weaponsOf(game);
    if (weapons == null) return const [];
    return [
      ListenableBuilder(
        listenable: weapons,
        builder: (context, _) {
          final catalog = weapons.catalog;
          if (catalog == null) {
            // Weapons load on demand; the card appears once they do.
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => weapons.ensureLoaded(),
            );
            return const SizedBox.shrink();
          }
          final made = _weaponsMadeFrom(monster, catalog);
          return MonsterWeaponsCard(
            number: next,
            weapons: made,
            language: widget.monsters.language,
            onOpenWeapon: (w) => _openWeapons(game, () => weapons.select(w.id)),
            onSeeAll: () => _openWeapons(
              game,
              () => weapons.showOnly(
                {for (final w in made) w.id},
                AppLocalizations.of(context).weaponsOfMonster(
                  monster.name.resolve(widget.monsters.language),
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  /// Back to the list, then Armas on [game] with [change] applied. Monstros
  /// keeps its state.
  void _openWeapons(Game game, Future<void> Function() change) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _shell.open(AppArea.weapons);
    _weaponsGame.value = game;
    change();
  }

  /// A weapon skill (Wilds): its detail in Armaduras of that game.
  Future<void> _openSkill(Game game, String skillId) async {
    final armor = armorOf(game);
    if (armor == null) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    _shell.open(AppArea.armor);
    _armorGame.value = game;
    await armor.select(ArmorTab.skills, skillId);
  }

  /// "Dropado por": back to the list, then the monster's detail in Monstros.
  /// The Armas filters stay as they were.
  void _openMonster(MaterialDropper dropper) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _shell.open(AppArea.monsters);
    widget.monsters.select(monsterIdOf(dropper));
  }

  /// A build item from the Assistente: the weapon in Armas; a piece (its
  /// set), skill or decoration in Armaduras (008 US2). Builds are Rise.
  Future<void> _openFromBuild(CatalogRef ref) async {
    final id = ref.id;
    final armor = widget.armor;
    if (id == null) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    switch (ref.kind) {
      case RefKind.weapon:
        _shell.open(AppArea.weapons);
        _weaponsGame.value = Game.riseSunbreak;
        await widget.weapons.select(WeaponId(Game.riseSunbreak, id));
      case RefKind.piece when armor != null:
        _shell.open(AppArea.armor);
        _armorGame.value = Game.riseSunbreak;
        await armor.ensureLoaded();
        final set = armor.catalog?.sets.where(
          (s) => s.pieces.any((p) => p.id == id),
        );
        if (set != null && set.isNotEmpty) {
          await armor.select(ArmorTab.sets, set.first.id);
        }
      case RefKind.skill when armor != null:
        _shell.open(AppArea.armor);
        _armorGame.value = Game.riseSunbreak;
        await armor.select(ArmorTab.skills, id);
      case RefKind.decoration when armor != null:
        _shell.open(AppArea.armor);
        _armorGame.value = Game.riseSunbreak;
        await armor.select(ArmorTab.decorations, id);
      case _:
        break;
    }
  }

  /// The 006 type picker over the weapon catalog, which loads on demand.
  Widget _typePicker(
    BuildContext context,
    String selected,
    ValueChanged<String> onChanged,
  ) => ListenableBuilder(
    listenable: widget.weapons,
    builder: (context, _) {
      final catalog = widget.weapons.catalog;
      if (catalog == null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.weapons.ensureLoaded(),
        );
        return const SizedBox(height: 88);
      }
      return WeaponTypePicker(
        types: catalog.types,
        selectedId: selected,
        language: widget.weapons.language,
        onChanged: onChanged,
      );
    },
  );

  String _typeName(String id) {
    final types = widget.weapons.catalog?.types ?? const [];
    for (final t in types) {
      if (t.id == id) return t.name.resolve(widget.weapons.language);
    }
    return id;
  }

  Widget _weaponsPage(
    Game game,
    WeaponListController controller,
    Widget header,
  ) => WeaponsPage(
    controller: controller,
    actions: widget.actions,
    sources: sourcesOf(game),
    onOpenMonster: _openMonster,
    header: header,
    onOpenSkill: (id) => _openSkill(game, id),
  );

  Widget _armorPage(Game game, ArmorController controller, Widget header) =>
      ArmorPage(
        controller: controller,
        actions: widget.actions,
        sources: sourcesOf(game),
        onOpenMonster: _openMonster,
        header: header,
      );

  @override
  Widget build(BuildContext context) {
    final armor = widget.armor;
    final wildsWeapons = widget.wildsWeapons;
    final wildsArmor = widget.wildsArmor;
    return AppShell(
      controller: _shell,
      monsters: MonstersPage(
        controller: widget.monsters,
        actions: widget.actions,
        extraSections: _extraSections,
      ),
      assistant: switch (widget.assistant) {
        final assistant? => AssistantPage(
          controller: assistant,
          optimizer: widget.optimizer,
          actions: widget.actions,
          typePicker: _typePicker,
          typeName: _typeName,
          onOpen: _openFromBuild,
        ),
        null => const SizedBox.shrink(),
      },
      armor: armor == null
          ? const SizedBox.shrink()
          : EquipmentArea(
              game: _armorGame,
              pages: {
                Game.riseSunbreak: (h) =>
                    _armorPage(Game.riseSunbreak, armor, h),
                if (wildsArmor != null)
                  Game.wilds: (h) => _armorPage(Game.wilds, wildsArmor, h),
              },
            ),
      weapons: EquipmentArea(
        game: _weaponsGame,
        pages: {
          Game.riseSunbreak: (h) =>
              _weaponsPage(Game.riseSunbreak, widget.weapons, h),
          if (wildsWeapons != null)
            Game.wilds: (h) => _weaponsPage(Game.wilds, wildsWeapons, h),
        },
      ),
    );
  }
}
