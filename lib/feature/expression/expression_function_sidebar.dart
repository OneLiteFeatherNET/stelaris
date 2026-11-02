import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/filter/category_filter_menu.dart';
import 'package:stelaris/feature/base/hide_tooltips_while_scrolling.dart';
import 'package:stelaris/feature/base/search/dialog_search_bar.dart';
import 'package:stelaris/feature/expression/expression_completion.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/app_shapes.dart';
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
  late final Map<_Group, List<_Row>> _entries = () {
    final catalog = widget.catalog;
    final byGroup = <_Group, List<_Row>>{
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

  /// The rows of the list: a header per group followed by its entries.
  List<_Row> _rows(AppLocalizations l10n, String text) {
    final search = text.trim().toLowerCase();
    final rows = <_Row>[];
    for (final MapEntry(key: group, value: entries) in _entries.entries) {
      if (_group != null && group != _group) continue;
      final Iterable<_Row> matches =
          search.isEmpty || group.label(l10n).toLowerCase().contains(search)
          ? entries
          : entries.where((row) => row.name.toLowerCase().contains(search));
      if (matches.isEmpty) continue;
      rows
        ..add(_HeaderRow(group))
        ..addAll(matches);
    }
    return rows;
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

  /// The list of the entries matching [search], or a note when there are
  /// none.
  Widget _list(AppLocalizations l10n, String search) {
    final rows = _rows(l10n, search);
    final String? note = widget.catalog == null
        ? l10n.expression_functions_unavailable
        : rows.isEmpty
        ? l10n.expression_functions_empty_search
        : null;
    if (note != null) {
      return Center(child: Text(note, textAlign: TextAlign.center));
    }

    // Lets a row which the search moved keep its element: without it the
    // list matches rows by index, and every row at a new index is built
    // from scratch.
    final indexOf = <Key, int>{
      for (final (index, row) in rows.indexed) row.key: index,
    };
    final group = _group;
    // The rows paint their ink on this material, which clips it to the list,
    // as in the component picker.
    return Material(
      type: MaterialType.transparency,
      clipBehavior: Clip.hardEdge,
      child: HideTooltipsWhileScrolling(
        child: ListView.builder(
          // Keeps the rows clear of the scrollbar.
          padding: const EdgeInsets.only(right: 16),
          itemCount: rows.length,
          findChildIndexCallback: (key) => indexOf[key],
          itemBuilder: (context, index) => switch (rows[index]) {
            final _HeaderRow row => _GroupHeader(
              key: row.key,
              row.group,
              // A filtered list has only this header, so it offers nothing
              // to click.
              onTap: group == null ? () => _selectGroup(row.group) : null,
            ),
            final _FunctionRow row => _FunctionTile(
              key: row.key,
              function: row.function,
              onTap: () => widget.onFunction(row.function),
            ),
            final _ConstantRow row => _ConstantTile(
              key: row.key,
              constant: row.constant,
              onTap: () => widget.onConstant(row.constant),
            ),
          },
        ),
      ),
    );
  }
}

/// A row of the list.
sealed class _Row {
  const _Row();

  /// What the search matches.
  String get name;

  /// The key of the row's widget, unique in the list.
  Key get key;
}

final class _HeaderRow extends _Row {
  const _HeaderRow(this.group);

  final _Group group;

  @override
  String get name => group.name;

  @override
  Key get key => ValueKey('expression_group_header_${group.name}');
}

final class _FunctionRow extends _Row {
  const _FunctionRow(this.function);

  final CatalogFunction function;

  @override
  String get name => function.name;

  @override
  Key get key => ValueKey('expression_function_${function.name}');
}

final class _ConstantRow extends _Row {
  const _ConstantRow(this.constant);

  final CatalogConstant constant;

  @override
  String get name => constant.name;

  @override
  Key get key => ValueKey('expression_constant_${constant.name}');
}

/// The header of a group, like the category headers of the component picker:
/// a click shows only the group.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.group, {required this.onTap, super.key});

  final _Group group;

  /// Filters the list by the group, null when it is already filtered.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final label = group.label(context.l10n);
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Row(
        children: [
          Text(
            label,
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
      message: context.l10n.expression_functions_group_only(label),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppShapes.small),
        onTap: onTap,
        child: header,
      ),
    );
  }
}

class _FunctionTile extends StatelessWidget {
  const _FunctionTile({required this.function, required this.onTap, super.key});

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
  const _ConstantTile({required this.constant, required this.onTap, super.key});

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
