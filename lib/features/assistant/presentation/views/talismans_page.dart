import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/slot_icon.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/build_request.dart';
import 'package:mh_wiki/features/assistant/domain/optimizer/optimizer_catalog.dart';
import 'package:mh_wiki/features/assistant/presentation/optimizer_controller.dart';
import 'package:mh_wiki/features/assistant/presentation/views/widgets/build_detail_view.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Meus talismãs (009 US3): the list and the form to add or edit one.
class TalismansPage extends StatefulWidget {
  const TalismansPage({required this.controller, super.key});

  final OptimizerController controller;

  @override
  State<TalismansPage> createState() => _TalismansPageState();
}

class _TalismansPageState extends State<TalismansPage> {
  /// The talisman being edited, or null for a new one.
  String? _editing;
  final _form = GlobalKey<_TalismanFormState>();

  OptimizerController get _c => widget.controller;

  Future<void> _delete(UserTalisman t) async {
    final l10n = AppLocalizations.of(context);
    final name = _describe(t);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteTalismanConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.deleteBuild,
              style: const TextStyle(color: HunterPalette.negative),
            ),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await _c.deleteTalisman(t.id);
      if (_editing == t.id) setState(() => _editing = null);
    }
  }

  String _describe(UserTalisman t) {
    final skills = _c.catalog?.skills ?? const {};
    final language = _c.assistant.language;
    return [
      for (final e in t.skills.entries)
        '${skills[e.key]?.name.resolve(language) ?? e.key} ${e.value}',
    ].join(' + ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) {
        final list = _c.talismans;
        final editing = [
          for (final t in list)
            if (t.id == _editing) t,
        ].firstOrNull;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.talismansTitle)),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(gutter + 4, 4, gutter, 12),
                child: Text(
                  l10n.talismansNote,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: HunterPalette.textMuted),
                ),
              ),
              NotebookSection(
                title: l10n.registered,
                child: list.isEmpty
                    ? EmptySectionText(l10n.noTalismans)
                    : Column(
                        children: [
                          for (final (i, t) in list.indexed)
                            _TalismanRow(
                              key: ValueKey(('talisman', t.id)),
                              text: _describe(t),
                              talisman: t,
                              ruled: i < list.length - 1,
                              onEdit: () => setState(() => _editing = t.id),
                              onDelete: () => _delete(t),
                            ),
                        ],
                      ),
              ),
              NotebookSection(
                title: editing == null ? l10n.newTalisman : l10n.editTalisman,
                child: _TalismanForm(
                  key: _form,
                  initial: editing,
                  skills: _c.catalog?.skills.values.toList() ?? const [],
                  language: _c.assistant.language,
                  onSave: (skills, slots) async {
                    final t = UserTalisman(
                      id: editing?.id ?? _c.newTalismanId(),
                      skills: skills,
                      slots: slots,
                    );
                    await _c.saveTalisman(t);
                    setState(() => _editing = null);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TalismanRow extends StatelessWidget {
  const _TalismanRow({
    required this.text,
    required this.talisman,
    required this.ruled,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final String text;
  final UserTalisman talisman;
  final bool ruled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: ruled
            ? const Border(
                bottom: BorderSide(color: HunterPalette.borderSubtle),
              )
            : null,
      ),
      child: InkWell(
        onTap: onEdit,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              Image.asset(
                partIcon('talisman', 10),
                width: 32,
                height: 32,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => const SizedBox(width: 32),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: notebookTitle(size: 16))),
              for (final s in talisman.slots)
                s == 0
                    ? const SizedBox(
                        width: 16,
                        child: Text(
                          '–',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: HunterPalette.textDisabled),
                        ),
                      )
                    : SlotIcon(level: s, size: 16),
              IconButton(
                tooltip: l10n.deleteTalisman,
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: HunterPalette.textDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skill 1 with level, skill 2 (optional) with level, and three slots 0–4.
class _TalismanForm extends StatefulWidget {
  const _TalismanForm({
    required this.initial,
    required this.skills,
    required this.language,
    required this.onSave,
    super.key,
  });

  final UserTalisman? initial;
  final List<OptimizerSkill> skills;
  final NameLanguage language;
  final Future<void> Function(Map<String, int> skills, List<int> slots) onSave;

  @override
  State<_TalismanForm> createState() => _TalismanFormState();
}

class _TalismanFormState extends State<_TalismanForm> {
  String? _skill1;
  int _level1 = 1;
  String? _skill2;
  int _level2 = 1;
  List<int> _slots = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    _load(widget.initial);
  }

  @override
  void didUpdateWidget(_TalismanForm old) {
    super.didUpdateWidget(old);
    if (old.initial?.id != widget.initial?.id) _load(widget.initial);
  }

  void _load(UserTalisman? t) {
    final entries = t?.skills.entries.toList() ?? const [];
    _skill1 = entries.isNotEmpty ? entries[0].key : null;
    _level1 = entries.isNotEmpty ? entries[0].value : 1;
    _skill2 = entries.length > 1 ? entries[1].key : null;
    _level2 = entries.length > 1 ? entries[1].value : 1;
    _slots = [...?t?.slots, 0, 0, 0].take(3).toList();
  }

  int _max(String? id) =>
      widget.skills.where((s) => s.id == id).firstOrNull?.max ?? 1;

  Future<String?> _pickSkill(BuildContext context, {required bool optional}) =>
      showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: HunterPalette.panel,
        builder: (_) => _SkillPicker(
          skills: widget.skills,
          language: widget.language,
          optional: optional,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String nameOf(String? id) =>
        widget.skills
            .where((s) => s.id == id)
            .firstOrNull
            ?.name
            .resolve(widget.language) ??
        l10n.noneSkill;

    Widget skillField({
      required String label,
      required String? value,
      required int level,
      required bool optional,
      required ValueChanged<String?> onSkill,
      required ValueChanged<int> onLevel,
    }) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: HunterPalette.textMuted),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            OutlinedButton(
              onPressed: () async {
                final picked = await _pickSkill(context, optional: optional);
                if (picked == null) return;
                onSkill(picked.isEmpty ? null : picked);
              },
              child: Text('${nameOf(value)} ▾'),
            ),
            if (value != null) ...[
              IconButton(
                tooltip: l10n.decreaseSkill(nameOf(value)),
                onPressed: level > 1 ? () => onLevel(level - 1) : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$level', style: notebookNumber(size: 15, bold: true)),
              IconButton(
                tooltip: l10n.increaseSkill(nameOf(value)),
                onPressed: level < _max(value)
                    ? () => onLevel(level + 1)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        skillField(
          label: l10n.skillOne,
          value: _skill1,
          level: _level1,
          optional: false,
          onSkill: (v) => setState(() {
            _skill1 = v;
            _level1 = _level1.clamp(1, _max(v));
          }),
          onLevel: (v) => setState(() => _level1 = v),
        ),
        skillField(
          label: l10n.skillTwoOptional,
          value: _skill2,
          level: _level2,
          optional: true,
          onSkill: (v) => setState(() {
            _skill2 = v == _skill1 ? null : v;
            _level2 = _level2.clamp(1, _max(v));
          }),
          onLevel: (v) => setState(() => _level2 = v),
        ),
        for (var i = 0; i < 3; i++) ...[
          Text(
            l10n.slotN(i + 1),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: HunterPalette.textMuted),
          ),
          const SizedBox(height: 4),
          SegmentedButton<int>(
            key: Key('slot-$i'),
            showSelectedIcon: false,
            segments: [
              for (var v = 0; v <= 4; v++)
                ButtonSegment(
                  value: v,
                  label: Text(v == 0 ? '–' : '$v'),
                  tooltip: v == 0 ? l10n.emptySlot : l10n.slotN(v),
                ),
            ],
            selected: {_slots[i]},
            onSelectionChanged: (s) => setState(() => _slots[i] = s.first),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 4),
        OutlinedButton(
          key: const Key('save-talisman'),
          style: OutlinedButton.styleFrom(
            foregroundColor: HunterPalette.gold,
            side: const BorderSide(color: HunterPalette.gold),
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _skill1 == null
              ? null
              : () => widget.onSave({
                  _skill1!: _level1,
                  if (_skill2 case final s2? when s2 != _skill1) s2: _level2,
                }, _slots),
          child: Text(
            l10n.saveTalisman,
            style: notebookTitle(size: 16, color: HunterPalette.gold),
          ),
        ),
      ],
    );
  }
}

/// A searchable skill list; returns the id, or "" for "nenhuma".
class _SkillPicker extends StatefulWidget {
  const _SkillPicker({
    required this.skills,
    required this.language,
    required this.optional,
  });

  final List<OptimizerSkill> skills;
  final NameLanguage language;
  final bool optional;

  @override
  State<_SkillPicker> createState() => _SkillPickerState();
}

class _SkillPickerState extends State<_SkillPicker> {
  String _text = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final q = _text.trim().toLowerCase();
    final list =
        [
          for (final s in widget.skills)
            if (q.isEmpty ||
                s.name.resolve(widget.language).toLowerCase().contains(q) ||
                s.name.en.toLowerCase().contains(q))
              s,
        ]..sort(
          (a, b) => a.name
              .resolve(widget.language)
              .compareTo(b.name.resolve(widget.language)),
        );
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                key: const Key('talisman-skill-search'),
                autofocus: true,
                onChanged: (v) => setState(() => _text = v),
                decoration: InputDecoration(
                  hintText: l10n.searchSkill,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  if (widget.optional)
                    ListTile(
                      title: Text(l10n.noneSkill),
                      onTap: () => Navigator.of(context).pop(''),
                    ),
                  for (final s in list)
                    ListTile(
                      title: Text(s.name.resolve(widget.language)),
                      onTap: () => Navigator.of(context).pop(s.id),
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
