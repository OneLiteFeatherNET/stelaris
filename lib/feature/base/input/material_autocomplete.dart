import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vulpes_data/material.dart';

/// The most suggestions shown under a field at once.
const int maxMaterialSuggestions = 5;

/// Built once: indexing every material is too costly to repeat per keystroke.
final MaterialSearch<MaterialSearchEntry> _materialSearch = MaterialSearch(
  MaterialSearchEntry.values,
);

/// The suggestions for [query], at most [maxMaterialSuggestions]. An empty
/// query suggests nothing, and [categories] narrows the search when not empty.
List<MaterialSearchEntry> suggestMaterials(
  String query, {
  Set<MaterialCategory> categories = const {},
}) {
  if (query.trim().isEmpty) return const [];
  return _materialSearch.search(
    query,
    categories: categories,
    limit: maxMaterialSuggestions,
  );
}

/// A free text field for a Minecraft material key that suggests matching
/// materials while typing.
///
/// Suggestions are only a shortcut: anything typed stays valid, so custom ids
/// work as before. The field itself comes from [fieldBuilder], which keeps the
/// caller's decoration and validation. Picking a suggestion puts its key into
/// the field and reports it through [onSelected], since a programmatic change
/// of the text doesn't reach the field's own `onChanged`.
class MaterialAutocomplete extends StatelessWidget {
  const MaterialAutocomplete({
    required this.fieldBuilder,
    required this.onSelected,
    this.initialValue = '',
    this.controller,
    this.focusNode,
    this.categories = const {},
    @visibleForTesting this.skipSuggestions,
    super.key,
  }) : assert(
         (controller == null) == (focusNode == null),
         'controller and focusNode must be given together',
       );

  /// Builds the input from the controller and focus node the suggestions are
  /// attached to. [onFieldSubmitted] must be called when the field is
  /// submitted so that the highlighted suggestion can be taken with Enter.
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  )
  fieldBuilder;
  final void Function(String key) onSelected;

  /// Only used when no [controller] is given.
  final String initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Restricts the suggestions to these categories; all when empty.
  final Set<MaterialCategory> categories;

  /// Whether to skip the suggestions; by default they are skipped on the web
  /// while its semantics tree is on.
  ///
  /// Showing the overlay then makes the engine re-parent the semantic nodes of
  /// the route, which drops the DOM focus of the text field: after the first
  /// typed character the field is blurred and the overlay closes again.
  final bool? skipSuggestions;

  bool get _skipSuggestions =>
      skipSuggestions ?? (kIsWeb && SemanticsBinding.instance.semanticsEnabled);

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<MaterialSearchEntry>(
      textEditingController: controller,
      focusNode: focusNode,
      initialValue: controller == null
          ? TextEditingValue(text: initialValue)
          : null,
      displayStringForOption: (entry) => entry.key,
      optionsBuilder: (value) => _skipSuggestions
          ? const []
          : suggestMaterials(value.text, categories: categories),
      onSelected: (entry) => onSelected(entry.key),
      fieldViewBuilder: fieldBuilder,
      optionsViewBuilder: (context, onSelected, options) =>
          _SuggestionList(options: options, onSelected: onSelected),
    );
  }
}

/// Height of one suggestion: the two line menu item of Material 3.
const double _suggestionExtent = 56;

/// Vertical padding of a Material 3 menu panel.
const double _panelPadding = 8;

/// The suggestions as a Material 3 menu panel. The options view is as wide as
/// the field and as high as the space left on screen, so the list scrolls
/// when the suggestions don't fit.
class _SuggestionList extends StatefulWidget {
  const _SuggestionList({required this.options, required this.onSelected});

  final Iterable<MaterialSearchEntry> options;
  final AutocompleteOnSelected<MaterialSearchEntry> onSelected;

  @override
  State<_SuggestionList> createState() => _SuggestionListState();
}

class _SuggestionListState extends State<_SuggestionList> {
  final ScrollController _controller = ScrollController();
  ValueNotifier<int>? _highlighted;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listened to without depending on it: only the items repaint when the
    // highlight moves, the list itself just scrolls.
    _highlighted?.removeListener(_revealHighlighted);
    _highlighted = context
        .getInheritedWidgetOfExactType<AutocompleteHighlightedOption>()
        ?.notifier;
    _highlighted?.addListener(_revealHighlighted);
  }

  @override
  void dispose() {
    _highlighted?.removeListener(_revealHighlighted);
    _controller.dispose();
    super.dispose();
  }

  /// Keeps the highlighted suggestion inside the viewport. The items have a
  /// fixed extent, so this works for items the list hasn't built.
  void _revealHighlighted() {
    final index = _highlighted?.value ?? 0;
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final top = index == 0 ? 0.0 : _panelPadding + index * _suggestionExtent;
    final bottom =
        _panelPadding +
        (index + 1) * _suggestionExtent +
        (index == widget.options.length - 1 ? _panelPadding : 0);
    if (top < position.pixels) {
      position.jumpTo(top);
    } else if (bottom > position.pixels + position.viewportDimension) {
      position.jumpTo(bottom - position.viewportDimension);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = MenuTheme.of(context).style;
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: style?.backgroundColor?.resolve({}) ?? colors.surfaceContainer,
      elevation: style?.elevation?.resolve({}) ?? 3,
      shadowColor: style?.shadowColor?.resolve({}) ?? colors.shadow,
      surfaceTintColor: Colors.transparent,
      shape:
          style?.shape?.resolve({}) ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
      clipBehavior: Clip.antiAlias,
      child: ListView.builder(
        controller: _controller,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: _panelPadding),
        itemExtent: _suggestionExtent,
        itemCount: widget.options.length,
        itemBuilder: (context, index) => _Suggestion(
          index: index,
          entry: widget.options.elementAt(index),
          onSelected: widget.onSelected,
        ),
      ),
    );
  }
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({
    required this.index,
    required this.entry,
    required this.onSelected,
  });

  final int index;
  final MaterialSearchEntry entry;
  final AutocompleteOnSelected<MaterialSearchEntry> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlighted = AutocompleteHighlightedOption.of(context) == index;
    return Semantics(
      selected: highlighted,
      child: MenuItemButton(
        // The focus stays in the text field, so the highlight borrows the
        // state layer of a focused menu item.
        style: highlighted
            ? ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              )
            : null,
        overflowAxis: Axis.vertical,
        onPressed: () => onSelected(entry),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              entry.key,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
