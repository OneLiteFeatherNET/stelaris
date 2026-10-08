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

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<MaterialSearchEntry>(
      textEditingController: controller,
      focusNode: focusNode,
      initialValue: controller == null
          ? TextEditingValue(text: initialValue)
          : null,
      displayStringForOption: (entry) => entry.key,
      optionsBuilder: (value) =>
          suggestMaterials(value.text, categories: categories),
      onSelected: (entry) => onSelected(entry.key),
      fieldViewBuilder: fieldBuilder,
      optionsViewBuilder: (context, onSelected, options) =>
          _SuggestionList(options: options, onSelected: onSelected),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.options, required this.onSelected});

  final Iterable<MaterialSearchEntry> options;
  final AutocompleteOnSelected<MaterialSearchEntry> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlighted = AutocompleteHighlightedOption.of(context);
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              for (final (index, entry) in options.indexed)
                ListTile(
                  dense: true,
                  selected: index == highlighted,
                  title: Text(entry.displayName),
                  subtitle: Text(
                    entry.key,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  onTap: () => onSelected(entry),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
