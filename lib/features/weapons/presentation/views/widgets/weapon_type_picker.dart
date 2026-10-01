import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mh_wiki/core/domain/name_language.dart';
import 'package:mh_wiki/core/domain/localized_text.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';
import 'package:mh_wiki/features/weapons/domain/entities/weapon_type.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// The weapon types as blocks that scroll sideways (006 ui-contract): icon
/// and pt-BR name, the selected one with a gold edge. With a mouse, the row
/// also scrolls by dragging and with the wheel, and its scrollbar stays
/// visible so the other types can be found.
class WeaponTypePicker extends StatefulWidget {
  const WeaponTypePicker({
    required this.types,
    required this.selectedId,
    required this.onChanged,
    this.language = NameLanguage.ptBr,
    super.key,
  });

  final NameLanguage language;
  final List<WeaponType> types;

  /// `null` when no type is selected (the "only these weapons" filter).
  final String? selectedId;
  final ValueChanged<String> onChanged;

  static String iconAsset(String typeId) =>
      'assets/images/weapons/types/$typeId.webp';

  @override
  State<WeaponTypePicker> createState() => _WeaponTypePickerState();
}

class _WeaponTypePickerState extends State<WeaponTypePicker> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// A vertical wheel over the row scrolls it sideways.
  void _onWheel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scroll.hasClients) return;
    final delta = event.scrollDelta.dy != 0
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    final position = _scroll.position;
    if (position.maxScrollExtent <= 0) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      _scroll.jumpTo(
        (position.pixels + delta).clamp(0, position.maxScrollExtent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gutter = Space.gutter(MediaQuery.sizeOf(context).width);
    return Listener(
      onPointerSignal: _onWheel,
      child: ScrollConfiguration(
        // Dragging with the mouse too, not only touch (Windows, web).
        behavior: ScrollConfiguration.of(context)
            .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
        child: Scrollbar(
          controller: _scroll,
          thumbVisibility: true,
          child: SingleChildScrollView(
            key: const PageStorageKey('weapon-types'),
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(gutter, 10, gutter, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, type) in widget.types.indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _TypeBlock(
                    type: type,
                    selected: type.id == widget.selectedId,
                    language: widget.language,
                    onTap: () => widget.onChanged(type.id),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeBlock extends StatelessWidget {
  const _TypeBlock({
    required this.type,
    required this.selected,
    required this.language,
    required this.onTap,
  });

  final NameLanguage language;
  final WeaponType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = type.name.resolve(language);
    return Semantics(
      button: true,
      selected: selected,
      label: l10n.weaponTypeLabel(name),
      excludeSemantics: true,
      child: Material(
        color: selected ? HunterPalette.panelHighlight : HunterPalette.panel,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected ? HunterPalette.gold : HunterPalette.borderSubtle,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: selected ? null : onTap,
          child: SizedBox(
            width: 68,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(3, 6, 3, 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 26,
                      child: Opacity(
                        opacity: selected ? 1 : 0.7,
                        child: Image.asset(
                          WeaponTypePicker.iconAsset(type.id),
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                          errorBuilder: (_, _, _) => Center(
                            child: Text(
                              _initials(type.name),
                              style: notebookTitle(
                                size: 17,
                                color: selected
                                    ? HunterPalette.gold
                                    : HunterPalette.textDisabled,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.15,
                        color: selected
                            ? HunterPalette.text
                            : HunterPalette.textMuted,
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

  static String _initials(LocalizedText name) => (name.ptBr ?? name.en)
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 2)
      .map((w) => w[0].toUpperCase())
      .take(2)
      .join();
}
