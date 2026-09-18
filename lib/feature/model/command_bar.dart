import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_sort_option.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

List<(SortField, SortDirection, String)> _sortOptions(AppLocalizations l10n) {
  return [
    (SortField.name, SortDirection.ascending, l10n.sort_name_ascending),
    (SortField.name, SortDirection.descending, l10n.sort_name_descending),
    (
      SortField.createdAt,
      SortDirection.descending,
      l10n.sort_created_newest_first,
    ),
    (
      SortField.createdAt,
      SortDirection.ascending,
      l10n.sort_created_oldest_first,
    ),
  ];
}

/// Called whenever the user picks a different sort field/direction from
/// [CommandBar]'s sort menu.
typedef SortChanged = void Function(SortField field, SortDirection direction);

/// A M3 search bar paired with a shared filter/sort menu and an add button,
/// used at the top of a [ModelPage]. Search text, active filters and the
/// current sort selection are all owned internally — the caller only
/// receives change notifications via [onSearchChanged]/[onFiltersChanged]/
/// [onSortChanged].
class CommandBar extends StatefulWidget {
  final VoidCallback onAdd;
  final ValueChanged<String> onSearchChanged;
  final List<FilterOption> filterOptions;
  final ValueChanged<Set<FilterOption>> onFiltersChanged;
  final SortChanged onSortChanged;

  const CommandBar({
    required this.onAdd,
    required this.onSearchChanged,
    required this.filterOptions,
    required this.onFiltersChanged,
    required this.onSortChanged,
    super.key,
  });

  @override
  State<CommandBar> createState() => _CommandBarState();
}

class _CommandBarState extends State<CommandBar> {
  // Fixed (not just minimum) so the SearchBar and the add button always
  // render at the exact same height — SearchBar's own default constraint
  // only sets a *minimum* height, which lets it grow taller than the
  // button's minimumSize under some theme densities.
  static const double _barHeight = 56;

  final Set<FilterOption> _activeFilters = {};

  SortField _sortField = SortField.name;
  SortDirection _sortDirection = SortDirection.ascending;

  final _menuController = MenuController();

  void _toggleFilter(FilterOption option) {
    setState(() {
      _activeFilters.contains(option)
          ? _activeFilters.remove(option)
          : _activeFilters.add(option);
    });
    widget.onFiltersChanged(_activeFilters);
  }

  void _selectSort(SortField field, SortDirection direction) {
    setState(() {
      _sortField = field;
      _sortDirection = direction;
    });
    widget.onSortChanged(field, direction);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: SearchBar(
            constraints: const BoxConstraints(
              minHeight: _barHeight,
              maxHeight: _barHeight,
            ),
            // Flat, matching the (elevation-0 at rest) add button next to
            // it — SearchBar's own default (elevation 6) is meant for a
            // floating full-screen search overlay, not an inline bar.
            elevation: const WidgetStatePropertyAll(0),
            hintText: l10n.command_bar_search_hint,
            leading: const Icon(Icons.search),
            onChanged: widget.onSearchChanged,
            trailing: [
              // One shared menu for both: sorting always applies (name and
              // creation date exist on every model), filter checkboxes are
              // appended below a divider only when the caller supplied any.
              Badge(
                label: Text('${_activeFilters.length}'),
                isLabelVisible: _activeFilters.isNotEmpty,
                child: MenuAnchor(
                  controller: _menuController,
                  menuChildren: [
                    ..._sortOptions(l10n).map((option) {
                      final (field, direction, label) = option;
                      final isActive =
                          field == _sortField && direction == _sortDirection;
                      return MenuItemButton(
                        onPressed: () => _selectSort(field, direction),
                        leadingIcon: Icon(
                          isActive
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isActive ? colorScheme.primary : null,
                        ),
                        child: Text(label),
                      );
                    }),
                    if (widget.filterOptions.isNotEmpty) ...[
                      const Divider(height: 1),
                      ...widget.filterOptions.map((option) {
                        final isActive = _activeFilters.contains(option);
                        return MenuItemButton(
                          onPressed: () => _toggleFilter(option),
                          leadingIcon: Icon(
                            isActive
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: isActive ? colorScheme.primary : null,
                          ),
                          child: Text(option.label),
                        );
                      }),
                    ],
                  ],
                  builder: (context, controller, child) {
                    return IconButton(
                      isSelected: _activeFilters.isNotEmpty,
                      icon: const Icon(Icons.filter_list),
                      tooltip: l10n.command_bar_filter_sort_tooltip,
                      onPressed: () {
                        controller.isOpen
                            ? controller.close()
                            : controller.open();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, _barHeight),
            maximumSize: const Size(double.infinity, _barHeight),
          ),
          onPressed: widget.onAdd,
          icon: addModelIcon,
          // Same source AddButton uses, so the two stay in sync instead of
          // drifting apart as separately hardcoded copies of "add".
          label: Text(l10n.button_add),
        ),
      ],
    );
  }
}
