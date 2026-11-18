import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/picker/asset_picker_dialog.dart';
import 'package:stelaris/feature/asset/preview/asset_scene_view.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/picker/filter_groups.dart';
import 'package:stelaris/feature/base/picker/grouped_picker_list.dart';
import 'package:stelaris/feature/base/search/dialog_search_bar.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/feature/item/components/book/written_book.dart';
import 'package:stelaris/feature/item/components/book/written_book_editor.dart';
import 'package:stelaris/feature/item/components/component_category_menu.dart';
import 'package:stelaris/feature/item/components/schema/schema.dart';
import 'package:stelaris/feature/item/components/stelaris_components.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart' show AssetModel;
import 'package:vulpes_data/component.dart';
import 'package:stelaris/util/app_shapes.dart';

/// The components which are edited outside of the components tab. The item
/// keeps them in its own storage, so the backend rejects them as components.
///
/// The stored enchantments of an enchanted book come from the enchantments
/// tab too, the material decides which of the two the item gets in game.
const Set<String> dedicatedComponents = {
  'minecraft:lore',
  'minecraft:enchantments',
  'minecraft:stored_enchantments',
};

/// The key of the component whose value names a model of the project.
const String itemModelComponent = 'minecraft:item_model';

/// The project a component belongs to, with the id the assets are stored
/// under and the key their namespace comes from.
typedef ComponentProject = ({String id, String key});

/// Every component the components tab knows: the Stelaris ones first, then
/// the vanilla catalog.
final List<ComponentSpec> componentCatalog = [
  ...stelarisComponents,
  ...dataComponents,
];

/// The components which can be added in the components tab.
///
/// Components with a dedicated editor and runtime state which can't be set
/// are not offered.
final List<ComponentSpec> offeredComponents = [
  for (final spec in componentCatalog)
    if (spec.editable && !dedicatedComponents.contains(spec.key)) spec,
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

  static const double _filterButtonSize = 32;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  /// The search text. Only the list listens to it, so a keystroke leaves the
  /// search bar and the filter alone.
  final ValueNotifier<String> _search = ValueNotifier('');

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
    _search.dispose();
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

  @override
  Widget build(BuildContext context) {
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
            // With its filter menu.
            DialogSearchBar(
              controller: _controller,
              focusNode: _focusNode,
              hintText: category == null
                  ? context.l10n.component_search_hint
                  : context.l10n.component_search_in(category.displayName),
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
              onChanged: (value) => _search.value = value,
            ),
            verticalSpacing10,
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _search,
                builder: (context, search, _) => GroupedPickerList(
                  groups: filterGroups(
                    _addable,
                    search: search,
                    only: category,
                    groupLabel: (category) => category.displayName,
                    matches: (spec, search) =>
                        spec.displayName.toLowerCase().contains(search) ||
                        spec.key.contains(search),
                  ),
                  groupLabel: (category) => category.displayName,
                  groupTooltip: context.l10n.component_category_only,
                  headerKey: (category) =>
                      Key('component_category_header_${category.key}'),
                  itemKey: (spec) => ValueKey('component_${spec.key}'),
                  itemBuilder: (context, spec) => _ComponentRow(
                    spec: spec,
                    isDefault: widget.materialDefaults.contains(spec.key),
                    onTap: () => Navigator.of(context).pop(spec),
                  ),
                  emptyText: context.l10n.component_search_empty,
                  // A filtered list has only one header, so it offers
                  // nothing to click.
                  onGroup: category == null ? _selectCategory : null,
                ),
              ),
            ),
          ],
        ),
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
///
/// The item model also gets a button to choose a model of the [project].
Future<bool> showComponentEditDialog(
  BuildContext context, {
  required ComponentSpec spec,
  required Object? value,
  required ComponentSave onSave,
  ComponentProject? project,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _ComponentEditDialog(
      spec: spec,
      value: value,
      onSave: onSave,
      project: project,
    ),
  );
  return saved ?? false;
}

class _ComponentEditDialog extends StatefulWidget {
  const _ComponentEditDialog({
    required this.spec,
    required this.value,
    required this.onSave,
    required this.project,
  });

  final ComponentSpec spec;
  final Object? value;
  final ComponentSave onSave;
  final ComponentProject? project;

  @override
  State<_ComponentEditDialog> createState() => _ComponentEditDialogState();
}

class _ComponentEditDialogState extends State<_ComponentEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late Object? _value = widget.value;
  bool _saving = false;

  /// Changes whenever a model is chosen, so the key field shows the new key.
  int _fieldEpoch = 0;

  /// Books have too many parts for the form, they get their own editor.
  bool get _isBook => widget.spec.key == writtenBookComponent;

  /// Only the item model names a project asset, and only in a project.
  bool get _isItemModel =>
      widget.spec.key == itemModelComponent && widget.project != null;

  /// Whether the model picker is shown in place of the form.
  bool _choosingModel = false;

  void _chooseModel() => setState(() => _choosingModel = true);

  void _onModelPicked(AssetModel asset) {
    setState(() {
      _choosingModel = false;
      _value = asset.key;
      _fieldEpoch++;
    });
  }

  /// The model picker in place of the form, so no dialog lies on another.
  Widget _buildModelPicker(ComponentProject project) {
    final current = _value;
    return AssetPicker(
      projectId: project.id,
      namespace: project.key,
      selectedKey: current is String ? current : null,
      previewBuilder: (asset) =>
          AssetSceneView(projectId: project.id, asset: asset),
      embedded: true,
      onPicked: _onModelPicked,
      onCancel: () => setState(() => _choosingModel = false),
    );
  }

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
    if (widget.project case final project? when _choosingModel) {
      return _buildModelPicker(project);
    }
    final theme = Theme.of(context);
    return FormDialog(
      title: widget.spec.displayName,
      actionIcon: Icons.save_outlined,
      actionLabel: context.l10n.button_save,
      onSubmit: _saving ? null : _submit,
      busy: _saving,
      // The book shows its page next to the editor.
      maxWidth: _isBook ? 900 : 600,
      // The inputs and their hints use the size of the dialog's other texts
      // instead of the larger default of text fields.
      content: Theme(
        data: theme.copyWith(
          textTheme: theme.textTheme.copyWith(
            bodyLarge: theme.textTheme.bodyMedium,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Pill(widget.spec.category.displayName),
                  _Pill(widget.spec.key),
                ],
              ),
              verticalSpacing10,
              if (_isBook)
                WrittenBookEditor(
                  value: _value,
                  // Only kept, the editor shows its own state.
                  onChanged: (value) => _value = value,
                )
              else
                SchemaField(
                  key: ValueKey(_fieldEpoch),
                  schema: widget.spec.schema,
                  value: _value,
                  onChanged: (value) => setState(() => _value = value),
                  suffix: _isItemModel
                      ? IconButton(
                          key: const Key('item_model_choose_asset'),
                          tooltip: context.l10n.asset_pick_model_tooltip,
                          icon: const Icon(Icons.view_in_ar),
                          onPressed: _chooseModel,
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small label in the header of the edit dialog.
class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppShapes.medium),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
