import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/model/attribute_model.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/attribute/attribute_vm_state.dart';
import 'package:stelaris/feature/attributes/attribute_general_page.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/paginated_model_list.dart';
import 'package:stelaris/feature/base/model_text.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A widget that represents the attribute management page.
///
/// The [AttributePage] allows users to view, select, and manage attributes.
/// It provides a dialog for creating new attributes and handles the state
/// management through Redux.
class AttributePage extends StatelessWidget {
  /// Creates an instance of [AttributePage].
  const AttributePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AttributeViewModel>(
      vm: () => AttributeVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitAttributeAction()),
      onDispose: (store) =>
          store.dispatch(RemoveSelectAttributeAction(), notify: false),
      builder: (context, vm) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaginatedModelList<AttributeModel>(
              mapToDataModelItem: (value) =>
                  TextWidget(displayName: value.uiName),
              openFunction: () => _openDialog(context),
              selectedItem: vm.selected,
              mapToDeleteDialog: (value) =>
                  createDeleteText(value.uiName, context),
              mapToDeleteSuccessfully: (value) {
                context.dispatch(AttributeRemoveAction(value));
                return true;
              },
              callFunction: (model) =>
                  context.dispatch(SelectAttributeAction(model)),
              models: vm.models,
              compareFunction: (model) => vm.isSelectedItem(model),
              hasMore: vm.hasNextPage,
              isLoadingMore: vm.isLoadingMore,
              onLoadMore: vm.hasNextPage && !vm.isLoadingMore
                  ? () => context.dispatch(InitAttributeAction())
                  : null,
            ),
            _mapModelToWidget(context, vm.selected),
          ],
        );
      },
    );
  }

  /// Maps the given [AttributeModel] to the right widget.
  /// If the model is null, it returns an [Expanded] widget with an [EmptyDataWidget].
  /// Otherwise, it returns an instance of [AttributeGeneralPage].
  Widget _mapModelToWidget(BuildContext context, AttributeModel? model) {
    if (model == null) {
      return Expanded(
        child: EmptyDataWidget.standard(
          header: context.l10n.empty_data_header,
          subHeader: context.l10n.empty_data_subHeader
        ),
      );
    }
    return AttributeGeneralPage();
  }

  /// Opens a dialog for creating a new attribute.
  ///
  /// The dialog includes a text field for the attribute name and handles
  /// validation and state management for adding the new attribute.
  void _openDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          title: context.l10n.dialog_attribute_create,
          valueUpdate: (value) {
            final AttributeModel attributeModel = AttributeModel(uiName: value);
            context.dispatchAndWait(AttributeAddAction(attributeModel));
            Navigator.pop(context, true);
          },
          formKey: GlobalKey<FormState>(),
          hintText: 'Example name',
          formatters: [
            FilteringTextInputFormatter.allow(stringWithSpacePattern),
          ],
          formFieldValidator: (value) {
            final String input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          clearFunction: (text) => text.trim().isNotEmpty,
        );
      },
    );
  }
}
