import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/entity_search_actions.dart';
import 'package:stelaris/api/state/actions/search_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/command_palette.dart';
import 'package:stelaris/feature/command_palette/command_palette_controller.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris/feature/command_palette/command_registry.dart';
import 'package:stelaris/feature/command_palette/entity_search_source.dart';
import 'package:stelaris/feature/command_palette/entity_search_state.dart';
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

/// The search field in the AppBar, scoped to the current section - and the
/// command palette.
///
/// Plain text edits [AppState.modelSearch], which the section's [ModelPage]
/// filters by, as it always did. The field also opens a dropdown with the
/// palette's entries: commands, the query syntax, entities, projects, help.
/// Its first entry for plain text is "Filter <section> by …", highlighted, so
/// Enter keeps filtering; Down reaches the rest. Input starting with a
/// palette prefix drives only the dropdown and leaves the list's filter alone.
///
/// On a detail page typing no longer leaves for the list - that would make
/// "Delete this item…" untypable. The filter entry leaves instead, through
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
  static const double _dropdownMaxHeight = 440;

  final _controller = TextEditingController();
  late final _focusNode = FocusNode(onKeyEvent: _onKey);
  final OverlayPortalController _dropdown = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final Object _tapGroup = Object();

  /// The store the field dispatches to, kept for [dispose].
  Store<AppState>? _store;

  /// The store's entity search, handed to the palette without rebuilding
  /// the field.
  StreamSubscription<EntitySearchState>? _entitySearchChanges;

  EntitySearchSource? _entitySource;

  /// The list filter last handed to [DebouncedSearchQueryAction] and not yet
  /// in the store. Its debounce waits on a `Future.delayed` that nothing can
  /// cancel, so a cancel is only dispatched while one is actually pending.
  String? _pendingFilter;

  CommandPaletteController? _palette;
  CommandRegistry? _registry;
  Listenable? _requests;

  /// Where the field is, as of the last build.
  NavigationEntry? _entry;
  bool _onDetail = false;

  /// The width the dropdown follows: the field's.
  double _fieldWidth = _maxWidth;

  /// Compact mode only: whether the field is expanded over the AppBar.
  bool _expanded = false;

  /// Set while the leave guard is open, so a second request doesn't stack
  /// a second dialog.
  bool _leavingDetail = false;

  /// The query last taken from or sent to the store. Store changes that
  /// differ from it (e.g. a reset) are copied into the field; changes the
  /// field made itself are not, so the cursor isn't moved while typing.
  String _syncedQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final CommandPaletteHost? host = CommandPaletteHost.maybeOf(context);
    if (host?.registry != _registry) {
      _palette?.dispose();
      _registry = host?.registry;
      _palette = _registry == null
          ? null
          : (CommandPaletteController(
              registry: _registry!,
              query: _controller,
              onRun: _runCommand,
            )..topEntries = _filterEntry);
    }
    _entitySource = host?.entitySearch;
    _palette
      ?..hasEntitySearch = _entitySource != null
      ..onEntityQuery = _onEntityQuery;
    final Store<AppState> store =
        StoreProvider.backdoorInheritedWidget<AppState>(context);
    if (store != _store) {
      _store = store;
      _entitySearchChanges?.cancel();
      _entitySearchChanges = store.onChange
          .map((state) => state.entitySearch)
          .distinct()
          .listen((search) => _palette?.applyEntitySearch(search));
    }
    if (host?.requests != _requests) {
      _requests?.removeListener(_onRequest);
      _requests = host?.requests;
      _requests?.addListener(_onRequest);
    }
  }

  @override
  void dispose() {
    _requests?.removeListener(_onRequest);
    _entitySearchChanges?.cancel();
    // A query still in its debounce belongs to the field that is going away,
    // e.g. when the section changes: drop it.
    if (_pendingFilter != null) {
      _store?.dispatch(DebouncedSearchQueryAction.cancel());
    }
    _palette?.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncFromStore(String query) {
    if (query == _syncedQuery) return;
    _syncedQuery = query;
    if (_controller.text != query) _controller.text = query;
  }

  // ── The dropdown ──

  /// Opens the dropdown for what the palette may see right now.
  void _openDropdown() {
    final CommandPaletteController? palette = _palette;
    if (palette == null || _dropdown.isShowing) return;
    palette.configure(
      CommandContext(
        state: StoreProvider.backdoorInheritedWidget<AppState>(context).state,
        location: GoRouter.of(context).state.matchedLocation,
      ),
      context.l10n,
    );
    _dropdown.show();
  }

  void _closeDropdown() {
    if (_dropdown.isShowing) _dropdown.hide();
  }

  /// `Ctrl+K`: open - expanding the field first where it is collapsed -
  /// or close again.
  void _onRequest() {
    if (_dropdown.isShowing) {
      _closeDropdown();
      return;
    }
    if (_isCompact && !_expanded) {
      setState(() => _expanded = true);
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusAndOpen());
      return;
    }
    _focusAndOpen();
  }

  bool _isCompact = false;

  void _focusAndOpen() {
    if (!mounted) return;
    _focusNode.requestFocus();
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    _openDropdown();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final CommandPaletteController? palette = _palette;
    if (palette == null) return KeyEventResult.ignored;
    if (!_dropdown.isShowing) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _openDropdown();
        return KeyEventResult.handled;
      }
      // Esc with the dropdown closed stays the field's: it clears.
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _closeDropdown();
      return KeyEventResult.handled;
    }
    return palette.handleKey(event);
  }

  /// A palette entry was chosen: the dropdown goes first, so a dialog or a
  /// navigation the command starts isn't covered by it.
  void _runCommand(StelarisCommand command) {
    _closeDropdown();
    if (command.id != _filterId) {
      // Done with the palette: the field goes back to showing the list's
      // filter, in plain mode, instead of keeping the command's chip and text.
      _focusNode.unfocus();
      _cancelPendingFilter();
      _palette?.reset();
      _controller.text = _syncedQuery;
    }
    command.run(context);
  }

  // ── Filtering ──

  static const String _filterId = 'search.filter';

  /// "Filter Items by 'sword'" on a list, "Show Items matching 'sword'" on a
  /// detail page - first and highlighted for plain text, so Enter filters.
  List<StelarisCommand> _filterEntry(String text) {
    final NavigationEntry? entry = _entry;
    if (entry == null) return const [];
    final bool onDetail = _onDetail;
    return [
      StelarisCommand(
        id: _filterId,
        title: (l10n) => onDetail
            ? l10n.command_palette_show_matching(entry.display, text)
            : l10n.command_palette_filter_list(entry.display, text),
        section: (_) => entry.display,
        group: CommandGroup.navigation,
        icon: Icons.filter_list,
        run: (_) async {
          if (onDetail) {
            await _leaveDetail(entry);
          } else {
            _applyFilterNow();
          }
        },
      ),
    ];
  }

  void _onChanged(String value) {
    final CommandPaletteController? palette = _palette;
    if (palette != null) {
      _openDropdown();
      palette.onTextChanged(value);
      // A prefix only drives the dropdown; the list keeps the filter it had.
      if (!palette.isPlain) {
        _cancelPendingFilter();
        return;
      }
    }
    if (_onDetail) return;
    // Only the last of these within the pause reaches the store; the field
    // picks it up from there like any other store change.
    final String query = _controller.text;
    _pendingFilter = query;
    // Done once the debounce ran out - applied, superseded or unchanged - so
    // there is nothing left to cancel for this query.
    context.dispatchAndWait(DebouncedSearchQueryAction(query)).then((_) {
      if (_pendingFilter == query) _pendingFilter = null;
    });
  }

  /// Drops a list filter still waiting in its debounce, if there is one.
  void _cancelPendingFilter() {
    if (_pendingFilter == null) return;
    _pendingFilter = null;
    context.dispatch(DebouncedSearchQueryAction.cancel());
  }

  /// The palette's entity question, as Redux actions: recorded at once, and
  /// asked once typing pauses.
  void _onEntityQuery(EntitySearchRequest? request) {
    final Store<AppState>? store = _store;
    final EntitySearchSource? source = _entitySource;
    if (store == null) return;
    if (request == null || source == null) {
      store.dispatch(ClearEntitySearchAction());
      return;
    }
    store
      ..dispatch(EntitySearchStartedAction(request))
      ..dispatch(EntitySearchAction(source, request));
  }

  /// The filter entry on a list: no need to wait for the debounce.
  void _applyFilterNow() {
    _cancelPendingFilter();
    final String query = _controller.text;
    _syncedQuery = query;
    context.dispatch(UpdateSearchQueryAction(query));
  }

  void _clear() {
    _cancelPendingFilter();
    _controller.clear();
    _palette?.reset();
    _syncedQuery = '';
    context.dispatch(UpdateSearchQueryAction(''));
  }

  Future<void> _leaveDetail(NavigationEntry entry) async {
    if (_leavingDetail) return;
    _leavingDetail = true;
    try {
      final canLeave = await confirmLeaveIfDirty(context);
      if (!mounted || !canLeave) return;
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
    _entry = entry;
    _onDetail = location != entry.route;

    return StoreConnector<AppState, ModelSearchState>(
      converter: (store) => store.state.modelSearch,
      builder: (context, search) {
        _syncFromStore(search.query);
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < AppBarSearch.compactThreshold;
            _isCompact = compact;
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
            _fieldWidth = constraints.maxWidth < _maxWidth
                ? constraints.maxWidth
                : _maxWidth;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxWidth),
                child: _buildSearchBar(
                  context,
                  entry: entry,
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
    required ModelSearchState search,
    required bool showClose,
  }) {
    final CommandPaletteController? palette = _palette;
    final Widget field = palette == null
        ? _searchBar(
            context,
            entry: entry,
            search: search,
            showClose: showClose,
          )
        : ListenableBuilder(
            // The chip and the placeholder follow the palette's mode - only
            // its mode: listening to the whole controller rebuilt the field
            // on every keystroke.
            listenable: palette.fieldState,
            builder: (context, _) => _searchBar(
              context,
              entry: entry,
              search: search,
              showClose: showClose,
            ),
          );
    return OverlayPortal(
      controller: _dropdown,
      overlayChildBuilder: _buildDropdown,
      child: CompositedTransformTarget(
        link: _link,
        child: TapRegion(
          groupId: _tapGroup,
          onTapOutside: (_) => _closeDropdown(),
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.escape): _clear,
            },
            child: field,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    final CommandPaletteController? palette = _palette;
    if (palette == null) return const SizedBox.shrink();
    return CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      targetAnchor: Alignment.bottomLeft,
      offset: const Offset(0, 6),
      child: Align(
        alignment: Alignment.topLeft,
        child: TapRegion(
          groupId: _tapGroup,
          child: SizedBox(
            width: _fieldWidth,
            child: Material(
              key: const Key('command-palette-dropdown'),
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: _dropdownMaxHeight,
                ),
                child: CommandPanel(controller: palette),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar(
    BuildContext context, {
    required NavigationEntry entry,
    required ModelSearchState search,
    required bool showClose,
  }) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final CommandPaletteController? palette = _palette;
    final String? chip = palette?.chipLabel(l10n);
    return SearchBar(
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
      hintText:
          palette?.hint(l10n) ??
          l10n.command_palette_hint_section(entry.display),
      onTap: _openDropdown,
      // In compact mode the leading button collapses the field (the query
      // keeps filtering the list), so the trailing X can always mean clear.
      leading: chip != null
          // Inset like the search icon it replaces (24px in a 32px box), so
          // the chip starts on the same line instead of against the rounded
          // edge of the field.
          ? Padding(
              padding: const EdgeInsets.only(left: (_iconButtonSize - 24) / 2),
              child: InputChip(
                key: const Key('command-palette-mode-chip'),
                label: Text(chip),
                visualDensity: VisualDensity.compact,
                // A pill inside the pill-shaped field, not Material's
                // default rounded rectangle.
                shape: const StadiumBorder(),
                onDeleted: palette!.leaveMode,
                deleteButtonTooltipMessage: l10n.command_palette_remove_mode,
                // Clicking the chip must not take focus from the field.
                onPressed: () => _focusNode.requestFocus(),
              ),
            )
          : SizedBox(
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
                      key: const Key('command-palette-search-icon'),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.search),
                      tooltip: l10n.command_bar_search_tooltip,
                      onPressed: _focusAndOpen,
                    ),
            ),
      onChanged: _onChanged,
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
