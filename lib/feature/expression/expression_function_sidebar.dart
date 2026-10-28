import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/expression/expression_completion.dart';
import 'package:stelaris/l10n/app_localizations.dart';
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

/// The catalog's functions and constants to browse and insert, shown in the
/// function picker. A search filters both by name ignoring case, and expands
/// every group while it is not empty. The search stays at the top, the groups
/// scroll below it. The caller inserts the tapped entry.
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
  String _query = '';

  bool _matches(String name) =>
      name.toLowerCase().contains(_query.trim().toLowerCase());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final catalog = widget.catalog;
    final searching = _query.trim().isNotEmpty;
    final monospace = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
    );

    final groups = <Widget>[];
    if (catalog != null) {
      for (final category in _groupOrder) {
        final functions = [
          for (final function in catalog.functions)
            if (function.category == category && _matches(function.name))
              function,
        ];
        if (functions.isEmpty) continue;
        groups.add(
          _Group(
            key: ValueKey('expression_group_${category.name}_$searching'),
            title: _categoryLabel(l10n, category),
            expanded: searching,
            children: [
              for (final function in functions)
                ListTile(
                  key: ValueKey('expression_function_${function.name}'),
                  dense: true,
                  title: Text(
                    functionSignature(function),
                    style: monospace,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle:
                      function.description == null ||
                          function.description!.isEmpty
                      ? null
                      : Text(
                          function.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  onTap: () => widget.onFunction(function),
                ),
            ],
          ),
        );
      }
      final constants = [
        for (final constant in catalog.constants)
          if (_matches(constant.name)) constant,
      ];
      if (constants.isNotEmpty) {
        groups.add(
          _Group(
            key: ValueKey('expression_group_constants_$searching'),
            title: l10n.expression_functions_group_constants,
            expanded: searching,
            children: [
              for (final constant in constants)
                ListTile(
                  key: ValueKey('expression_constant_${constant.name}'),
                  dense: true,
                  title: Text(constant.name, style: monospace),
                  trailing: Text(
                    constant.value,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => widget.onConstant(constant),
                ),
            ],
          ),
        );
      }
    }

    final String? note;
    if (catalog == null) {
      note = l10n.expression_functions_unavailable;
    } else if (groups.isEmpty) {
      note = l10n.expression_functions_empty_search;
    } else {
      note = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('expression_function_search'),
          autofocus: true,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            labelText: l10n.expression_functions_search_label,
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        if (note != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(note, style: theme.textTheme.bodySmall),
          ),
        Expanded(child: ListView(children: groups)),
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

/// A collapsible group of entries. Its [expanded] state is only the initial
/// one: the key changes with the search, so a search opens every group.
class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.expanded,
    required this.children,
    super.key,
  });

  final String title;
  final bool expanded;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      initiallyExpanded: expanded,
      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
      childrenPadding: EdgeInsets.zero,
      children: children,
    );
  }
}
