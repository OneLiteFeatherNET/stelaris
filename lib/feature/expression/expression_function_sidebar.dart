import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/hide_tooltips_while_scrolling.dart';
import 'package:stelaris/feature/base/search/dialog_search_bar.dart';
import 'package:stelaris/feature/expression/expression_completion.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The categories functions are grouped under, in the order they are listed.
const List<CatalogFunctionCategory> _groupOrder = [
  CatalogFunctionCategory.project,
  CatalogFunctionCategory.basic,
  CatalogFunctionCategory.string,
  CatalogFunctionCategory.dateTime,
  CatalogFunctionCategory.trigonometric,
  CatalogFunctionCategory.other,
];

/// The widest a constant's value gets at the end of its row. Values like E
/// or PI carry up to 100 digits, unbounded they take the whole row.
const double _maxConstantValueWidth = 160;

/// The catalog's functions and constants to browse and insert, shown in the
/// function picker, styled like the component picker: a search bar above a
/// list of the entries under a header per group. The search filters both by
/// name ignoring case. The caller inserts the tapped entry.
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
  String _search = '';

  /// The functions per category in the order of [_groupOrder], computed once
  /// so a keystroke only filters. Categories without any are left out.
  late final Map<CatalogFunctionCategory, List<CatalogFunction>> _functions =
      () {
        final byCategory = <CatalogFunctionCategory, List<CatalogFunction>>{
          for (final category in _groupOrder) category: [],
        };
        for (final function in widget.catalog?.functions ?? const []) {
          byCategory[function.category]?.add(function);
        }
        return byCategory..removeWhere((_, functions) => functions.isEmpty);
      }();

  /// The rows of the list: a header per group followed by its entries.
  List<_Row> _rows(AppLocalizations l10n) {
    final search = _search.trim().toLowerCase();
    bool matches(String name) =>
        search.isEmpty || name.toLowerCase().contains(search);

    final rows = <_Row>[];
    for (final MapEntry(key: category, value: functions)
        in _functions.entries) {
      final hits = functions.where((function) => matches(function.name));
      if (hits.isEmpty) continue;
      rows
        ..add(_HeaderRow(_categoryLabel(l10n, category)))
        ..addAll(hits.map(_FunctionRow.new));
    }
    final constants = (widget.catalog?.constants ?? const <CatalogConstant>[])
        .where((constant) => matches(constant.name));
    if (constants.isNotEmpty) {
      rows
        ..add(_HeaderRow(l10n.expression_functions_group_constants))
        ..addAll(constants.map(_ConstantRow.new));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = _rows(l10n);
    final String? note = widget.catalog == null
        ? l10n.expression_functions_unavailable
        : rows.isEmpty
        ? l10n.expression_functions_empty_search
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DialogSearchBar(
          key: const ValueKey('expression_function_search'),
          hintText: l10n.expression_functions_search_label,
          onChanged: (value) => setState(() => _search = value),
        ),
        verticalSpacing10,
        Expanded(
          child: note != null
              ? Center(child: Text(note, textAlign: TextAlign.center))
              // The rows paint their ink on this material, which clips it to
              // the list, as in the component picker.
              : Material(
                  type: MaterialType.transparency,
                  clipBehavior: Clip.hardEdge,
                  child: HideTooltipsWhileScrolling(
                    child: ListView.builder(
                      // Keeps the rows clear of the scrollbar.
                      padding: const EdgeInsets.only(right: 16),
                      itemCount: rows.length,
                      itemBuilder: (context, index) => switch (rows[index]) {
                        _HeaderRow(:final title) => _GroupHeader(title),
                        _FunctionRow(:final function) => _FunctionTile(
                          function: function,
                          onTap: () => widget.onFunction(function),
                        ),
                        _ConstantRow(:final constant) => _ConstantTile(
                          constant: constant,
                          onTap: () => widget.onConstant(constant),
                        ),
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  static String _categoryLabel(
    AppLocalizations l10n,
    CatalogFunctionCategory category,
  ) => switch (category) {
    CatalogFunctionCategory.basic => l10n.expression_functions_group_basic,
    CatalogFunctionCategory.string => l10n.expression_functions_group_string,
    CatalogFunctionCategory.dateTime =>
      l10n.expression_functions_group_date_time,
    CatalogFunctionCategory.trigonometric =>
      l10n.expression_functions_group_trigonometric,
    CatalogFunctionCategory.other => l10n.expression_functions_group_other,
    CatalogFunctionCategory.project => l10n.expression_function_group_project,
  };
}

/// A row of the list.
sealed class _Row {
  const _Row();
}

final class _HeaderRow extends _Row {
  const _HeaderRow(this.title);

  final String title;
}

final class _FunctionRow extends _Row {
  const _FunctionRow(this.function);

  final CatalogFunction function;
}

final class _ConstantRow extends _Row {
  const _ConstantRow(this.constant);

  final CatalogConstant constant;
}

/// The header of a group, like the category headers of the component picker.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
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
      key: ValueKey('expression_function_${function.name}'),
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
      key: ValueKey('expression_constant_${constant.name}'),
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
