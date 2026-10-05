import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/hide_tooltips_while_scrolling.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/item/components/component_category_menu.dart';
import 'package:stelaris/feature/item/components/schema_field.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:vulpes_data/component.dart';

/// The components which can be added in the components tab.
///
/// Managed components (lore, enchantments, name, model data) have their own
/// editors and runtime state can't be set, so neither is offered.
final List<ComponentSpec> offeredComponents = [
  for (final spec in dataComponents)
    if (spec.editable && !spec.managed) spec,
];

/// Lets the user pick a component which the item doesn't have yet.
///
/// Components the [material] has by default are marked, adding one of them
/// overrides the vanilla value.
Future<ComponentSpec?> showComponentPickerDialog(
  BuildContext context, {
  required Set<String> existing,
  required Set<String> materialDefaults,
}) {
  return showDialog<ComponentSpec>(
    context: context,
    builder: (_) => _ComponentPickerDialog(
      existing: existing,
      materialDefaults: materialDefaults,
    ),
  );
}

class _ComponentPickerDialog extends StatefulWidget {
  const _ComponentPickerDialog({
    required this.existing,
    required this.materialDefaults,
  });

  final Set<String> existing;
  final Set<String> materialDefaults;

  @override
  State<_ComponentPickerDialog> createState() => _ComponentPickerDialogState();
}

class _ComponentPickerDialogState extends State<_ComponentPickerDialog> {
  /// The height of the whole content, fixed so the dialog doesn't change its
  /// size while the user types. The list takes what the search leaves.
  static const double _contentHeight = 480;

  static const double _searchHeight = 44;

  static const double _filterButtonSize = 32;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _search = '';

  /// The category picked in the filter menu. Null shows all.
  ComponentCategory? _category;

  /// The components which can still be added, independent of the filters,
  /// grouped by their category in the order of the categories. Categories
  /// without any are left out.
  late final Map<ComponentCategory, List<ComponentSpec>> _addable = () {
    final byCategory = <ComponentCategory, List<ComponentSpec>>{
      for (final category in ComponentCategory.values) category: [],
    };
    for (final spec in offeredComponents) {
      if (!widget.existing.contains(spec.key)) {
        byCategory[spec.category]!.add(spec);
      }
    }
    return byCategory..removeWhere((_, specs) => specs.isEmpty);
  }();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectCategory(ComponentCategory? category) {
    setState(() => _category = category);
    _focusNode.requestFocus();
  }

  /// The addable components per category, for the filter menu.
  late final Map<ComponentCategory, int> _counts = {
    for (final MapEntry(key: category, value: specs) in _addable.entries)
      category: specs.length,
  };

  /// The rows of the list: a header per category followed by its components.
  ///
  /// The search matches the name and key of a component, and the name of its
  /// category, so typing e.g. `combat` lists every combat component.
  List<_Row> _rows() {
    final search = _search.trim().toLowerCase();
    final rows = <_Row>[];
    for (final MapEntry(key: category, value: specs) in _addable.entries) {
      if (_category != null && category != _category) continue;
      final Iterable<ComponentSpec> matches =
          search.isEmpty || category.displayName.toLowerCase().contains(search)
          ? specs
          : specs.where(
              (spec) =>
                  spec.displayName.toLowerCase().contains(search) ||
                  spec.key.contains(search),
            );
      if (matches.isEmpty) continue;
      rows
        ..add(_HeaderRow(category))
        ..addAll(matches.map(_SpecRow.new));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = _rows();
    final category = _category;
    return FormDialog(
      title: context.l10n.component_add_title,
      actionLabel: context.l10n.button_add,
      onSubmit: null,
      showActions: false,
      maxWidth: 560,
      content: SizedBox(
        height: _contentHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Styled like the app bar search, with its filter menu.
            SearchBar(
              controller: _controller,
              focusNode: _focusNode,
              autoFocus: true,
              hintText: category == null
                  ? context.l10n.component_search_hint
                  : context.l10n.component_search_in(category.displayName),
              leading: const Icon(Icons.search),
              trailing: [
                ComponentCategoryMenu(
                  value: category,
                  counts: _counts,
                  onChanged: _selectCategory,
                  builder: (context, toggle) => SizedBox(
                    // The anchor would stretch the button to the bar's
                    // height otherwise.
                    width: _filterButtonSize,
                    height: _filterButtonSize,
                    child: IconButton(
                      key: const Key('component_category_filter'),
                      padding: EdgeInsets.zero,
                      isSelected: category != null,
                      icon: const Icon(Icons.filter_list),
                      tooltip: context.l10n.component_filter_tooltip,
                      onPressed: toggle,
                    ),
                  ),
                ),
              ],
              elevation: const WidgetStatePropertyAll(0),
              constraints: const BoxConstraints(
                minHeight: _searchHeight,
                maxHeight: _searchHeight,
              ),
              backgroundColor: WidgetStatePropertyAll(
                theme.colorScheme.surface,
              ),
              side: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? BorderSide(color: theme.colorScheme.primary, width: 2)
                    : BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.only(left: 12, right: 6),
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
            verticalSpacing10,
            Expanded(
              child: rows.isEmpty
                  ? Center(child: Text(context.l10n.component_search_empty))
                  // The rows paint their ink on this material, which clips
                  // it to the list. On the dialog's material the highlight
                  // of a row scrolled half out drew past the list.
                  : Material(
                      type: MaterialType.transparency,
                      clipBehavior: Clip.hardEdge,
                      child: HideTooltipsWhileScrolling(
                        child: ListView.builder(
                          // Keeps the rows clear of the scrollbar.
                          padding: const EdgeInsets.only(right: 16),
                          itemCount: rows.length,
                          itemBuilder: (context, index) =>
                              switch (rows[index]) {
                                _HeaderRow(:final category) => _CategoryHeader(
                                  category,
                                  // A filtered list has only this header, so it
                                  // offers nothing to click.
                                  onTap: _category == null
                                      ? () => _selectCategory(category)
                                      : null,
                                ),
                                _SpecRow(:final spec) => _ComponentRow(
                                  spec: spec,
                                  isDefault: widget.materialDefaults.contains(
                                    spec.key,
                                  ),
                                  onTap: () => Navigator.of(context).pop(spec),
                                ),
                              },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A row of the component list.
sealed class _Row {
  const _Row();
}

final class _HeaderRow extends _Row {
  const _HeaderRow(this.category);

  final ComponentCategory category;
}

final class _SpecRow extends _Row {
  const _SpecRow(this.spec);

  final ComponentSpec spec;
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader(this.category, {required this.onTap});

  final ComponentCategory category;

  /// Filters the list by the category, null when it is already filtered.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Row(
        children: [
          Text(
            category.displayName,
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.filter_list, size: 16, color: color),
          ],
        ],
      ),
    );
    if (onTap == null) return header;
    return Tooltip(
      message: context.l10n.component_category_only(category.displayName),
      child: InkWell(
        key: Key('component_category_header_${category.key}'),
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: header,
      ),
    );
  }
}

class _ComponentRow extends StatelessWidget {
  const _ComponentRow({
    required this.spec,
    required this.isDefault,
    required this.onTap,
  });

  final ComponentSpec spec;
  final bool isDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(spec.displayName),
      subtitle: Text(spec.key),
      // A plain label instead of a chip keeps every row the same height.
      trailing: isDefault
          ? Tooltip(
              message: context.l10n.component_default_tooltip,
              child: Text(
                context.l10n.component_default_label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

/// Saves the value of a component; resolves to the error, or null when it
/// worked.
typedef ComponentSave = Future<Object?> Function(Object? value);

/// Edits the value of a component in a form built from its schema.
///
/// Submitting waits for [onSave]: on an error the dialog stays open and
/// shows it, otherwise it closes. Resolves to whether the value was saved.
Future<bool> showComponentEditDialog(
  BuildContext context, {
  required ComponentSpec spec,
  required Object? value,
  required ComponentSave onSave,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) =>
        _ComponentEditDialog(spec: spec, value: value, onSave: onSave),
  );
  return saved ?? false;
}

class _ComponentEditDialog extends StatefulWidget {
  const _ComponentEditDialog({
    required this.spec,
    required this.value,
    required this.onSave,
  });

  final ComponentSpec spec;
  final Object? value;
  final ComponentSave onSave;

  @override
  State<_ComponentEditDialog> createState() => _ComponentEditDialogState();
}

class _ComponentEditDialogState extends State<_ComponentEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late Object? _value = widget.value;
  bool _saving = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;
    setState(() => _saving = true);
    final error = await widget.onSave(_value);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      context.showErrorSnackBar(error);
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormDialog(
      title: widget.spec.displayName,
      actionIcon: Icons.save_outlined,
      actionLabel: context.l10n.button_save,
      onSubmit: _saving ? null : _submit,
      busy: _saving,
      maxWidth: 600,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.spec.category.displayName} · ${widget.spec.key}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            verticalSpacing10,
            SchemaField(
              schema: widget.spec.schema,
              value: _value,
              onChanged: (value) => setState(() => _value = value),
            ),
          ],
        ),
      ),
    );
  }
}
