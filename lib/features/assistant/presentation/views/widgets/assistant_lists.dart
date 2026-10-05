import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/features/assistant/domain/entities/curated_build.dart';
import 'package:mh_wiki/features/assistant/presentation/assistant_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/assistant_labels.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/build_card.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/progress_picker.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Builds the weapon type picker for the chosen type (the one from 006,
/// handed in by the app so this feature does not know Armas).
typedef TypePickerBuilder = Widget Function(
  BuildContext context,
  String selected,
  ValueChanged<String> onChanged,
);

/// Recomendadas (008 US1): "Onde você está?", the type picker, then "Para
/// agora" and "Próximas".
class RecommendedList extends StatelessWidget {
  const RecommendedList({
    required this.controller,
    this.typePicker,
    this.highlightSelection = false,
    super.key,
  });

  final AssistantController controller;
  final TypePickerBuilder? typePicker;
  final bool highlightSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = controller;
    final picker = typePicker;
    final selected = c.selection;
    Widget card(CuratedBuild b, {String? next}) => BuildCard(
      key: ValueKey(('build', b.id)),
      curated: b,
      language: c.language,
      availableFrom: next,
      selected:
          highlightSelection && selected?.saved == null && selected?.build == b,
      onTap: () => c.select(b),
    );

    final body = <Widget>[];
    switch (c.state) {
      case AssistantLoading():
        body.add(
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      case AssistantFailed():
        body.add(_Failed(onRetry: c.load));
      case AssistantLoaded(:final now, :final next):
        if (now.isEmpty && next.isEmpty) {
          body.add(_Empty(l10n.noBuildsAtAll));
        } else {
          body
            ..add(ListCaption(l10n.buildsNow))
            ..addAll(
              now.isEmpty
                  ? [_Empty(l10n.noBuildsNow)]
                  : [for (final b in now) card(b)],
            );
          if (next.isNotEmpty) {
            body
              ..add(ListCaption(l10n.buildsNext))
              ..addAll([
                for (final b in next)
                  card(b, next: availableFrom(l10n, b.stage)),
              ]);
          }
        }
    }

    return ListView(
      key: const PageStorageKey('assistant-recommended'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ProgressPicker(progress: c.progress, onChanged: c.setProgress),
        if (picker != null) picker(context, c.weaponType, c.setWeaponType),
        ...body,
      ],
    );
  }
}

/// Minhas builds (008 US3).
class SavedBuildsList extends StatelessWidget {
  const SavedBuildsList({
    required this.controller,
    this.highlightSelection = false,
    super.key,
  });

  final AssistantController controller;
  final bool highlightSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = controller;
    final saved = c.savedBuilds;
    if (saved.isEmpty) {
      return ListView(children: [_Empty(l10n.noSavedBuilds)]);
    }
    final date = DateFormat('dd/MM/yyyy');
    return ListView(
      key: const PageStorageKey('assistant-saved'),
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      children: [
        for (final s in saved)
          BuildCard(
            key: ValueKey(('saved', s.id)),
            curated: s.build,
            language: c.language,
            title: s.name,
            subtitle:
                '${l10n.savedFrom(s.build.name)} · ${date.format(s.savedAt)}',
            selected: highlightSelection && c.selection?.saved?.id == s.id,
            onTap: () => c.selectSaved(s),
          ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter + 4, 12, gutter, 12),
      child: EmptySectionText(text),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            l10n.buildsLoadFailed,
            textAlign: TextAlign.center,
            style: notebookTitle(size: 18, color: HunterPalette.textMuted),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
