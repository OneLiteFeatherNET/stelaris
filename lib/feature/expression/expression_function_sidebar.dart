import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/filter/category_filter_menu.dart';
import 'package:stelaris/feature/base/picker/filter_groups.dart';
import 'package:stelaris/feature/base/picker/grouped_picker_list.dart';
import 'package:stelaris/feature/base/search/dialog_search_bar.dart';
import 'package:stelaris/feature/expression/expression_completion.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The groups of the picker in the order they are listed: one per function
/// category, then the constants.
enum _Group {
  project(CatalogFunctionCategory.project),
  basic(CatalogFunctionCategory.basic),
  string(CatalogFunctionCategory.string),
  dateTime(CatalogFunctionCategory.dateTime),
  trigonometric(CatalogFunctionCategory.trigonometric),
  other(CatalogFunctionCategory.other),
  constants(null);

  const _Group(this.category);

  /// The category of the group's functions, null for the constants.
  final CatalogFunctionCategory? category;

  String label(AppLocalizations l10n) => switch (this) {
    project => l10n.expression_function_group_project,
    basic => l10n.expression_functions_group_basic,
    string => l10n.expression_functions_group_string,
    dateTime => l10n.expression_functions_group_date_time,
    trigonometric => l10n.expression_functions_group_trigonometric,
    other => l10n.expression_functions_group_other,
    constants => l10n.expression_functions_group_constants,
  };
}

/// The widest a constant's value gets at the end of its row. Values like E
/// or PI carry up to 100 digits, unbounded they take the whole row.
const double _maxConstantValueWidth = 160;

const double _filterButtonSize = 32;

/// The catalog's functions and constants to browse and insert, shown in the
/// function picker, styled like the component picker: a search bar with a
/// group filter above a list of the entries under a header per group.
///
/// The search matches the names of the entries ignoring case, and the name
/// of a group, so typing e.g. `text` lists every text function. A click on a
/// header shows only its group. The caller inserts the tapped entry.
class ExpressionFunctionSidebar extends StatefulWidget {
  const ExpressionFunctionSidebar({
    required this.catalog,
    required this.onFunction,
    required this.onConstant,
    super.key,
  });

  /// Null while the catalog is not loaded: a note is shown instead.
  final ExpressionCatalog? catalog;
  final ValueChanged<CatalogFunction> onFunction;
  final ValueChanged<CatalogConstant> onConstant;

  @override
  State<ExpressionFunctionSidebar> createState() =>
      _ExpressionFunctionSidebarState();
}

class _ExpressionFunctionSidebarState extends State<ExpressionFunctionSidebar> {
  final FocusNode _focusNode = FocusNode();

  /// The search text. Only the list listens to it, so a keystroke leaves the
  /// search bar and the filter alone.
  final ValueNotifier<String> _search = ValueNotifier('');

  /// The group picked in the filter. Null shows all.
  _Group? _group;

  /// The entries per group, computed once so a keystroke only filters.
  /// Groups without any are left out.
  late final Map<_Group, List<_Entry>> _entries = () {
    final catalog = widget.catalog;
    final byGroup = <_Group, List<_Entry>>{
      for (final group in _Group.values) group: [],
    };
    if (catalog != null) {
      for (final function in catalog.functions) {
        final group = _Group.values.firstWhere(
          (group) => group.category == function.category,
          orElse: () => _Group.other,
        );
        byGroup[group]!.add(_FunctionRow(function));
      }
      byGroup[_Group.constants]!.addAll(
        catalog.constants.map(_ConstantRow.new),
      );
    }
    return byGroup..removeWhere((_, entries) => entries.isEmpty);
  }();

  @override
  void dispose() {
    _focusNode.dispose();
    _search.dispose();
    super.dispose();
  }

  void _selectGroup(_Group? group) {
    setState(() => _group = group);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final group = _group;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DialogSearchBar(
          key: const ValueKey('expression_function_search'),
          focusNode: _focusNode,
          hintText: group == null
              ? l10n.expression_functions_search_label
              : l10n.expression_functions_search_in(group.label(l10n)),
          trailing: [
            CategoryFilterMenu<_Group>(
              value: group,
              allLabel: l10n.expression_functions_all_groups,
              keyPrefix: 'expression_group_item',
              entries: [
                for (final MapEntry(key: group, value: entries)
                    in _entries.entries)
                  (
                    value: group,
                    label: group.label(l10n),
                    count: entries.length,
                    id: group.name,
                  ),
              ],
              onChanged: _selectGroup,
              builder: (context, toggle) => SizedBox(
                // The anchor would stretch the button to the bar's height
                // otherwise.
                width: _filterButtonSize,
                height: _filterButtonSize,
                child: IconButton(
                  key: const Key('expression_group_filter'),
                  padding: EdgeInsets.zero,
                  isSelected: group != null,
                  icon: const Icon(Icons.filter_list),
                  tooltip: l10n.expression_functions_filter_tooltip,
                  onPressed: toggle,
                ),
              ),
            ),
          ],
          onChanged: (value) => _search.value = value,
        ),
        verticalSpacing10,
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _search,
            builder: (context, search, _) => _list(l10n, search),
          ),
        ),
      ],
    );
  }

  /// The list of the entries matching [search], or a note while the catalog
  /// is not loaded.
  Widget _list(AppLocalizations l10n, String search) {
    if (widget.catalog == null) {
      return Center(
        child: Text(
          l10n.expression_functions_unavailable,
          textAlign: TextAlign.center,
        ),
      );
    }
    return GroupedPickerList(
      groups: filterGroups(
        _entries,
        search: search,
        only: _group,
        groupLabel: (group) => group.label(l10n),
        matches: (entry, search) => entry.name.toLowerCase().contains(search),
      ),
      groupLabel: (group) => group.label(l10n),
      groupTooltip: l10n.expression_functions_group_only,
      headerKey: (group) => ValueKey('expression_group_header_${group.name}'),
      itemKey: (entry) => entry.key,
      itemBuilder: (context, entry) => switch (entry) {
        _FunctionRow(:final function) => _FunctionTile(
          function: function,
          onTap: () => widget.onFunction(function),
        ),
        _ConstantRow(:final constant) => _ConstantTile(
          constant: constant,
          onTap: () => widget.onConstant(constant),
        ),
      },
      emptyText: l10n.expression_functions_empty_search,
      // A filtered list has only one header, so it offers nothing to click.
      onGroup: _group == null ? _selectGroup : null,
    );
  }
}

/// An entry of the list.
sealed class _Entry {
  const _Entry();

  /// What the search matches.
  String get name;

  /// The key of the entry's row, unique in the list.
  Key get key;
}

final class _FunctionRow extends _Entry {
  const _FunctionRow(this.function);

  final CatalogFunction function;

  @override
  String get name => function.name;

  @override
  Key get key => ValueKey('expression_function_${function.name}');
}

final class _ConstantRow extends _Entry {
  const _ConstantRow(this.constant);

  final CatalogConstant constant;

  @override
  String get name => constant.name;

  @override
  Key get key => ValueKey('expression_constant_${constant.name}');
}

class _FunctionTile extends StatelessWidget {
  const _FunctionTile({required this.function, required this.onTap});

  final CatalogFunction function;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = function.description;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        functionSignature(function),
        style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: description == null || description.isEmpty
          ? null
          : Text(description, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}

class _ConstantTile extends StatelessWidget {
  const _ConstantTile({required this.constant, required this.onTap});

  final CatalogConstant constant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        constant.name,
        style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
      ),
      // Capped, the full value is the tooltip.
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxConstantValueWidth),
        child: Tooltip(
          message: constant.value,
          child: Text(
            constant.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
