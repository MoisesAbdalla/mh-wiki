import 'package:flutter/material.dart';
import 'package:mh_wiki/app/app_shell.dart';
import 'package:mh_wiki/app/weapons_of_monster.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/material_sources.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapons_page.dart';

/// The app's home: the area shell plus the links between monsters and
/// weapons (006 US2/US3). Only this layer knows both features.
class AppHome extends StatefulWidget {
  const AppHome({
    required this.monsters,
    required this.weapons,
    this.actions,
    super.key,
  });

  final MonsterListController monsters;
  final WeaponListController weapons;
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

  /// "Dropado por": back to the list, then the monster's detail in Monstros.
  /// The Armas filters stay as they were.
  void _openMonster(MaterialDropper dropper) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _shell.open(AppArea.monsters);
    widget.monsters.select(monsterIdOf(dropper));
  }

  @override
  Widget build(BuildContext context) => AppShell(
    controller: _shell,
    monsters: MonstersPage(
      controller: widget.monsters,
      actions: widget.actions,
    ),
    weapons: WeaponsPage(
      controller: widget.weapons,
      actions: widget.actions,
      sources: _sources,
      onOpenMonster: _openMonster,
    ),
  );
}
