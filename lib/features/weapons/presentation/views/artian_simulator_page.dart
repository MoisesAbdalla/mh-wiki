import 'package:flutter/material.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/gogma_artian_view.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_switcher.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/artian_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/artian_simulator_view.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The simulator for the open Artian, or `null` when none is open.
Widget? artianSimulatorFor(
  WeaponListController weapons,
  ArtianController artians, {
  VoidCallback? onOpenGogmazios,
}) {
  final selection = artians.selection;
  final catalog = weapons.catalog;
  if (selection == null || catalog == null) return null;
  final type = catalog.artianOf(selection.type);
  if (selection.focus case final focus?) {
    final weapon = catalog.gogma(selection.type, focus);
    if (weapon == null) return null;
    return GogmaArtianView(
      key: ValueKey(('gogma', weapon.id)),
      weapon: weapon,
      foci: catalog.gogmaOf(selection.type),
      base: type?.base(8),
      onFocus: (f) => artians.openGogma(selection.type, f),
      onOpenGogmazios: onOpenGogmazios,
      language: weapons.language,
    );
  }
  if (type == null || type.base(selection.rarity) == null) return null;
  final mine = artians.selectedMine;
  return ArtianSimulatorView(
    key: ValueKey(('artian', selection.type, selection.rarity, mine?.id)),
    type: type,
    rarity: selection.rarity,
    catalog: catalog,
    artians: artians,
    mine: mine,
    language: weapons.language,
  );
}

/// Full-screen simulator used in the compact layout.
class ArtianSimulatorPage extends StatelessWidget {
  const ArtianSimulatorPage({
    required this.weapons,
    required this.artians,
    this.onOpenGogmazios,
    super.key,
  });

  final WeaponListController weapons;
  final ArtianController artians;
  final VoidCallback? onOpenGogmazios;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([weapons, artians]),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            '${l10n.gameName(Game.wilds)} · ${l10n.artianGroup}',
            overflow: TextOverflow.ellipsis,
            style: notebookTitle(color: HunterPalette.textMuted),
          ),
        ),
        body: NotebookSwitcher(
          child:
              artianSimulatorFor(
                weapons,
                artians,
                onOpenGogmazios: onOpenGogmazios,
              ) ??
              const SizedBox.shrink(),
        ),
      ),
    );
  }
}
