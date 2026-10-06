import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/item/item_component_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/item/components/component_category_menu.dart';
import 'package:stelaris/feature/item/components/component_dialogs.dart';
import 'package:stelaris/feature/item/components/schema/schema.dart';
import 'package:stelaris/feature/model/model_card_actions.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:vulpes_data/component.dart';
import 'package:vulpes_data/material.dart';

/// Every component of the catalog by its key, also the ones which can't be
/// added, so stored components can always be shown.
final Map<String, ComponentSpec> _specsByKey = {
  for (final spec in componentCatalog) spec.key: spec,
};

/// The item's Components tab: a grid with one card per added component.
///
/// Only components the user added are shown, never all components of the
/// material. Adding and editing happen in dialogs built from the component
/// schema of vulpes, the values are stored through the item components API.
class ItemComponentsPage extends StatefulWidget {
  const ItemComponentsPage({super.key});

  @override
  State<ItemComponentsPage> createState() => _ItemComponentsPageState();
}

class _ItemComponentsPageState extends State<ItemComponentsPage>
    with AutomaticKeepAliveClientMixin {
  static const double _maxCardExtent = 320;
  static const double _cardHeight = 112;
  static const double _spacing = 12;

  /// Shows only the components of this category, null shows all.
  ComponentCategory? _category;

  /// The tab animation which brought this tab into view, until it settled.
  Animation<double>? _tabAnimation;

  /// Whether the tab animation settled. Loading and building the grid wait
  /// for it, so the switch to this tab doesn't stutter.
  bool _settled = false;

  /// The item whose components were requested, so each item loads once
  /// while the tab is kept alive.
  String? _loadedFor;

  /// The fetch is scheduled for the next frame but not dispatched yet.
  bool _fetchScheduled = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settled || _tabAnimation != null) return;
    final animation = DefaultTabController.maybeOf(context)?.animation;
    if (animation == null || _isSettled(animation)) {
      _settled = true;
      return;
    }
    _tabAnimation = animation..addListener(_onTabAnimation);
  }

  @override
  void dispose() {
    _tabAnimation?.removeListener(_onTabAnimation);
    super.dispose();
  }

  /// The animation rests on a tab, it isn't between two.
  static bool _isSettled(Animation<double> animation) =>
      animation.value == animation.value.roundToDouble();

  void _onTabAnimation() {
    final animation = _tabAnimation;
    if (animation == null || !_isSettled(animation)) return;
    animation.removeListener(_onTabAnimation);
    _tabAnimation = null;
    setState(() => _settled = true);
  }

  /// Requests the components of [itemId] once the tab has settled.
  void _loadIfNeeded(String? itemId) {
    if (!_settled || itemId == _loadedFor) return;
    _loadedFor = itemId;
    _fetchScheduled = true;
    // Not during build, the dispatch changes the store.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _fetchScheduled = false);
      context.dispatch(ItemComponentFetchAction());
    });
  }

  Future<void> _add(_ComponentsView vm) async {
    final spec = await showComponentPickerDialog(
      context,
      existing: {for (final component in vm.components) component.componentKey},
      materialDefaults: defaultComponentsOf(vm.material).toSet(),
    );
    if (spec == null || !mounted) return;
    await showComponentEditDialog(
      context,
      spec: spec,
      value: initialValue(spec.schema),
      onSave: (value) => _run(
        ItemComponentAddAction(
          ItemComponentDto(componentKey: spec.key, value: value),
        ),
      ),
    );
  }

  Future<void> _edit(ComponentSpec spec, ItemComponentDto component) async {
    await showComponentEditDialog(
      context,
      spec: spec,
      value: component.value,
      onSave: (value) =>
          _run(ItemComponentUpdateAction(component.copyWith(value: value))),
    );
  }

  /// Runs [action] and resolves to its error, or null when it worked.
  Future<Object?> _run(ReduxAction<AppState> action) async {
    // Without a wrapError on the store, a backend error is rethrown rather
    // than reported through the status.
    try {
      final status = await context.dispatchAndWait(action);
      return status.isCompletedFailed ? status.originalError : null;
    } catch (error) {
      return error;
    }
  }

  Future<void> _remove(String name, ItemComponentDto component) async {
    final confirmed = await showDialog<bool>(
      context: context,
      // Only confirms; the removal runs here, so its error can be shown.
      builder: (context) {
        // Split around the name, so it can be bold wherever a language puts
        // it.
        final [before, after] = context.l10n
            .component_delete_header('\u0000')
            .split('\u0000');
        return DeleteDialog<ItemComponentDto>(
          title: context.l10n.component_delete_title,
          header: [
            TextSpan(text: before),
            TextSpan(
              text: name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: after),
          ],
          value: component,
          successfully: (_) => true,
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final error = await _run(ItemComponentDeleteAction(component));
    if (error != null && mounted) context.showErrorSnackBar(error);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StoreConnector<AppState, _ComponentsView>(
      vm: () => _ComponentsFactory(),
      builder: (context, vm) {
        _loadIfNeeded(vm.itemId);
        // A spinner until the components of this item are loaded, the grid
        // is only built once the tab stands still.
        final pending = !_settled || _fetchScheduled || vm.loading;
        final defaults = defaultComponentsOf(vm.material).toSet();
        final all = [...vm.components]
          ..sort((a, b) => _sortIndex(a).compareTo(_sortIndex(b)));
        // The menu only offers the categories the item has.
        final counts = <ComponentCategory, int>{};
        for (final component in all) {
          final category = _specsByKey[component.componentKey]?.category;
          if (category != null) {
            counts[category] = (counts[category] ?? 0) + 1;
          }
        }
        // A category whose last component was removed filters nothing.
        final category = counts.containsKey(_category) ? _category : null;
        final components = category == null
            ? all
            : [
                for (final component in all)
                  if (_specsByKey[component.componentKey]?.category == category)
                    component,
              ];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: context.l10n.component_page_title(all.length),
                actions: [
                  if (counts.isNotEmpty)
                    ComponentCategoryMenu(
                      value: category,
                      counts: counts,
                      onChanged: (value) => setState(() => _category = value),
                      builder: (context, toggle) => PageHeaderAction(
                        key: const Key('component_category_filter'),
                        icon: const Icon(Icons.filter_list),
                        label:
                            category?.displayName ??
                            context.l10n.component_all_categories,
                        onPressed: toggle,
                      ),
                    ),
                  PageHeaderAction(
                    icon: const Icon(Icons.add),
                    label: context.l10n.button_add,
                    primary: true,
                    loading: pending,
                    onPressed: () => _add(vm),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: switch ((pending, components.isEmpty)) {
                  (true, _) => const Center(child: CircularProgressIndicator()),
                  (false, true) => EmptyDataWidget.full(
                    header: context.l10n.component_empty_header,
                    subHeader: context.l10n.component_empty_body,
                  ),
                  _ => LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          ((constraints.maxWidth + _spacing) /
                                  (_maxCardExtent + _spacing))
                              .floor()
                              .clamp(1, 4);
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: _cardHeight,
                          crossAxisSpacing: _spacing,
                          mainAxisSpacing: _spacing,
                        ),
                        itemCount: components.length,
                        itemBuilder: (context, index) {
                          final component = components[index];
                          final spec = _specsByKey[component.componentKey];
                          final editable =
                              spec != null &&
                              spec.editable &&
                              !dedicatedComponents.contains(spec.key);
                          return _ComponentCard(
                            key: ValueKey(component.id),
                            componentKey: component.componentKey,
                            spec: spec,
                            value: component.value,
                            overridesDefault: defaults.contains(
                              component.componentKey,
                            ),
                            onEdit: editable
                                ? () => _edit(spec, component)
                                : null,
                            onRemove: () => _remove(
                              spec?.displayName ?? component.componentKey,
                              component,
                            ),
                          );
                        },
                      );
                    },
                  ),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Sorts by category like the picker, unknown components come last.
  static int _sortIndex(ItemComponentDto component) =>
      _specsByKey[component.componentKey]?.category.index ??
      ComponentCategory.values.length;
}

class _ComponentsView extends Vm {
  _ComponentsView({
    required this.itemId,
    required this.material,
    required this.components,
    required this.loading,
  }) : super(equals: [itemId, material, components, loading]);

  final String? itemId;
  final String material;
  final List<ItemComponentDto> components;
  final bool loading;
}

class _ComponentsFactory
    extends VmFactory<AppState, ItemComponentsPage, _ComponentsView> {
  @override
  _ComponentsView fromStore() => _ComponentsView(
    itemId: state.selectedItem?.id,
    material: state.selectedItem?.material ?? defaultMaterial,
    components: state.selectedItemComponents,
    loading: isWaiting(ItemComponentFetchAction),
  );
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({
    required this.componentKey,
    required this.spec,
    required this.value,
    required this.overridesDefault,
    required this.onEdit,
    required this.onRemove,
    super.key,
  });

  final String componentKey;

  /// The catalog entry, null for a component the catalog doesn't know (any
  /// more), e.g. after a Minecraft update removed it.
  final ComponentSpec? spec;
  final Object? value;
  final bool overridesDefault;

  /// Opens the edit dialog, null when the component can't be edited.
  final VoidCallback? onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    // Same look as the model grid cards.
    return Card.filled(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      spec?.displayName ?? componentKey,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Same compact buttons as the actions of a model grid card.
                  ModelCardActions(
                    color: colorScheme.onSurfaceVariant,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          key: const Key('component_card_edit'),
                          tooltip: context.l10n.component_edit_tooltip,
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: onEdit,
                        ),
                      IconButton(
                        key: const Key('component_card_remove'),
                        tooltip: context.l10n.component_delete_tooltip,
                        icon: deleteIcon,
                        onPressed: onRemove,
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                switch (spec) {
                  null => context.l10n.component_unknown,
                  final spec when overridesDefault =>
                    context.l10n.component_overrides_default(
                      spec.category.displayName,
                    ),
                  final spec => spec.category.displayName,
                },
                style: mutedStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                switch (spec) {
                  null => context.l10n.component_not_in_catalog(componentKey),
                  final spec => summarize(context.l10n, spec.schema, value),
                },
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
