import 'package:flutter/material.dart';
import 'package:mh_wiki/l10n/app_localizations.dart';

/// Search box that reports every change (FR-005) and stays in sync when the
/// query is cleared elsewhere (e.g. "Limpar filtros").
class SearchField extends StatefulWidget {
  const SearchField({required this.text, required this.onChanged, super.key});

  final String text;
  final ValueChanged<String> onChanged;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: widget.text.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.clearSearch,
                  icon: const Icon(Icons.clear),
                  onPressed: () => widget.onChanged(''),
                ),
        ),
      ),
    );
  }
}
