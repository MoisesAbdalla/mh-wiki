import 'package:flutter/material.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/weapon_row.dart';
import 'package:mh_wiki/features/weapons/presentation/views/widgets/gogma_artian_view.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon.dart';
import 'package:mh_wiki/core/domain/game.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/presentation/game_icons.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/core/presentation/widgets/monster_image.dart';
import 'package:mh_wiki/features/weapons/domain/entities/artian.dart';
import 'package:mh_wiki/features/weapons/domain/entities/special_kind.dart';
import 'package:mh_wiki/features/weapons/presentation/controllers/artian_controller.dart';
import 'package:mh_wiki/features/weapons/presentation/weapon_labels.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The "Artian" group after a type's trees (010 US3): the three bases, then
/// the user's own ("minha"). A tap opens the simulator.
class ArtianGroupCard extends StatelessWidget {
  const ArtianGroupCard({
    required this.type,
    required this.mine,
    required this.onOpen,
    required this.onOpenMine,
    this.gogma = const [],
    this.onOpenGogma,
    this.selection,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final ArtianType type;
  final List<MyArtian> mine;
  final ValueChanged<ArtianBase> onOpen;
  final ValueChanged<MyArtian> onOpenMine;

  /// The type's Gogma Artian (Gogmazios), one per focus.
  final List<Weapon> gogma;
  final ValueChanged<Weapon>? onOpenGogma;

  /// Highlighted in the expanded layout.
  final ArtianSelection? selection;
  final NameLanguage language;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    final rows = <Widget>[
      for (final base in type.bases)
        _ArtianRow(
          key: ValueKey(('artian', base.rarity)),
          image: _image(base),
          name: base.name.resolve(language),
          info: [
            l10n.rarity(base.rarity),
            '${l10n.attack} ${base.attack}',
            l10n.artianAnyElement,
          ].join(' · '),
          selected:
              selection?.myId == null &&
              selection?.focus == null &&
              selection?.type == type.type &&
              selection?.rarity == base.rarity,
          onTap: () => onOpen(base),
        ),
      for (final a in mine)
        if (type.base(a.build.rarity) case final base?)
          _ArtianRow(
            key: ValueKey(('my-artian', a.id)),
            image: _image(base),
            name: a.name,
            tag: l10n.myArtianTag,
            info: [
              l10n.rarity(base.rarity),
              if (simulateArtian(type, a.build) case final r) ...[
                '${l10n.attack} ${r.attack}',
                if (r.element case final e?)
                  '${l10n.specialName(SpecialKind.values.byName(e))} ${r.elementValue}',
              ],
            ].join(' · '),
            selected: selection?.myId == a.id,
            onTap: () => onOpenMine(a),
          ),
      if (gogma.isNotEmpty)
        Semantics(
          header: true,
          child: Padding(
            key: const Key('gogma-group'),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                const MonsterImage(asset: gogmaziosImage, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.gogmaGroup,
                    style: notebookTitle(
                      size: 15,
                      color: HunterPalette.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      for (final w in gogma)
        _ArtianRow(
          key: ValueKey(('gogma', w.gogma)),
          image: weaponImage(w),
          name: w.name.resolve(language),
          tag: l10n.gogmaTag,
          info: [
            l10n.gogmaFocus(focusName(l10n, w.gogma!)),
            '${l10n.attack} ${w.attack}',
            l10n.signedPercent(w.affinity),
            if (w.traits.phial case final p?) p.resolve(language),
            if (w.traits.shelling case final p?) p.resolve(language),
          ].join(' · '),
          selected: selection?.focus == w.gogma && selection?.type == type.type,
          onTap: () => onOpenGogma?.call(w),
        ),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(gutter - 10, 5, gutter - 10, 5),
      child: Material(
        key: const Key('artian-group'),
        color: HunterPalette.panel,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: HunterPalette.borderSubtle),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: HunterPalette.borderSubtle),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: Text(l10n.artianGroup, style: notebookTitle(size: 18)),
                ),
              ),
            ),
            for (final (i, row) in rows.indexed)
              if (i < rows.length - 1)
                DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: HunterPalette.borderSubtle),
                    ),
                  ),
                  child: row,
                )
              else
                row,
          ],
        ),
      ),
    );
  }

  String? _image(ArtianBase base) =>
      base.imageAsset ??
      GameIcons.weaponType(type.type, Game.wilds, rarity: base.rarity);
}

class _ArtianRow extends StatelessWidget {
  const _ArtianRow({
    required this.image,
    required this.name,
    required this.info,
    required this.selected,
    required this.onTap,
    this.tag,
    super.key,
  });

  final String? image;
  final String name;
  final String info;
  final String? tag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall;
    final seal = tag;
    return Semantics(
      button: true,
      selected: selected,
      label: [name, ?seal, info].join(', '),
      excludeSemantics: true,
      child: Material(
        color: selected ? HunterPalette.panelHighlight : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: selected ? HunterPalette.gold : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                child: Row(
                  children: [
                    MonsterImage(asset: image, size: 34),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                name,
                                style: notebookTitle(size: 16, height: 1.15),
                              ),
                              if (seal != null)
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: HunterPalette.gold,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: Text(
                                      seal,
                                      style: muted?.copyWith(
                                        color: HunterPalette.gold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(info, style: muted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
