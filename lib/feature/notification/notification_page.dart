import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/state/actions/notification_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/factory/notification_vm_state.dart';
import 'package:stelaris_ui/feature/base/base_model_view.dart';
import 'package:stelaris_ui/feature/base/model_text.dart';
import 'package:stelaris_ui/feature/dialogs/entry_add_dialog.dart';
import 'package:stelaris_ui/feature/notification/notification_page_general.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/functions.dart';

class NotificationPage extends StatelessWidget {

  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NotificationViewModel>(
      vm: () => NotificationVmFactory(),
      onInit: (store) => store.dispatchAsync(InitNotificationAction()),
      builder: (context, vm) {
        return BaseModelView<NotificationModel>(
            mapToDataModelItem: (value) =>
                ModelText(displayName: value.modelName),
            openFunction: () => _openCreationDialog(context),
            selectedItem: vm.selected,
            mapToDeleteDialog: (value) {
              return [
                TextSpan(
                    text: context.l10n.delete_dialog_first_line,
                    style: whiteStyle),
                TextSpan(
                  text: value.modelName ?? unknownEntry,
                  style: redStyle,
                ),
                TextSpan(
                  text: context.l10n.delete_dialog_entry,
                  style: whiteStyle,
                ),
              ];
            },
            mapToDeleteSuccessfully: (value) {
              StoreProvider.dispatch(context, RemoveNotificationAction(value));
              return true;
            },
            callFunction: (model) => StoreProvider.dispatch(
                context, SelectedNotificationAction(model)),
            models: vm.models,
            child: _mapPageToWidget(vm.selected),
            compareFunction: (model) => vm.isSelectedItem(model),
        );
      },
    );
  }

  void _openCreationDialog(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return EntryAddDialog(
          title: 'Create new notification',
          valueUpdate: (value) {
            NotificationModel model = NotificationModel(modelName: value);
            StoreProvider.dispatch(context, NotificationAddAction(model));
            Navigator.pop(context, true);
          },
          formKey: GlobalKey<FormState>(),
          hintText: 'Example name',
          formatters: [FilteringTextInputFormatter.allow(stringWithSpacePattern)],
          formFieldValidator: (value) {
            var input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          clearFunction: (text) => text.trim().isNotEmpty,
          autoFocus: true,
        );
      },
    );
  }

  Widget? _mapPageToWidget(NotificationModel? model) {
    if (model == null) return null;
    return NotificationGeneralPage(model: model);
  }
}
