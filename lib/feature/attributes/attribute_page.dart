import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/attribute/attribute_vm_state.dart';
import 'package:stelaris/feature/attributes/attribute_edit_dialog.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/feature/model/filter_option.dart';
import 'package:stelaris/feature/model/model_page.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A widget that represents the attribute management page.
///
/// The [AttributePage] allows users to view, search, filter, and manage
/// attributes through a [ModelPage]. It provides a dialog for creating new
/// attributes and handles the state management through Redux. Tapping an
/// attribute opens a dialog to edit its default/maximum value — an
/// attribute only has those two editable fields, so a dedicated detail
/// route/page would be overkill.
class AttributePage extends StatelessWidget {
  /// Creates an instance of [AttributePage].
  const AttributePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AttributeViewModel>(
      vm: () => AttributeVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitAttributeAction()),
      builder: (context, vm) {
        final hasDefaultValueFilter = FilterOption(
          'has_default_value',
          context.l10n.filter_attribute_has_default_value,
        );
        final hasMaximumValueFilter = FilterOption(
          'has_maximum_value',
          context.l10n.filter_attribute_has_maximum_value,
        );

        return ModelPage<AttributeModel>(
          mapToDataModelItem: (value) =>
              _buildCardContent(context, vm.projectKey, value),
          mapToDeleteDialog: (value) =>
              createDeleteText(value.uiName, context),
          mapToDeleteSuccessfully: (value) {
            context.dispatch(AttributeRemoveAction(value));
            return true;
          },
          models: vm.models,
          matchesSearch: (model, query) =>
              model.uiName.toLowerCase().contains(query.toLowerCase()),
          nameSelector: (model) => model.uiName,
          filterOptions: [hasDefaultValueFilter, hasMaximumValueFilter],
          matchesFilter: (model, filter) => switch (filter.id) {
            'has_default_value' =>
              model.defaultValue != null && model.defaultValue != 0,
            'has_maximum_value' =>
              model.maximumValue != null && model.maximumValue != 0,
            _ => true,
          },
          onAdd: () => _openDialog(context, vm.projectKey),
          onModelTap: (model) => showDialog(
            context: context,
            builder: (_) => AttributeEditDialog(model: model),
          ),
          onRefresh: () => context.dispatch(RefreshAttributeAction()),
          hasMore: vm.hasNextPage,
          isLoadingMore: vm.isLoadingMore,
          onLoadMore: vm.hasNextPage && !vm.isLoadingMore
              ? () => context.dispatch(InitAttributeAction())
              : null,
        );
      },
    );
  }

  /// Builds the primary card content for an [AttributeModel]: its display
  /// name plus its namespaced key (e.g. `manis:test`), derived client-side
  /// from the current project's key and the model's local [AttributeModel.key].
  Widget _buildCardContent(
    BuildContext context,
    String projectKey,
    AttributeModel value,
  ) {
    final key = value.key;
    final namespacedKey = key != null && key.isNotEmpty
        ? '$projectKey:$key'
        : null;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.uiName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (namespacedKey != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.vpn_key_outlined,
                  size: 12,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    namespacedKey,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Opens a dialog for creating a new attribute.
  ///
  /// The dialog includes a text field for the attribute name and handles
  /// validation and state management for adding the new attribute.
  void _openDialog(BuildContext context, String projectKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModelCreateDialog(
          title: context.l10n.dialog_attribute_create,
          projectNamespace: projectKey,
          onSubmit: (name, key) {
            final AttributeModel attributeModel = AttributeModel(
              uiName: name,
              key: key,
            );
            context.dispatchAndWait(AttributeAddAction(attributeModel));
            Navigator.pop(context, true);
          },
        );
      },
    );
  }
}
