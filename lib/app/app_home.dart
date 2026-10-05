import 'package:flutter/material.dart';
import 'package:mh_wiki/app/app_shell.dart';
import 'package:mh_wiki/app/monster_weapons_card.dart';
import 'package:mh_wiki/app/weapons_of_monster.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/armor/presentation/armor_controller.dart';
import 'package:mh_wiki/features/armor/presentation/views/armor_page.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';
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

/// The app's home: the area shell plus the links between monsters and
/// weapons (006 US2/US3). Only this layer knows both features.
class AppHome extends StatefulWidget {
  const AppHome({
    required this.monsters,
    required this.weapons,
    this.armor,
    this.assistant,
    this.actions,
    super.key,
  });

  final MonsterListController monsters;
  final WeaponListController weapons;
  final ArmorController? armor;
  final AssistantController? assistant;
  final List<Widget>? actions;

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  final _shell = AppShellController();
  MonsterMaterialIndex? _index;
  Object? _indexedFrom;

  /// Built on first use and rebuilt when the monsters reload.
  MonsterMaterialIndex get index {
    final monsters = widget.monsters.monsters;
    if (!identical(monsters, _indexedFrom)) {
      _indexedFrom = monsters;
      _index = MonsterMaterialIndex(monsters);
    }
    return _index!;
  }

  late final MaterialSourceLookup _sources = MaterialSourceLookup(
    (id) => index.lookup(() => widget.monsters.language).droppersOf(id),
  );

  @override
  void dispose() {
    _shell.dispose();
    super.dispose();
  }

  final _weaponsOf = <MonsterId, List<Weapon>>{};
  WeaponCatalog? _weaponsFrom;

  /// The weapons made from [monster], cached per catalog.
  List<Weapon> _weaponsMadeFrom(Monster monster, WeaponCatalog catalog) {
    if (!identical(catalog, _weaponsFrom)) {
      _weaponsFrom = catalog;
      _weaponsOf.clear();
    }
    return _weaponsOf.putIfAbsent(
      monster.id,
      () => index.weaponsUsingMaterialsOf(monster, catalog.weapons),
    );
  }

  /// "Armas feitas com ele" after a Rise monster's own cards (006 US3).
  List<Widget> _extraSections(BuildContext context, Monster monster, int next) {
    if (monster.id.game != Game.riseSunbreak) return const [];
    return [
      ListenableBuilder(
        listenable: widget.weapons,
        builder: (context, _) {
          final catalog = widget.weapons.catalog;
          if (catalog == null) {
            // Weapons load on demand; the card appears once they do.
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => widget.weapons.ensureLoaded(),
            );
            return const SizedBox.shrink();
          }
          final weapons = _weaponsMadeFrom(monster, catalog);
          return MonsterWeaponsCard(
            number: next,
            weapons: weapons,
            language: widget.monsters.language,
            onOpenWeapon: (w) =>
                _openWeapons(() => widget.weapons.select(w.id)),
            onSeeAll: () => _openWeapons(
              () => widget.weapons.showOnly(
                {for (final w in weapons) w.id},
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

  /// Back to the list, then Armas with [change] applied. Monstros keeps its
  /// state.
  void _openWeapons(Future<void> Function() change) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _shell.open(AppArea.weapons);
    change();
  }

  /// "Dropado por": back to the list, then the monster's detail in Monstros.
  /// The Armas filters stay as they were.
  void _openMonster(MaterialDropper dropper) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _shell.open(AppArea.monsters);
    widget.monsters.select(monsterIdOf(dropper));
  }

  /// A build item from the Assistente: the weapon in Armas; a piece (its
  /// set), skill or decoration in Armaduras (008 US2).
  Future<void> _openFromBuild(CatalogRef ref) async {
    final id = ref.id;
    final armor = widget.armor;
    if (id == null) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    switch (ref.kind) {
      case RefKind.weapon:
        _shell.open(AppArea.weapons);
        await widget.weapons.select(WeaponId(Game.riseSunbreak, id));
      case RefKind.piece when armor != null:
        _shell.open(AppArea.armor);
        await armor.ensureLoaded();
        final set = armor.catalog?.sets.where(
          (s) => s.pieces.any((p) => p.id == id),
        );
        if (set != null && set.isNotEmpty) {
          await armor.select(ArmorTab.sets, set.first.id);
        }
      case RefKind.skill when armor != null:
        _shell.open(AppArea.armor);
        await armor.select(ArmorTab.skills, id);
      case RefKind.decoration when armor != null:
        _shell.open(AppArea.armor);
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

  @override
  Widget build(BuildContext context) => AppShell(
    controller: _shell,
    monsters: MonstersPage(
      controller: widget.monsters,
      actions: widget.actions,
      extraSections: _extraSections,
    ),
    assistant: switch (widget.assistant) {
      final assistant? => AssistantPage(
        controller: assistant,
        actions: widget.actions,
        typePicker: _typePicker,
        typeName: _typeName,
        onOpen: _openFromBuild,
      ),
      null => const SizedBox.shrink(),
    },
    armor: switch (widget.armor) {
      final armor? => ArmorPage(
        controller: armor,
        actions: widget.actions,
        sources: _sources,
        onOpenMonster: _openMonster,
      ),
      null => const SizedBox.shrink(),
    },
    weapons: WeaponsPage(
      controller: widget.weapons,
      actions: widget.actions,
      sources: _sources,
      onOpenMonster: _openMonster,
    ),
  );
}
