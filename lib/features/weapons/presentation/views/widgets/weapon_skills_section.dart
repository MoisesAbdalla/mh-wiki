import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/widgets/notebook_section.dart';
import 'package:mh_wiki/core/presentation/widgets/ruled_row.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// "Habilidades da arma" (Wilds, 010 FR-003): each skill with pips up to its
/// max; a tap opens the skill in Armaduras.
class WeaponSkillsSection extends StatelessWidget {
  const WeaponSkillsSection({
    required this.skills,
    required this.number,
    this.onOpenSkill,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final List<WeaponSkill> skills;
  final int number;
  final ValueChanged<String>? onOpenSkill;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NotebookSection(
      number: number,
      title: l10n.weaponSkills,
      child: Column(
        children: [
          for (final (i, s) in skills.indexed)
            Semantics(
              button: onOpenSkill != null,
              label: l10n.skillLevelOf(
                s.name.resolve(language),
                s.level,
                s.max,
              ),
              excludeSemantics: true,
              child: InkWell(
                onTap: onOpenSkill == null ? null : () => onOpenSkill!(s.id),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: RuledRow(
                    ruled: i < skills.length - 1,
                    label: Text(s.name.resolve(language)),
                    trailing: _Pips(level: s.level, max: s.max),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pips extends StatelessWidget {
  const _Pips({required this.level, required this.max});

  final int level;
  final int max;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 3,
    children: [
      for (var i = 1; i <= max; i++)
        Container(
          key: ValueKey(('weapon-skill-pip', i, i <= level)),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: i <= level ? HunterPalette.gold : null,
            border: Border.all(
              color: i <= level ? HunterPalette.gold : HunterPalette.border,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
    ],
  );
}
