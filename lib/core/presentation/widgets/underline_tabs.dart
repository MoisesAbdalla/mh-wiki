import 'package:flutter/material.dart';
import 'package:mh_wiki/core/presentation/theme/hunter_palette.dart';
import 'package:mh_wiki/core/presentation/theme/notebook_tokens.dart';

/// One tab of [UnderlineTabs]: a text, or an image with that text as its
/// fallback.
class TabOption<T> {
  const TabOption({
    required this.value,
    required this.text,
    this.image,
    this.semanticsLabel,
    this.enabled = true,
  });

  final T value;

  /// A disabled tab is dimmed and ignores taps (e.g. a game "em breve").
  final bool enabled;
  final String text;

  /// Asset path of an image shown instead of [text] (e.g. a game logo).
  final String? image;

  /// Spoken label when it should say more than [text].
  final String? semanticsLabel;
}

/// Tabs drawn as text or images on one line, the active one in full colour
/// with a gold underline (005 FR-006/FR-008, research R4). When they do not
/// fit, the line scrolls sideways instead of wrapping or shrinking.
class UnderlineTabs<T> extends StatelessWidget {
  const UnderlineTabs({
    required this.options,
    required this.selected,
    required this.onChanged,
    this.textSize = 17,
    this.imageHeight = 46,
    this.ruled = true,
    super.key,
  });

  final List<TabOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final double textSize;
  final double imageHeight;

  /// Draws a hairline under the whole row of tabs.
  final bool ruled;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: ruled
          ? const Border(bottom: BorderSide(color: HunterPalette.borderSubtle))
          : null,
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, option) in options.indexed) ...[
            if (i > 0) const SizedBox(width: 18),
            _UnderlineTab(
              option: option,
              selected: option.value == selected,
              textSize: textSize,
              imageHeight: imageHeight,
              onTap: option.enabled ? () => onChanged(option.value) : null,
            ),
          ],
        ],
      ),
    ),
  );
}

class _UnderlineTab extends StatelessWidget {
  const _UnderlineTab({
    required this.option,
    required this.selected,
    required this.textSize,
    required this.imageHeight,
    required this.onTap,
  });

  final TabOption<Object?> option;
  final bool selected;
  final double textSize;
  final double imageHeight;
  final VoidCallback? onTap;

  /// Greyscale mix of an unselected image (0 = grey, 1 = original colours).
  static const _saturation = 0.6;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      option.text,
      style: notebookTitle(
        size: textSize,
        color: selected ? HunterPalette.text : HunterPalette.textMuted,
      ),
    );
    final image = option.image;
    final content = image == null
        ? text
        : Opacity(
            opacity: selected ? 1 : 0.55,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(
                _saturationMatrix(selected ? 1 : _saturation),
              ),
              child: Image.asset(
                image,
                height: imageHeight,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => text,
              ),
            ),
          );

    final tab = Semantics(
      container: true,
      button: true,
      enabled: option.enabled,
      selected: selected,
      label: option.semanticsLabel ?? option.text,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? HunterPalette.gold : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 7),
              // The label above speaks for the text or the logo.
              child: ExcludeSemantics(
                child: Center(widthFactor: 1, heightFactor: 1, child: content),
              ),
            ),
          ),
        ),
      ),
    );
    return option.enabled ? tab : Opacity(opacity: 0.45, child: tab);
  }

  static List<double> _saturationMatrix(double s) {
    const r = 0.2126, g = 0.7152, b = 0.0722;
    final i = 1 - s;
    return [
      r * i + s, g * i, b * i, 0, 0, //
      r * i, g * i + s, b * i, 0, 0, //
      r * i, g * i, b * i + s, 0, 0, //
      0, 0, 0, 1, 0,
    ];
  }
}
