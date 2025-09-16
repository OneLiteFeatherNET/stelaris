import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/model/attribute_model.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/attribute/attribute_vm_state.dart';
import 'package:stelaris/feature/attributes/attribute_general_page.dart';
import 'package:stelaris/feature/base/paginated_model_list.dart';
import 'package:stelaris/feature/base/model_text.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/functions.dart';

/// A widget that represents the attribute management page.
///
/// The [AttributePage] allows users to view, select, and manage attributes.
/// It provides a dialog for creating new attributes and handles the state
/// management through Redux.
class AttributePage extends StatefulWidget {
  /// Creates an instance of [AttributePage].
  const AttributePage({super.key});

  @override
  State<AttributePage> createState() => _AttributePageState();
}

class _AttributePageState extends State<AttributePage> {
  // No local pagination here. The list items are fully sourced from the store (vm.models).

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AttributeViewModel>(
      vm: () => AttributeVmFactory(),
      onInit: (store) => store.dispatchAndWait(InitAttributeAction()),
      onDispose: (store) => store.dispatch(RemoveSelectAttributeAction(), notify: false),
      builder: (context, vm) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaginatedModelList<AttributeModel>(
              mapToDataModelItem: (value) => TextWidget(displayName: value.uiName),
              openFunction: () => _openDialog(context),
              selectedItem: vm.selected,
              mapToDeleteDialog: (value) => createDeleteText(value.uiName, context),
              mapToDeleteSuccessfully: (value) {
                context.dispatch(AttributeRemoveAction(value));
                return true;
              },
              callFunction: (model) => context.dispatch(SelectAttributeAction(model)),
              models: vm.models,
              compareFunction: (model) => vm.isSelectedItem(model),
              hasMore: vm.hasNextPage,
              isLoadingMore: vm.isLoadingMore,
              onLoadMore: vm.hasNextPage && !vm.isLoadingMore
                  ? () => context.dispatch(InitAttributeAction())
                  : null,
            ),
            if (vm.selected != null) _mapModelToWidget(vm.selected)!,
          ],
        );
      },
    );
  }

  /// Maps the selected [AttributeModel] to a widget.
  ///
  /// Returns an instance of [AttributeGeneralPage] if a model is selected,
  /// otherwise returns null.
  Widget? _mapModelToWidget(AttributeModel? model) {
    if (model == null) return null;
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
          title: 'Create new attribute',
          valueUpdate: (value) {
            final AttributeModel attributeModel = AttributeModel(uiName: value);
            context.dispatchAndWait(AttributeAddAction(attributeModel));
            Navigator.pop(context, true);
          },
          formKey: GlobalKey<FormState>(),
          hintText: 'Example name',
          formatters: [
            FilteringTextInputFormatter.allow(stringWithSpacePattern)
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