import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/features/settings/presentation/settings_controller.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.controller, super.key});

  final SettingsController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_showSaveFailure);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_showSaveFailure);
    super.dispose();
  }

  void _showSaveFailure() {
    if (!widget.controller.saveFailed || !mounted) return;
    widget.controller.acknowledgeSaveFailure();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).saveFailed)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.only(top: 24),
          children: [
            NotebookSection(
              title: l10n.nameLanguageTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.nameLanguageDescription,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: HunterPalette.textMuted),
                  ),
                  const SizedBox(height: 8),
                  RadioGroup<NameLanguage>(
                    groupValue: widget.controller.settings.nameLanguage,
                    onChanged: (value) {
                      if (value != null) {
                        widget.controller.setNameLanguage(value);
                      }
                    },
                    child: Column(
                      children: [
                        _RuledOption(
                          value: NameLanguage.ptBr,
                          label: l10n.nameLanguagePtBr,
                        ),
                        _RuledOption(
                          value: NameLanguage.en,
                          label: l10n.nameLanguageEn,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// App bar action that opens [SettingsPage].
class SettingsButton extends StatelessWidget {
  const SettingsButton({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context).settingsTitle,
    icon: const Icon(Icons.settings_outlined),
    style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(controller: controller),
      ),
    ),
  );
}

/// A radio choice drawn as a ruled row, without a panel (005 FR-003).
class _RuledOption extends StatelessWidget {
  const _RuledOption({required this.value, required this.label});

  final NameLanguage value;
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: HunterPalette.borderSubtle)),
    ),
    child: RadioListTile<NameLanguage>(
      value: value,
      title: Text(label),
      contentPadding: EdgeInsets.zero,
    ),
  );
}
