import 'package:flutter/material.dart';
import 'package:mh_wiki/features/monsters/presentation/controllers/monster_list_controller.dart';
import 'package:mh_wiki/features/monsters/presentation/views/widgets/monster_detail_view.dart';

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
        final monster = controller.selectedMonster;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              monster?.name.resolve(controller.language) ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: monster == null
              ? const SizedBox.shrink()
              : MonsterDetailView(
                  monster: monster,
                  language: controller.language,
                ),
        );
      },
    );
  }
}
