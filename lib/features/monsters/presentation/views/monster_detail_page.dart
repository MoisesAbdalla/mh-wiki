import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/labels.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Full-screen detail used in the compact layout. Reads the selected monster
/// from the controller so language changes apply immediately.
class MonsterDetailPage extends StatelessWidget {
  const MonsterDetailPage({required this.controller, super.key});

  final MonsterListController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final monster = controller.selectedMonster;
        return Scaffold(
          // The name is the page's header; the bar names the game, since
          // there are no game tabs on this page (005 FR-009).
          appBar: AppBar(
            title: Text(
              monster == null ? '' : l10n.gameName(monster.id.game),
              overflow: TextOverflow.ellipsis,
              style: notebookTitle(size: 20, color: HunterPalette.textMuted),
            ),
          ),
          body: monster == null
              ? const SizedBox.shrink()
              : MonsterDetailView(
                  monster: monster,
                  language: controller.language,
                  versions: controller.selectedVersions,
                  onSelectVersion: controller.select,
                ),
        );
      },
    );
  }
}
