import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/item/item_component_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/item/components/component_category_menu.dart';
import 'package:stelaris/feature/item/components/component_dialogs.dart';
import 'package:stelaris/feature/item/components/schema_field.dart';
import 'package:stelaris/feature/model/model_card_actions.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:vulpes_data/component.dart';
import 'package:vulpes_data/material.dart';

/// Every component of the catalog by its key, also the ones which can't be
/// added, so stored components can always be shown.
final Map<String, ComponentSpec> _specsByKey = {
  for (final spec in dataComponents) spec.key: spec,
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

class _ItemComponentsPageState extends State<ItemComponentsPage> {
  static const double _maxCardExtent = 320;
  static const double _cardHeight = 112;
  static const double _spacing = 12;

  /// Shows only the components of this category, null shows all.
  ComponentCategory? _category;

  Future<void> _add(_ComponentsView vm) async {
    final spec = await showComponentPickerDialog(
      context,
      existing: {for (final component in vm.components) component.componentKey},
      materialDefaults: defaultComponentsOf(vm.material).toSet(),
    );
    if (spec == null || !mounted) return;
    final result = await showComponentEditDialog(
      context,
      spec: spec,
      value: initialValue(spec.schema),
    );
    if (result == null || !mounted) return;
    context.dispatch(
      ItemComponentAddAction(
        ItemComponentDto(componentKey: spec.key, value: result.value),
      ),
    );
  }

  Future<void> _edit(ComponentSpec spec, ItemComponentDto component) async {
    final result = await showComponentEditDialog(
      context,
      spec: spec,
      value: component.value,
    );
    if (result == null || !mounted) return;
    context.dispatch(
      ItemComponentUpdateAction(component.copyWith(value: result.value)),
    );
  }

  Future<void> _remove(String name, ItemComponentDto component) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => FormDialog(
        title: 'Remove component',
        content: Text('Remove "$name" from the item? Its value will be lost.'),
        actionLabel: 'Remove',
        actionIcon: Icons.delete_forever,
        destructive: true,
        onSubmit: () => Navigator.of(context).pop(true),
      ),
    );
    if (confirmed != true || !mounted) return;
    context.dispatch(ItemComponentDeleteAction(component));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ComponentsView>(
      vm: () => _ComponentsFactory(),
      onInit: (store) => store.dispatch(ItemComponentFetchAction()),
      builder: (context, vm) {
        final defaults = defaultComponentsOf(vm.material).toSet();
        final all = [...vm.components]
          ..sort((a, b) => _sortIndex(a).compareTo(_sortIndex(b)));
        // Only categories the item has, in the order of the grid.
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
                title: 'Components (${all.length})',
                actions: [
                  if (counts.isNotEmpty)
                    ComponentCategoryMenu(
                      value: category,
                      counts: counts,
                      onChanged: (value) => setState(() => _category = value),
                      builder: (context, toggle) => PageHeaderAction(
                        key: const Key('component_category_filter'),
                        icon: const Icon(Icons.filter_list),
                        label: category?.displayName ?? 'All categories',
                        onPressed: toggle,
                      ),
                    ),
                  PageHeaderAction(
                    icon: const Icon(Icons.add),
                    label: context.l10n.button_add,
                    primary: true,
                    loading: vm.loading,
                    onPressed: () => _add(vm),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: switch ((vm.loading, components.isEmpty)) {
                  (true, true) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  (false, true) => const EmptyDataWidget.full(
                    header: 'No components yet',
                    subHeader: 'Add a component to change how the item behaves, e.g. food or a tool.',
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
                              spec != null && spec.editable && !spec.managed;
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
    required this.material,
    required this.components,
    required this.loading,
  }) : super(equals: [material, components, loading]);

  final String material;
  final List<ItemComponentDto> components;
  final bool loading;
}

class _ComponentsFactory
    extends VmFactory<AppState, ItemComponentsPage, _ComponentsView> {
  @override
  _ComponentsView fromStore() => _ComponentsView(
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
                          tooltip: 'Edit component',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: onEdit,
                        ),
                      IconButton(
                        key: const Key('component_card_remove'),
                        tooltip: 'Remove component',
                        icon: deleteIcon,
                        onPressed: onRemove,
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                switch (spec) {
                  null => 'Unknown component',
                  final spec when overridesDefault =>
                    '${spec.category.displayName} · overrides the default',
                  final spec => spec.category.displayName,
                },
                style: mutedStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                switch (spec) {
                  null => '$componentKey is not in the component catalog',
                  final spec => summarize(spec.schema, value),
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
