import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
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
          children: [
            ListTile(
              title: Text(
                l10n.nameLanguageTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(l10n.nameLanguageDescription),
            ),
            RadioGroup<NameLanguage>(
              groupValue: widget.controller.settings.nameLanguage,
              onChanged: (value) {
                if (value != null) widget.controller.setNameLanguage(value);
              },
              child: Column(
                children: [
                  RadioListTile<NameLanguage>(
                    value: NameLanguage.ptBr,
                    title: Text(l10n.nameLanguagePtBr),
                  ),
                  RadioListTile<NameLanguage>(
                    value: NameLanguage.en,
                    title: Text(l10n.nameLanguageEn),
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
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(controller: controller),
      ),
    ),
  );
}
