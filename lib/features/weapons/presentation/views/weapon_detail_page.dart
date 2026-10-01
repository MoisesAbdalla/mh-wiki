import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_switcher.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/weapon_list_controller.dart';
import 'package:mh_wiki/core/presentation/material_droppers.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_detail_view.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Full-screen detail used in the compact layout.
class WeaponDetailPage extends StatelessWidget {
  const WeaponDetailPage({
    required this.controller,
    this.sources = MaterialSourceLookup.empty,
    this.onOpenMonster,
    super.key,
  });

  final WeaponListController controller;
  final MaterialSourceLookup sources;
  final ValueChanged<MaterialDropper>? onOpenMonster;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final weapon = controller.selectedWeapon;
        final catalog = controller.catalog;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              weapon == null ? '' : l10n.gameName(weapon.id.game),
              overflow: TextOverflow.ellipsis,
              style: notebookTitle(color: HunterPalette.textMuted),
            ),
          ),
          body: weapon == null || catalog == null
              ? const SizedBox.shrink()
              : NotebookSwitcher(
                  child: WeaponDetailView(
                    key: ValueKey(weapon.id),
                    weapon: weapon,
                    catalog: catalog,
                    onSelectWeapon: (w) => controller.select(w.id),
                    sources: sources,
                    onOpenMonster: onOpenMonster,
                    language: controller.language,
                  ),
                ),
        );
      },
    );
  }
}
