import 'package:flutter/material.dart';
import 'package:mh_wiki/app/app_shell.dart';
import 'package:mh_wiki/app/monster_weapons_card.dart';
import 'package:mh_wiki/app/weapons_of_monster.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster.dart';
import 'package:mh_wiki/features/monsters/domain/entities/monster_id.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/monsters_page.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_catalog.dart';
import 'package:mh_wiki/features/weapons/presentation/material_sources.dart';
import 'package:mh_wiki/features/weapons/presentation/views/weapons_page.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) => AppShell(
    controller: _shell,
    monsters: MonstersPage(
      controller: widget.monsters,
      actions: widget.actions,
      extraSections: _extraSections,
    ),
    weapons: WeaponsPage(
      controller: widget.weapons,
      actions: widget.actions,
      sources: _sources,
      onOpenMonster: _openMonster,
    ),
  );
}
