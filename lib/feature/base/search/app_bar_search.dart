import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/search_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/unsaved/unsaved_changes_guard.dart';
import 'package:stelaris/feature/model/model_sort_option.dart';
import 'package:stelaris/l10n/app_localizations.dart';
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

/// The search field in the AppBar, scoped to the current section. Edits
/// [AppState.modelSearch], which the section's [ModelPage] filters by.
///
/// On a detail page, typing leaves for the section's list — through
/// [confirmLeaveIfDirty], so unsaved edits aren't dropped silently.
class AppBarSearch extends StatefulWidget {
  const AppBarSearch({super.key});

  /// Below this width the field collapses to a search icon that expands it
  /// over the AppBar, instead of squeezing it next to the actions.
  static const double compactThreshold = 600;

  @override
  State<AppBarSearch> createState() => _AppBarSearchState();
}

class _AppBarSearchState extends State<AppBarSearch> {
  // Slightly below the AppBar's 48px toolbar, so the field doesn't touch
  // its top and bottom edges.
  static const double _barHeight = 40;
  static const double _maxWidth = 640;
  static const double _iconButtonSize = 32;
  static const Duration _debounce = Duration(milliseconds: 300);

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;

  /// Compact mode only: whether the field is expanded over the AppBar.
  bool _expanded = false;

  /// Set while the leave guard is open, so further typing on a detail page
  /// doesn't stack a second dialog.
  bool _leavingDetail = false;

  /// The query last taken from or sent to the store. Store changes that
  /// differ from it (e.g. a reset) are copied into the field; changes the
  /// field made itself are not, so the cursor isn't moved while typing.
  String _syncedQuery = '';

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncFromStore(String query) {
    if (query == _syncedQuery) return;
    _syncedQuery = query;
    if (_controller.text != query) _controller.text = query;
  }

  void _onChanged(String value, NavigationEntry entry, bool onDetail) {
    if (onDetail) {
      _leaveDetail(entry);
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      _syncedQuery = value;
      context.dispatch(UpdateSearchQueryAction(value));
    });
  }

  void _clear() {
    _debounceTimer?.cancel();
    _controller.clear();
    _syncedQuery = '';
    context.dispatch(UpdateSearchQueryAction(''));
  }

  Future<void> _leaveDetail(NavigationEntry entry) async {
    if (_leavingDetail) return;
    _leavingDetail = true;
    try {
      final canLeave = await confirmLeaveIfDirty(context);
      if (!mounted) return;
      if (!canLeave) {
        _controller.text = _syncedQuery;
        return;
      }
      // Read after the dialog, so whatever was typed while it was open
      // isn't lost.
      final query = _controller.text;
      _syncedQuery = query;
      context.dispatch(UpdateSearchQueryAction(query));
      context.go(entry.route);
    } finally {
      _leavingDetail = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final entry = entryForLocation(location);
    if (entry == null) return const SizedBox.shrink();
    final onDetail = location != entry.route;

    return StoreConnector<AppState, ModelSearchState>(
      converter: (store) => store.state.modelSearch,
      builder: (context, search) {
        _syncFromStore(search.query);
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < AppBarSearch.compactThreshold;
            if (compact && !_expanded) {
              return Center(
                child: IconButton(
                  key: const Key('app_bar_search_open'),
                  tooltip: context.l10n.command_bar_search_tooltip,
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() => _expanded = true),
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxWidth),
                child: _buildSearchBar(
                  context,
                  entry: entry,
                  onDetail: onDetail,
                  search: search,
                  showClose: compact,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchBar(
    BuildContext context, {
    required NavigationEntry entry,
    required bool onDetail,
    required ModelSearchState search,
    required bool showClose,
  }) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final searchBar = SearchBar(
      controller: _controller,
      focusNode: _focusNode,
      // Only when just expanded from the compact icon — the always-visible
      // wide field must not steal focus on every page load.
      autoFocus: showClose,
      constraints: const BoxConstraints(
        minHeight: _barHeight,
        maxHeight: _barHeight,
      ),
      elevation: const WidgetStatePropertyAll(0),
      // SearchBar's default fill (surfaceContainerHigh) is one tone off the
      // app chrome in light mode and identical to it in dark mode, so the
      // field disappeared. The content panel's surface tone plus an outline
      // sets it apart in both.
      backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
      side: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide(color: colorScheme.outlineVariant),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12),
      ),
      hintText: l10n.app_bar_search_hint(entry.display),
      // In compact mode the leading button collapses the field (the query
      // keeps filtering the list), so the trailing X can always mean clear.
      leading: SizedBox(
        width: _iconButtonSize,
        height: _iconButtonSize,
        child: showClose
            ? IconButton(
                key: const Key('app_bar_search_close'),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.app_bar_search_close_tooltip,
                onPressed: () => setState(() => _expanded = false),
              )
            : IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.search),
                tooltip: l10n.command_bar_search_tooltip,
                onPressed: () => _focusNode.requestFocus(),
              ),
      ),
      onChanged: (value) => _onChanged(value, entry, onDetail),
      trailing: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              width: _iconButtonSize,
              height: _iconButtonSize,
              child: IconButton(
                key: const Key('app_bar_search_clear'),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close),
                tooltip: l10n.search_clear_tooltip,
                onPressed: _clear,
              ),
            );
          },
        ),
        _buildFilterMenu(context, search),
      ],
    );
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _clear},
      child: searchBar,
    );
  }

  Widget _buildFilterMenu(BuildContext context, ModelSearchState search) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Badge(
      label: Text('${search.activeFilters.length}'),
      isLabelVisible: search.activeFilters.isNotEmpty,
      child: MenuAnchor(
        menuChildren: [
          ..._sortOptions(l10n).map((option) {
            final (field, direction, label) = option;
            final isActive =
                field == search.sortField && direction == search.sortDirection;
            return MenuItemButton(
              onPressed: () =>
                  context.dispatch(UpdateSearchSortAction(field, direction)),
              leadingIcon: Icon(
                isActive
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isActive ? colorScheme.primary : null,
              ),
              child: Text(label),
            );
          }),
          if (search.availableFilters.isNotEmpty) ...[
            const Divider(height: 1),
            ...search.availableFilters.map((option) {
              final isActive = search.activeFilters.contains(option);
              return MenuItemButton(
                onPressed: () =>
                    context.dispatch(ToggleSearchFilterAction(option)),
                leadingIcon: Icon(
                  isActive ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isActive ? colorScheme.primary : null,
                ),
                child: Text(option.label),
              );
            }),
          ],
        ],
        builder: (context, controller, child) {
          // Explicit SizedBox: the anchor ignores IconButton's own
          // constraints and would stretch it to the bar's full height.
          return SizedBox(
            width: _iconButtonSize,
            height: _iconButtonSize,
            child: IconButton(
              padding: EdgeInsets.zero,
              isSelected: search.activeFilters.isNotEmpty,
              icon: const Icon(Icons.filter_list),
              tooltip: l10n.command_bar_filter_sort_tooltip,
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
            ),
          );
        },
      ),
    );
  }
}
